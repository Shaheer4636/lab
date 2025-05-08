#!/bin/bash

LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
OPS_API_KEY="30c08e31-8dba-4df4-a1a1-fd28316d0d28"
OPSGENIE_URL="https://api.opsgenie.com/v2/alerts"

# Get EC2 instance ID using IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

echo "$TIMESTAMP: Script started on instance $INSTANCE_ID" >> "$LOG_FILE"

# Auto-detect S3 mount path
MOUNT_PATH=$(mount | grep -E 'type fuse.s3fs' | awk '{print $3}' | grep -E '^/mnt/(repository|buyspeed-)' | head -n1)

echo "$TIMESTAMP: Detected mount path: $MOUNT_PATH" >> "$LOG_FILE"
echo "$TIMESTAMP: Detected instance ID: $INSTANCE_ID" >> "$LOG_FILE"

# Check for mount path failure
if [ -z "$MOUNT_PATH" ]; then
    ALERT_MSG="$TIMESTAMP: ERROR - No S3 mount found under /mnt/ on instance $INSTANCE_ID!"
    echo "$ALERT_MSG" >> "$LOG_FILE"

    curl --fail --show-error -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"[EC2: $INSTANCE_ID] No S3 mount found on this instance\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-none\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\",
            \"details\": {
              \"InstanceId\": \"$INSTANCE_ID\",
              \"MountPath\": \"None\"
            }
          }"
    exit 1
fi

# Check if mount is active
if /bin/mountpoint -q "$MOUNT_PATH"; then
    ALERT_MSG="$TIMESTAMP: OK - $MOUNT_PATH is mounted and active on instance $INSTANCE_ID."
else
    ALERT_MSG="$TIMESTAMP: ERROR - $MOUNT_PATH is NOT mounted on instance $INSTANCE_ID!"

    curl --fail --show-error -X POST "$OPSGENIE_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: GenieKey $OPS_API_KEY" \
      -d "{
            \"message\": \"[EC2: $INSTANCE_ID] Mount $MOUNT_PATH is NOT available\",
            \"alias\": \"s3-mount-check-$INSTANCE_ID-$(basename $MOUNT_PATH)\",
            \"description\": \"$ALERT_MSG\",
            \"priority\": \"P2\",
            \"source\": \"$INSTANCE_ID\",
            \"details\": {
              \"InstanceId\": \"$INSTANCE_ID\",
              \"MountPath\": \"$MOUNT_PATH\"
            }
          }"
fi

echo "$ALERT_MSG" >> "$LOG_FILE"
