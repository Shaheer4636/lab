#!/bin/bash
MOUNT_PATH="/mnt/buyspeed-arkansas-stage"
LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(/bin/date '+%Y-%m-%d %H:%M:%S')

echo "$TIMESTAMP: Script started" >> /tmp/cron_debug.log
echo "Checking mount path: $MOUNT_PATH" >> /tmp/cron_debug.log
echo "Running command: /bin/mountpoint -q $MOUNT_PATH" >> /tmp/cron_debug.log

if /bin/mountpoint -q "$MOUNT_PATH"; then
    echo "$TIMESTAMP: OK - $MOUNT_PATH is active" >> "$LOG_FILE"
    echo "$TIMESTAMP: Mount is active" >> /tmp/cron_debug.log
else
    mountpoint_exit_code=$?
    echo "$TIMESTAMP: ERROR - $MOUNT_PATH is not active (exit code: $mountpoint_exit_code)" >> "$LOG_FILE"
    echo "$TIMESTAMP: Mount is NOT active" >> /tmp/cron_debug.log
fi
