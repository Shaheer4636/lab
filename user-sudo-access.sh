#!/bin/bash

set -e

echo "🔐 Setting password for ec2-user..."
echo "ec2-user:ARKANSAS@123" | sudo chpasswd

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_PATH="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

echo "📁 Backing up $SSHD_CONFIG to $BACKUP_PATH"
sudo cp "$SSHD_CONFIG" "$BACKUP_PATH"

echo "🔧 Updating SSH config to allow password login..."

# Set or append required settings
sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG" || echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG" || echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"

echo "🧪 Validating SSH config..."
if sudo sshd -t; then
    echo "✅ SSH config is valid."
    echo "🔁 Restarting sshd..."
    sudo systemctl restart sshd
    echo "✅ ec2-user can now connect via WinSCP using password: ARKANSAS@123"
else
    echo "❌ SSH config invalid. Restore from: $BACKUP_PATH"
fi
