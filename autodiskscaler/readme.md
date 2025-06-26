# AutoDiskScaler – Smart Cloud Disk Optimization Tool

**AutoDiskScaler** is a cloud-native DevOps tool written in Golang that helps reduce cloud storage costs by automatically detecting and optimizing idle EBS volumes (and in the future, Azure and GCP disks) during weekends or off-hours. It is built for teams and organizations who want to avoid paying for unused disks, while preserving data safety and automation.

---

## Purpose

Cloud environments often accumulate unused or underutilized disks — especially over weekends or non-production hours. AutoDiskScaler provides an automated, policy-driven solution to:

- Identify idle or unattached cloud volumes.
- Safely create snapshots before performing any action.
- Optionally detach or downsize volumes.
- Automate reattachment or restore on Monday.
- Save 20–40% in monthly disk storage costs.

---

## Key Features

| Feature                     | Description                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| Idle Disk Detection      | Scans for unattached or low-activity EBS volumes (based on tags and state). |
| Snapshot Safety          | Automatically creates snapshots before any optimization.                   |
| Weekend Scheduler        | Runs every Friday 6 PM – Monday 8 AM (customizable).                        |
| Tag Exclusion Rules      | Skip volumes with custom tags (e.g., `Keep=true`, `Prod=true`).             |
| Modular Golang Codebase  | Easy to extend and integrate with other tools.                              |
| Cost Reports (planned)   | Estimate and report cost savings for each weekend run.                     |
| Multi-cloud Support (soon) | Extendable for Azure and GCP disks.                                       |

---

## Flow

```text
+--------------------+
|   Cron Scheduler   |  <- Triggers every Friday and Monday
+--------+-----------+
         |
         v
+---------------------+
|   Volume Scanner     |  <- Detects idle EBS volumes
+--------+------------+
         |
         v
+---------------------+
| Snapshot & Optimize |  <- Takes snapshot, detaches or downsizes volumes
+--------+------------+
         |
         v
+---------------------+
|   Logging & Report   |  <- Logs actions, future reports cost savings
+---------------------+
