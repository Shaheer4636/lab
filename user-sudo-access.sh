#!/bin/bash

set -e

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

echo "📁 Backing up $SSHD_CONFIG to $BACKUP"
sudo cp "$SSHD_CONFIG" "$BACKUP"

echo "🧹 Removing all Match blocks from SSH config..."
sudo sed -i '/^Match /,$d' "$SSHD_CONFIG"

echo "🔧 Setting global SSH password auth config..."
sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG" || echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG" || echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"

echo "🧪 Validating SSH config..."
if sudo sshd -t; then
    echo "✅ SSH config is valid."
    echo "🔁 Restarting sshd..."
    sudo systemctl restart sshd
    echo "✅ SSHD restarted. You can now connect via WinSCP on port 22 with password."
else
    echo "❌ SSH config still broken. Restore from: $BACKUP"
fi
