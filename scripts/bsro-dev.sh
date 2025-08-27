#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR='$(TARGET_DIR)'
ME="$(id -un)"   # e.g., ec2-user

echo "ME=$ME"
echo "TARGET_DIR=$TARGET_DIR"

sudo mkdir -p "$TARGET_DIR"
sudo chown -R "$ME":"$ME" "$TARGET_DIR"
sudo find "$TARGET_DIR" -type d -exec chmod 755 {} +
sudo find "$TARGET_DIR" -type f -exec chmod 644 {} +
