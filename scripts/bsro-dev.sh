#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR='$(TARGET_DIR)'
APP_USER='$(APP_USER)'
PIPELINE_USER='$(PIPELINE_USER)'

echo "TARGET_DIR=$TARGET_DIR"
echo "APP_USER=$APP_USER"
echo "PIPELINE_USER=$PIPELINE_USER"

sudo mkdir -p "$TARGET_DIR"
sudo chown -R "$PIPELINE_USER":"$APP_USER" "$TARGET_DIR"
sudo chmod -R g+rwX "$TARGET_DIR"
