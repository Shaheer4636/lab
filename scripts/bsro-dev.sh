#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR='$(TARGET_DIR)'
APP_USER='$(APP_USER)'
ME="$(id -un)"   # user of the SSH connection (e.g., ec2-user)

echo "TARGET_DIR=$TARGET_DIR"
echo "APP_USER=$APP_USER"
echo "ME=$ME"

sudo mkdir -p "$TARGET_DIR"
sudo chown -R "$ME":"$APP_USER" "$TARGET_DIR"
sudo chmod -R g+rwX "$TARGET_DIR"
