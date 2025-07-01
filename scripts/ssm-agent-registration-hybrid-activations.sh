#!/bin/bash

# === HYBRID ACTIVATION DETAILS ===
# this is one time code that is why putting here does not create any harm
ACTIVATION_CODE="ktEk0a54vGgIPI/rGNTEG"
ACTIVATION_ID="6e432640-0502-4f7e-9200-c8ae1882f193"
REGION="us-east-2"

echo "[INFO] Installing Amazon SSM Agent if not already installed..."

# Install SSM Agent (Snap for Ubuntu)
if ! systemctl status amazon-ssm-agent &> /dev/null; then
    sudo snap install amazon-ssm-agent --classic
fi

echo "[INFO] Registering instance with AWS Systems Manager..."
sudo amazon-ssm-agent -register -code "$ACTIVATION_CODE" -id "$ACTIVATION_ID" -region "$REGION"

echo "[INFO] Enabling and starting amazon-ssm-agent service..."
sudo systemctl enable amazon-ssm-agent
sudo systemctl restart amazon-ssm-agent

echo "[INFO] ✅ Done. Status of amazon-ssm-agent:"
sudo systemctl status amazon-ssm-agent --no-pager
