#!/bin/bash

echo "🔐 Setting password for ec2-user..."
echo "ec2-user:ARKANSAS@123" | sudo chpasswd

SSHD_CONFIG="/etc/ssh/sshd_config"
BAK="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

echo "📦 Backing up sshd_config to $BAK"
sudo cp "$SSHD_CONFIG" "$BAK"

echo "🔧 Updating SSH config to allow password login..."
# Ensure PasswordAuthentication is set to yes
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sudo sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
sudo sed -i 's/^#*UsePAM.*/UsePAM yes/' "$SSHD_CONFIG"

# Append if not found
grep -q "^PasswordAuthentication" "$SSHD_CONFIG" || echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONFIG"
grep -q "^ChallengeResponseAuthentication" "$SSHD_CONFIG" || echo "ChallengeResponseAuthentication no" | sudo tee -a "$SSHD_CONFIG"
grep -q "^UsePAM" "$SSHD_CONFIG" || echo "UsePAM yes" | sudo tee -a "$SSHD_CONFIG"

echo "🔁 Restarting sshd..."
sudo systemctl restart sshd

echo "✅ ec2-user can now connect via WinSCP using password: ARKANSAS@123"
