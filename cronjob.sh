#!/bin/bash
MOUNT_PATH="/mnt/buyspeed-arkansas-stage"
LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(/bin/date '+%Y-%m-%d %H:%M:%S')

echo "$TIMESTAMP: Script executed" >> /tmp/cron_debug.log

if /bin/mountpoint -q "$MOUNT_PATH"; then
    /bin/echo "$TIMESTAMP: OK - $MOUNT_PATH is active" >> "$LOG_FILE"
    exit 0
else
    mountpoint_exit_code=$?
    /bin/echo "$TIMESTAMP: ERROR - $MOUNT_PATH is not active (mountpoint exit code: $mountpoint_exit_code)" >> "$LOG_FILE"
    exit 1
fi
