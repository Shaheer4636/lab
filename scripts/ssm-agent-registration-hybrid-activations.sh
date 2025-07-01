#!/bin/bash

# === HYBRID ACTIVATION DETAILS ===
ACTIVATION_CODE="ktEk0a54vGgIPI/rGNTEG"
ACTIVATION_ID="6e432640-0502-4f7e-9200-c8ae1882f193"
REGION="us-east-2"

echo "[INFO] Removing Snap version if installed..."
sudo snap remove amazon-ssm-agent || true

echo "[INFO] Downloading and installing .deb version..."
cd /tmp
wget https://s3.amazonaws.com/amazon-ssm-us-east-2/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb

echo "[INFO] Registering instance with AWS Systems Manager..."
sudo amazon-ssm-agent -register -code "$ACTIVATION_CODE" -id "$ACTIVATION_ID" -region "$REGION"

echo "[INFO] Enabling and starting systemd service..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "[INFO] ✅ Done. Agent status:"
sudo systemctl status amazon-ssm-agent --no-pager
