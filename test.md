#!/bin/bash

set -e

# Backup the original sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)

# Enable password authentication
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart ssh

echo "✅ SSH config updated: Password authentication enabled, root login disabled."
