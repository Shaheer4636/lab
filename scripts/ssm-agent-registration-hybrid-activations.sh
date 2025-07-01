#!/bin/bash

# === HYBRID ACTIVATION DETAILS ===
ACTIVATION_CODE="ktEk0a54vGgIPI/rGNTEG"
ACTIVATION_ID="6e432640-0502-4f7e-9200-c8ae1882f193"
REGION="us-east-2"

echo "[INFO] Installing Amazon SSM Agent (Snap)..."
sudo snap install amazon-ssm-agent --classic

echo "[INFO] Registering with AWS Systems Manager..."
sudo /snap/bin/amazon-ssm-agent -register -code "$ACTIVATION_CODE" -id "$ACTIVATION_ID" -region "$REGION"

echo "[INFO] Starting amazon-ssm-agent Snap service..."
sudo snap start amazon-ssm-agent

echo "[INFO] ✅ Done. Status of agent:"
sudo snap services amazon-ssm-agent
