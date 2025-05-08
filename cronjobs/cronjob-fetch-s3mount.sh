#!/bin/bash

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "$TIMESTAMP: Script started on $INSTANCE_ID" >> "$LOG_FILE"

# Auto-detect the S3 mount path (fuse.s3fs, under /mnt/)
MOUNT_PATH=$(mount | grep -E 'type fuse.s3fs' | awk '{print $3}' | grep -E '^/mnt/(repository|buyspeed-)' | head -n1)

# Debug: log detected mount path
echo "$TIMESTAMP: Detected mount path: $MOUNT_PATH" >> "$LOG_FILE"

# Safety check
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

# Check if the mount point is actually active
if /bin/mountpoint -q "$MOUNT_PATH"; then
    ALERT_MSG="$TIMESTAMP: OK - $MOUNT_PATH is mounted and active on instance $INSTANCE_ID."
else
    ALERT_MSG="$TIMESTAMP: ERROR - $MOUNT_PATH is NOT mounted on instance $INSTANCE_ID!"

    curl --fail --show-error -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"$ALERT_MSG\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-$(basename $MOUNT_PATH)\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\"
          }"
fi

echo "$ALERT_MSG" >> "$LOG_FILE"
