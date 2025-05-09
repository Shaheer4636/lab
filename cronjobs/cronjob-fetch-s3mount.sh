#!/bin/bash

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"

# Get EC2 instance ID via IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

# Fix: Match ANY fuse-based mount under /mnt/repository or /mnt/buyspeed-*
MOUNT_PATH=$(awk '$3 ~ "^fuse" && $2 ~ "^/mnt/" { print $2 }' /proc/mounts | grep -E '^/mnt/(repository|buyspeed-)' | head -n1)

# If no valid mount found, alert
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
    exit 1
fi

# Final verification of mount status
if grep -qs "$MOUNT_PATH" /proc/mounts; then
    exit 0  # ✅ Mount is active — silent
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
fi
