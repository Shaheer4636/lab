# S3 Mount Monitoring Cron Setup Guide

This guide documents how to configure and test a cron-based monitoring script that checks S3 bucket mounts on EC2 instances and sends alerts to OpsGenie if the mount is lost.

---

## Overview

* **Script name**: `s3_mount_monitor.sh`
* **Purpose**: Detect if an S3 mount is missing and alert via OpsGenie.
* **Mount paths covered**: `/mnt/repository`, `/mnt/buyspeed-*`
* **Logs**: `/var/log/s3_mount_monitor.log`
* **Alerting**: OpsGenie REST API (via `curl`)

---

## Script Location & Permissions

1. **Create the script**:

```bash
sudo nano /usr/local/bin/s3_mount_monitor.sh
```

2. **Paste the script** (provided below).

3. **Make it executable**:

```bash
sudo chmod +x /usr/local/bin/s3_mount_monitor.sh
```

---

##  Add Cronjob

To run the script every 5 minutes:

```bash
sudo crontab -e
```

Add the following line:

```bash
*/5 * * * * /usr/local/bin/s3_mount_monitor.sh
```

Save and exit.

---

##  How to Test the Script

### 1. **Manual Test**

```bash
sudo /usr/local/bin/s3_mount_monitor.sh
```

Check logs:

```bash
tail -n 10 /var/log/s3_mount_monitor.log
```

### 2. **Simulate Mount Failure**

```bash
sudo umount -l /mnt/repository
```

Then run:

```bash
sudo /usr/local/bin/s3_mount_monitor.sh
```

An alert should be sent to OpsGenie.

### 3. **Remount** (if needed)

```bash
sudo s3fs your-bucket-name /mnt/repository -o allow_other -o iam_role=auto
```

---

## Script Logic Summary

* Gets EC2 instance ID.
* Auto-detects S3 mount path (repository or buyspeed-\*).
* If no path found or mount is not active, sends alert to OpsGenie.
* Logs status to `/var/log/s3_mount_monitor.log`.

---

## OpsGenie Integration Notes

* Alerts are sent to OpsGenie using a unique alias per instance and mount.
* Use aliases like: `s3-mount-check-i-0abc123-repository` to prevent duplicates.
* Deduplication relies on OpsGenie's alert alias logic.
* Alerts must be manually closed or auto-closed via OpsGenie rules (optional).

---

## Full Script

```bash
#!/bin/bash

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "$TIMESTAMP: Script started on $INSTANCE_ID" >> "$LOG_FILE"

# Auto-detect the S3 mount path (only one match expected)
MOUNT_PATH=$(mount | awk '$5 ~ /^fuse/ && $3 ~ /^\/mnt\//' | awk '{print $3}' | grep -E '/mnt/(repository|buyspeed-)')

if [ -z "$MOUNT_PATH" ]; then
    ALERT_MSG="$TIMESTAMP: ERROR - No S3 mount found under /mnt/ on instance $INSTANCE_ID!"
    echo "$ALERT_MSG" >> "$LOG_FILE"

    curl --fail --show-error -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"$ALERT_MSG\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-none\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\"
          }"
    exit 1
fi

# Actual mountpoint check
if /bin/mountpoint -q "$MOUNT_PATH"; then
    ALERT_MSG="$TIMESTAMP: OK - $MOUNT_PATH is mounted and active on instance $INSTANCE_ID."
else
    ALERT_MSG="$TIMESTAMP: ERROR - $MOUNT_PATH is NOT mounted on instance $INSTANCE_ID!"

    curl --fail --show-error -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"$ALERT_MSG\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-$MOUNT_PATH\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\"
          }"
fi

echo "$ALERT_MSG" >> "$LOG_FILE"
```
