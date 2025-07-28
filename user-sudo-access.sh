#!/bin/bash

echo "🔁 Creating FTP-safe clone of ec2-user..."

# Create new user
useradd ftp-ec2 -m -s /bin/bash
echo "ftp-ec2:ARKANSAS@123" | chpasswd

# Set home permissions
chown ftp-ec2:ftp-ec2 /home/ftp-ec2
chmod 755 /home/ftp-ec2

# Whitelist for vsftpd
touch /etc/vsftpd/user_list
grep -qxF "ftp-ec2" /etc/vsftpd/user_list || echo "ftp-ec2" >> /etc/vsftpd/user_list

# Restart service
systemctl restart vsftpd

echo "✅ New FTP user created: ftp-ec2 / ARKANSAS@123"
