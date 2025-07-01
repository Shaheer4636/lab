#!/bin/bash

# === HYBRID ACTIVATION DETAILS ===
ACTIVATION_CODE="ktEk0a54vGgIPI/rGNTEG"
ACTIVATION_ID="6e432640-0502-4f7e-9200-c8ae1882f193"
REGION="us-east-2"

echo "[INFO] Removing Snap version (if exists)..."
sudo snap remove amazon-ssm-agent || true

echo "[INFO] Downloading latest .deb SSM Agent package..."
cd /tmp
curl -O https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/debian_amd64/amazon-ssm-agent.deb

echo "[INFO] Installing SSM Agent via dpkg..."
sudo dpkg -i amazon-ssm-agent.deb

echo "[INFO] Registering instance with AWS Systems Manager..."
sudo amazon-ssm-agent -register -code "$ACTIVATION_CODE" -id "$ACTIVATION_ID" -region "$REGION"

echo "[INFO] Enabling and starting amazon-ssm-agent service..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl restart amazon-ssm-agent

echo "[INFO] ✅ Done. Agent status:"
sudo systemctl status amazon-ssm-agent --no-pager
