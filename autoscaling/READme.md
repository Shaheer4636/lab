
# AWS ASG Scheduler CLI

This CLI tool is used to **schedule automatic scale-down and revert actions** on AWS Auto Scaling Groups (ASGs) based on environment-specific rules. It targets ASGs matching naming conventions and applies cron-based scaling actions for cost-saving during nights and weekends.

---

## Features

- Automatically schedules **scale-down** based on predefined rules per environment (e.g., `prod`, `uat`, `stage`)
- Automatically schedules a **revert** action after a specified duration
- Supports **dry-run** and **verbose** output for safe experimentation
- Uses AWS SDK v2 and supports profiles/regions via your AWS CLI setup

---

## Environment Rules

The scale-down rules are hardcoded per environment:

| Environment | Scaled Down Capacity |
|------------|----------------------|
| prod       | 2                    |
| uat        | 1                    |
| stage      | 0                    |

---

## Installation



## Usage

The main command is `asg-schedule apply`.

### Basic Example

```bash
./asg-scheduler asg-schedule apply \
  --logical-name "stage" \
  --cron-expression "0 22 * * 5" \
  --duration 540 \
  --verbose
```

### Explanation

| Flag                | Description                                                                 |
| ------------------- | --------------------------------------------------------------------------- |
| `--logical-name`    | Substring used to match ASG names (e.g. `epro` will match `epro-dev-v1`)    |
| `--cron-expression` | Cron format for scale-down action (e.g., `0 22 * * 5` = every Friday 10 PM) |
| `--duration`        | Minutes after which to revert the scaling (e.g., `540` = 9 hours)           |
| `--dry-run`         | Runs the logic but doesn’t apply changes                                    |
| `--verbose`         | Prints detailed match and scheduling information                            |

---

## Dry Run Example

```bash
./asg-scheduler asg-schedule apply \
  --logical-name "epro" \
  --cron-expression "0 22 * * 5" \
  --duration 540 \
  --dry-run \
  --verbose
```

This will show which ASGs would be modified without actually creating scheduled actions.

---

##  ASG Name Matching Logic

The ASG name should follow this regex pattern:

```
^epro-[a-zA-Z0-9-]+-(dev|qa|uat|stage|prod|train|demo)-v[0-9]+$
```

Examples:

* `epro-order-prod-v3` ok
* `epro-billing-uat-v1` ok
* `random-asg-prod` not ok

