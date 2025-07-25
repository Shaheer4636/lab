#!/bin/bash

echo "Installing AWS SSM Agent..."

# Define region (change if needed)
REGION="us-east-1"

# Step 1: Download and install
sudo yum install -y https://s3.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm

# Step 2: Enable and start the agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Step 3: Verify status
echo "Checking SSM Agent status..."
sudo systemctl status amazon-ssm-agent --no-pager

echo "✅ SSM Agent installation complete."
