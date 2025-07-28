#!/bin/bash

set -e

USER="ec2-user"
PASS="ARKANSAS@123"
HOME="/home/$USER"

echo "🔧 Ensuring user '$USER' exists and has correct shell..."
id $USER >/dev/null 2>&1 || useradd -m -s /bin/bash $USER
usermod -s /bin/bash $USER

echo "🔐 Setting password for '$USER'..."
echo "$USER:$PASS" | chpasswd

echo "📁 Ensuring home directory exists and is owned correctly..."
mkdir -p "$HOME"
chown $USER:$USER "$HOME"
chmod 755 "$HOME"

echo "⚙️ Ensuring vsftpd allows writable home (chroot safe)..."
grep -q "^allow_writeable_chroot=YES" /etc/vsftpd/vsftpd.conf || echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf

echo "👤 Ensuring user is in allowed list..."
touch /etc/vsftpd/user_list
grep -qxF "$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd

echo "✅ FTPS login for '$USER' on port 990 should now work!"
