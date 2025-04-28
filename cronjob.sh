#!/bin/bash

MOUNT_PATH="/mnt/buyspeed-arkansas-stage"
LOG_FILE="/var/log/s3_mount_monitor.log"
DEBUG_LOG="/tmp/cron_debug.log"
TIMESTAMP=$(/bin/date '+%Y-%m-%d %H:%M:%S')

# Function to log both to debug and main log if needed
log_debug() {
    echo "$TIMESTAMP: $1" >> "$DEBUG_LOG"
}

log_error() {
    echo "$TIMESTAMP: ERROR - $1" >> "$LOG_FILE"
    log_debug "ERROR - $1"
}

log_ok() {
    log_debug "OK - $1"
}

# Start Script
log_debug "Script started. Checking mount: $MOUNT_PATH"

# Check if mount point is active
if /bin/mountpoint -q "$MOUNT_PATH"; then
    log_ok "Mount point is active"
    exit 0
else
    log_error "Mount point is not active. Attempting one retry..."

    # Try to remount once
    /opt/aws/mountpoint-s3/bin/mount-s3 buyspeed-arkansas-stage "$MOUNT_PATH" --allow-delete >> "$DEBUG_LOG" 2>&1

    # Short wait to allow mount to complete
    sleep 2

    # Recheck
    if /bin/mountpoint -q "$MOUNT_PATH"; then
        log_debug "Remount succeeded"
        exit 0
    else
        log_error "Remount failed after retry"
        exit 1
    fi
fi
