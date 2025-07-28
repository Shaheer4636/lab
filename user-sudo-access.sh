#!/bin/bash
set -e

USER="ec2-user"
PASS="ARKANSAS@123"
PUBLIC_IP="3.82.115.255"  # Replace with your real EC2 public IP

echo "[1] Installing required packages..."
yum install -y vsftpd openssl policycoreutils-python-utils firewalld
systemctl enable firewalld --now

echo "[2] Resetting password for $USER..."
echo "$USER:$PASS" | chpasswd
usermod -s /bin/bash $USER
chmod 755 /home/$USER
chown $USER:$USER /home/$USER

echo "[3] Creating TLS certificate..."
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/vsftpd/ssl/vsftpd.key \
  -out /etc/vsftpd/ssl/vsftpd.crt \
  -subj "/C=US/ST=NA/L=NA/O=FTPS/CN=$PUBLIC_IP"

echo "[4] Writing clean vsftpd config..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
listen_port=990
ssl_enable=YES
implicit_ssl=YES
require_ssl_reuse=NO

rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key

ssl_tlsv1=NO
ssl_tlsv1_1=NO
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
ssl_ciphers=HIGH

local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

force_local_logins_ssl=YES
force_local_data_ssl=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
pasv_address=$PUBLIC_IP
pasv_addr_resolve=NO

ftpd_banner=Welcome to secure FTPS.
EOF

echo "[5] Whitelisting ec2-user for login..."
touch /etc/vsftpd/user_list
grep -qxF "$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "[6] Opening firewall ports..."
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=30000-30100/tcp --permanent
firewall-cmd --reload

echo "[7] Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "[✔] FTPS server is ready at $PUBLIC_IP on port 990 using TLSv1.2/v1.3"
echo "Use username: $USER and password: $PASS with Implicit TLS and Passive Mode"
