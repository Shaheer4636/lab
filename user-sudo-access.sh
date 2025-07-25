#!/bin/bash

# Restrict ec2-user to SFTP only

echo "Setting up ec2-user for SFTP-only access..."

# Step 1: Prepare chroot directory
mkdir -p /home/ec2-user/uploads
chown root:root /home/ec2-user
chmod 755 /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user/uploads

# Step 2: Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)

# Step 3: Append Match block for ec2-user to sshd_config
cat <<EOF >> /etc/ssh/sshd_config

# SFTP-only restriction for ec2-user
Match User ec2-user
    ChrootDirectory /home/ec2-user
    ForceCommand internal-sftp
    AllowTCPForwarding no
    X11Forwarding no
EOF

# Step 4: Restart sshd
echo "Restarting sshd..."
systemctl restart sshd

echo "✅ ec2-user is now restricted to SFTP-only."
echo "SFTP directory: /uploads"
