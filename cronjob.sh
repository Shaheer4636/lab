#!/bin/bash

MOUNT_PATH="/mnt/buyspeed-arkansas-stage"
LOG_FILE="/var/log/s3_mount_monitor.log"
TIMESTAMP=$(/bin/date '+%Y-%m-%d %H:%M:%S') # Using full path for date

# Check if the mount point is active (-q is quiet, exits 0 if mountpoint, non-zero otherwise)
if /bin/mountpoint -q "$MOUNT_PATH"; then
    /bin/echo "$TIMESTAMP: OK - $MOUNT_PATH is active" >> "$LOG_FILE"
    exit 0 # Exit with success status (0 indicates mount is active)
else
    mountpoint_exit_code=$?
    /bin/echo "$TIMESTAMP: ERROR - $MOUNT_PATH is not active (mountpoint exit code: $mountpoint_exit_code)" >> "$LOG_FILE"
    exit 1 # Exit with failure status (non-zero indicates mount is not active)
fi
