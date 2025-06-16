package cmd

import (
	"context"
	"fmt"
	"log"
	"regexp"
	"strconv"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/autoscaling"
	"github.com/spf13/cobra"
)

var logicalName, cronExpr string
var durationMinutes int
var dryRun, verbose bool

// Environment scaling rules for downscale
var scheduleRules = map[string]int32{
	"prod":  2,
	"uat":   1,
	"stage": 0,
}

var asgScheduleCmd = &cobra.Command{
	Use:   "asg-schedule",
	Short: "Create scheduled scaling actions on AWS Auto Scaling Groups",
}

var applyCmd = &cobra.Command{
	Use:   "apply",
	Short: "Apply scheduled scaling actions to matching ASGs",
	Run: func(cmd *cobra.Command, args []string) {
		cfg, err := config.LoadDefaultConfig(context.TODO())
		if err != nil {
			log.Fatalf("failed to load AWS config: %v", err)
		}

		svc := autoscaling.NewFromConfig(cfg)
		asgPattern := regexp.MustCompile(`^epro-[a-zA-Z0-9-]+-(dev|qa|uat|stage|prod|train|demo)-v[0-9]+$`)

		asgs, err := svc.DescribeAutoScalingGroups(context.TODO(), &autoscaling.DescribeAutoScalingGroupsInput{})
		if err != nil {
			log.Fatalf("failed to describe ASGs: %v", err)
		}

		for _, asg := range asgs.AutoScalingGroups {
			name := *asg.AutoScalingGroupName
			if !asgPattern.MatchString(name) || !strings.Contains(name, logicalName) {
				continue
			}

			env := extractEnv(name)
			downCap, ok := scheduleRules[env]
			if !ok {
				log.Printf("Skipping ASG %s: no downscale rule for env: %s", name, env)
				continue
			}

			originalCap := int32(len(asg.Instances))
			originalMin := *asg.MinSize
			originalMax := *asg.MaxSize

			if verbose {
				fmt.Printf("[Match] ASG: %s | Env: %s | DownCap: %d | RevertCap: %d | Cron: %s\n",
					name, env, downCap, originalCap, cronExpr)
			}

			if dryRun {
				continue
			}

			scheduleBase := name + "-scale-schedule"

			// Downscale: use env-specific rules
			_, err := svc.PutScheduledUpdateGroupAction(context.TODO(), &autoscaling.PutScheduledUpdateGroupActionInput{
				AutoScalingGroupName: &name,
				ScheduledActionName:  aws.String(scheduleBase + "-down"),
				Recurrence:           aws.String(cronExpr),
				MinSize:              aws.Int32(downCap),
				MaxSize:              aws.Int32(downCap),
				DesiredCapacity:      aws.Int32(downCap),
			})
			if err != nil {
				log.Printf("Failed downscale for %s: %v", name, err)
			} else if verbose {
				fmt.Printf("Scheduled downscale (min/max/desired = %d) for ASG: %s\n", downCap, name)
			}

			// Revert logic stays untouched
			revertCron := calculateRevertCron(cronExpr, durationMinutes)
			_, err = svc.PutScheduledUpdateGroupAction(context.TODO(), &autoscaling.PutScheduledUpdateGroupActionInput{
				AutoScalingGroupName: &name,
				ScheduledActionName:  aws.String(scheduleBase + "-revert"),
				Recurrence:           aws.String(revertCron),
				MinSize:              aws.Int32(originalMin),
				MaxSize:              aws.Int32(originalMax),
				DesiredCapacity:      aws.Int32(originalCap),
			})
			if err != nil {
				log.Printf("Failed revert for %s: %v", name, err)
			} else if verbose {
				fmt.Printf("Scheduled revert (recurring) for ASG: %s | RevertCron: %s\n", name, revertCron)
			}
		}
	},
}

func extractEnv(name string) string {
	parts := strings.Split(name, "-")
	if len(parts) >= 3 {
		return strings.ToLower(parts[2])
	}
	return ""
}

func calculateRevertCron(base string, offset int) string {
	parts := strings.Fields(base)
	if len(parts) != 5 {
		return base // fallback
	}

	minute, err1 := strconv.Atoi(parts[0])
	hour, err2 := strconv.Atoi(parts[1])
	if err1 != nil || err2 != nil {
		return base
	}

	totalMinutes := hour*60 + minute + offset
	hour = (totalMinutes / 60) % 24
	minute = totalMinutes % 60

	parts[0] = fmt.Sprintf("%d", minute)
	parts[1] = fmt.Sprintf("%d", hour)
	return strings.Join(parts, " ")
}

func init() {
	applyCmd.Flags().StringVar(&logicalName, "logical-name", "", "Substring pattern to match ASG names")
	applyCmd.Flags().StringVar(&cronExpr, "cron-expression", "", "Cron expression for downscale schedule")
	applyCmd.Flags().IntVar(&durationMinutes, "duration", 15, "Duration in minutes before reverting to original capacity")
	applyCmd.Flags().BoolVar(&dryRun, "dry-run", false, "Dry run only")
	applyCmd.Flags().BoolVar(&verbose, "verbose", false, "Verbose output")

	applyCmd.MarkFlagRequired("logical-name")
	applyCmd.MarkFlagRequired("cron-expression")

	asgScheduleCmd.AddCommand(applyCmd)
	rootCmd.AddCommand(asgScheduleCmd)
}
