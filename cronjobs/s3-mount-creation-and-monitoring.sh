#!/bin/bash

########################
##VARIABLES FOR SCRIPT##
########################

# List of logs, the associated directory and the number of days to keep on the util server
utilLogPaths=("/opt/periscope/buyspeed/utils/etl/logs/" "/opt/periscope/buyspeed/utils/etl/logs/" "/opt/periscope/buyspeed/utils/etl/logs/runs/")
utilLogRegex=("etl-combined*" "etl-overflow*" "vendorCategoryUpdateJob*")
utilLogdestpath=("etl-combined" "etl-overflow" "vendorCategoryUpdateJob")
utilLogAge=("1" "1" "1")

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"

#############
##FUNCTIONS##
#############

function backup_utillogs() {
  for i in ${!utilLogPaths[@]}; do
    logpath=${utilLogPaths[$i]}
    regex=${utilLogRegex[$i]}
    maxAge=${utilLogAge[$i]}
    destpath=${utilLogdestpath[$i]}
    YEAR=$(date +%Y)
    MONTH=$(date +%m)
    DAY=$(date +%d)
    destfilepath="s3://buyspeed-phila-uat/logs/util/$destpath/$YEAR/$MONTH/$DAY"
    find "$logpath" -maxdepth 1 -name "$regex" -type f -mtime +"$maxAge" -exec bash -c '
      destfilepath="$1"
      for file do
        if [ -f "$file" ]; then
          base=$(basename "$file")
          aws s3 mv "$file" "$destfilepath/$base"
          echo "LOG BACKED UP: $destfilepath/$base"
        fi
      done' _ "$destfilepath" {} +
  done
}

function timestamp() {
  echo 'CHECKING DATE & TIME...'
  datetime=$(date +"%Y-%m-%d-%T")
  echo $datetime
}

function check_s3_mount() {
  # Get EC2 instance ID via IMDSv2
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)

  # Match ANY fuse-based mount under /mnt/repository or /mnt/buyspeed-*
  MOUNT_PATH=$(awk '$3 ~ "^fuse" && $2 ~ "^/mnt/" { print $2 }' /proc/mounts | grep -E '^/mnt/(repository|buyspeed-)' | head -n1)

  if [ -z "$MOUNT_PATH" ]; then
    ALERT_MSG="$TIMESTAMP: ERROR - No S3 mount found on instance $INSTANCE_ID!"
    echo "$ALERT_MSG" >> "$LOG_FILE"

    curl -s -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"[EC2: $INSTANCE_ID] No S3 mount found\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-none\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\",
            \"entity\": \"$INSTANCE_ID\",
            \"details\": {
              \"InstanceId\": \"$INSTANCE_ID\",
              \"MountPath\": \"None\"
            }
          }"
    return 1
  fi

  # Verify if mount is still active
  if grep -qs "$MOUNT_PATH" /proc/mounts; then
    return 0  # ✅ Mount is active — silent
  else
    MOUNT_NAME=$(basename "$MOUNT_PATH")
    ALERT_MSG="$TIMESTAMP: ERROR - $MOUNT_PATH is NOT mounted on instance $INSTANCE_ID!"
    echo "$ALERT_MSG" >> "$LOG_FILE"

    curl -s -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"[EC2: $INSTANCE_ID] Mount $MOUNT_PATH is NOT active\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-$MOUNT_NAME\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\",
            \"entity\": \"$INSTANCE_ID\",
            \"details\": {
              \"InstanceId\": \"$INSTANCE_ID\",
              \"MountPath\": \"$MOUNT_PATH\"
            }
          }"
    return 2
  fi
}

###############
##MAIN SCRIPT##
###############

timestamp
check_s3_mount
backup_utillogs
