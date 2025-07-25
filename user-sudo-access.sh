#!/bin/bash

set -e

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

echo "📁 Backing up $SSHD_CONFIG to $BACKUP"
sudo cp "$SSHD_CONFIG" "$BACKUP"

echo "🧹 Removing all Match blocks from SSH config..."
sudo sed -i '/^Match /,$d' "$SSHD_CONFIG"

echo "🔧 Setting password auth options globally..."
sudo sed -i 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
sudo sed -i 's/^#\?\s*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"

# Append if missing
grep -q "^PasswordAuthentication" "$SSHD_CONFIG" || echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
grep -q "^ChallengeResponseAuthentication" "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSHD_CONFIG"
grep -q "^UsePAM" "$SSHD_CONFIG" || echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"

echo "🔐 Setting password for ec2-user..."
echo "ec2-user:ARKANSAS@123" | sudo chpasswd

echo "🧪 Validating SSH config..."
if sudo sshd -t; then
    echo "✅ SSH config is valid."
    echo "🔁 Restarting sshd..."
    sudo systemctl restart sshd
    echo "✅ DONE: You can now connect using SFTP on port 22 with username 'ec2-user' and password 'ARKANSAS@123'"
else
    echo "❌ Invalid SSH config. Restore from backup: $BACKUP"
fi
