#!/bin/bash
set -e

# Set these as needed
USER="ec2-user"
PASS="ARKANSAS@123"
PUBLIC_IP="3.82.115.255"  # Replace with your EC2 public IP

echo "[1] Setting password for $USER..."
echo "$USER:$PASS" | chpasswd

echo "[2] Installing required packages..."
yum install -y vsftpd openssl policycoreutils-python-utils

echo "[3] Creating TLS cert (self-signed)..."
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=US/ST=State/L=City/O=Org/OU=IT/CN=$PUBLIC_IP" \
  -keyout /etc/vsftpd/ssl/vsftpd.key \
  -out /etc/vsftpd/ssl/vsftpd.crt

echo "[4] Configuring vsftpd..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

ssl_enable=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

force_local_data_ssl=YES
force_local_logins_ssl=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
pasv_address=$PUBLIC_IP
pasv_addr_resolve=NO

user_sub_token=\$USER
local_root=/home/\$USER
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

ftpd_banner=FTPS Active
EOF

echo "[5] Whitelisting $USER for login..."
grep -q "^$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "[6] Setting permissions..."
chmod 755 /home/$USER
chown $USER:$USER /home/$USER

echo "[7] Opening firewall ports..."
firewall-cmd --add-service=ftp --permanent
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=30000-30100/tcp --permanent
firewall-cmd --reload

echo "[8] Enabling & restarting vsftpd..."
systemctl enable vsftpd
systemctl restart vsftpd

echo "[✔] FTPS setup complete for $USER. Connect using FTPS on port 990 with passive mode enabled."
