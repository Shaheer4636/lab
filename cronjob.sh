#!/bin/bash

MOUNT_PATH="/mnt/buyspeed-arkansas-stage"
LOG_FILE="/var/log/s3_mount_monitor.log"
DEBUG_LOG="/tmp/cron_debug.log"
TIMESTAMP=$(/bin/date '+%Y-%m-%d %H:%M:%S')

echo "$TIMESTAMP: Script started" >> "$DEBUG_LOG"
echo "Checking mount path: $MOUNT_PATH" >> "$DEBUG_LOG"
echo "Running command: /bin/mountpoint -q $MOUNT_PATH" >> "$DEBUG_LOG"

if /bin/mountpoint -q "$MOUNT_PATH"; then
    echo "$TIMESTAMP: OK - $MOUNT_PATH is active" >> "$LOG_FILE"
    echo "$TIMESTAMP: Mount is active" >> "$DEBUG_LOG"
    exit 0
else
    mountpoint_exit_code=$?
    echo "$TIMESTAMP: ERROR - $MOUNT_PATH is not active (exit code: $mountpoint_exit_code)" >> "$LOG_FILE"
    echo "$TIMESTAMP: Mount is NOT active. Attempting to remount..." >> "$DEBUG_LOG"

    # Retry remount
    /opt/aws/mountpoint-s3/bin/mount-s3 buyspeed-arkansas-stage "$MOUNT_PATH" --allow-delete >> "$DEBUG_LOG" 2>&1

    # Wait briefly to allow remount
    sleep 5

    # Recheck if mount successful
    if /bin/mountpoint -q "$MOUNT_PATH"; then
        echo "$TIMESTAMP: SUCCESS - Remount of $MOUNT_PATH succeeded" >> "$LOG_FILE"
        echo "$TIMESTAMP: Remount succeeded" >> "$DEBUG_LOG"
        exit 0
    else
        echo "$TIMESTAMP: CRITICAL - Remount of $MOUNT_PATH FAILED" >> "$LOG_FILE"
        echo "$TIMESTAMP: Remount failed" >> "$DEBUG_LOG"
        exit 1
    fi
fi
