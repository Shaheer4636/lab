#!/bin/bash

set -e

USERNAME="jacob"
PASSWORD="jacob@newlibertytee123!"

# Create the user with home directory
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
  echo "${USERNAME}:${PASSWORD}" | chpasswd
  echo "User '$USERNAME' created."
else
  echo "User '$USERNAME' already exists."
fi

# Add to sudo group
usermod -aG sudo "$USERNAME"
echo "User '$USERNAME' added to sudo group."

# Prepare SSH directory
SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
echo "SSH directory prepared for user '$USERNAME'."

# Modify /etc/ssh/sshd_config to allow password auth and user
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup the file
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

# Enable password authentication
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"

# Restart SSH service
echo "Restarting SSH service..."
systemctl restart sshd

echo "User '$USERNAME' is ready and can now access the server via SSH using password."
