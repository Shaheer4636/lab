#!/bin/bash

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "$TIMESTAMP: Script started on $INSTANCE_ID" >> "$LOG_FILE"

# Auto-detect the S3 mount path (only one match expected)
MOUNT_PATH=$(mount | awk '$5 ~ /^fuse/ && $3 ~ /^\/mnt\// {print $3}' | grep -E '/mnt/(repository|buyspeed-)')

# Safety: check if we found a mount path at all
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
