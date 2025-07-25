#!/bin/bash

set -e

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

echo "📁 Backing up $SSHD_CONFIG to $BACKUP"
sudo cp "$SSHD_CONFIG" "$BACKUP"

echo "🧹 Removing broken Match User ec2-user block (if exists)..."
sudo sed -i '/^Match User ec2-user/,+5d' "$SSHD_CONFIG"

echo "🔧 Setting global SSH password auth config..."
sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG" || echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG" || echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"

echo "🧪 Validating SSH config..."
if sudo sshd -t; then
    echo "✅ SSH config is valid."
    echo "🔁 Restarting sshd..."
    sudo systemctl restart sshd
    echo "✅ SSHD restarted. SFTP on port 22 should now work for ec2-user."
else
    echo "❌ Invalid SSH config. Restore from backup: $BACKUP"
fi
