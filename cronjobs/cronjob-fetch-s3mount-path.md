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
tail -n 10 /var/log/s3_mount_monitor.log


```


** Expected Behaviour
1. Once the opsgenie notification is ack it will not be logged again
2. till the notification is closed, assigned, ack it will lot be alerted again.
