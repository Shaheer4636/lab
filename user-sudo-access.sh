#!/bin/bash

# Create the user and set password
useradd -m -s /bin/bash rahul
echo "rahul:rahul@liberty123!" | chpasswd

# Add user to sudo group
usermod -aG sudo rahul

# Set up SSH folder and permissions
mkdir -p /home/rahul/.ssh
chmod 700 /home/rahul/.ssh
touch /home/rahul/.ssh/authorized_keys
chmod 600 /home/rahul/.ssh/authorized_keys
chown -R rahul:rahul /home/rahul/.ssh

# Optional: Copy authorized_keys from current user (if needed)
# cp ~/.ssh/authorized_keys /home/rahul/.ssh/authorized_keys
# chown rahul:rahul /home/rahul/.ssh/authorized_keys

# Ensure SSH is enabled
systemctl enable ssh
systemctl start ssh

# Set full permissions on home directory
chmod 700 /home/rahul
chown -R rahul:rahul /home/rahul

echo "✅ User 'rahul' created with sudo and SSH access."
