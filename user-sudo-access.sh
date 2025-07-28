#!/bin/bash
set -e

USER="ec2-user"
PASS="ARKANSAS@123"
PUBLIC_IP="3.82.115.255"  # <-- CHANGE TO YOUR EC2 PUBLIC IP

echo "[1] Installing vsftpd & SSL..."
yum install -y vsftpd openssl policycoreutils-python-utils firewalld
systemctl enable firewalld --now

echo "[2] Setting password for $USER..."
echo "$USER:$PASS" | chpasswd

echo "[3] Creating TLS certificate..."
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=US/ST=State/L=City/O=Example/CN=$PUBLIC_IP" \
  -keyout /etc/vsftpd/ssl/vsftpd.key \
  -out /etc/vsftpd/ssl/vsftpd.crt

echo "[4] Writing vsftpd.conf..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_port=990
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

ssl_enable=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
pasv_address=$PUBLIC_IP
pasv_addr_resolve=NO

ftpd_banner=Welcome to FTPS Server.
EOF

echo "[5] Whitelisting user in /etc/vsftpd/user_list..."
grep -q "^$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "[6] Setting correct permissions..."
chmod 755 /home/$USER
chown $USER:$USER /home/$USER

echo "[7] Configuring firewall..."
firewall-cmd --add-service=ftp --permanent
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=30000-30100/tcp --permanent
firewall-cmd --reload

echo "[8] Restarting vsftpd..."
systemctl restart vsftpd
systemctl status vsftpd --no-pager

echo "[✔] FTPS setup complete. Use the following settings in FileZilla or WinSCP:
Host: ftps://$PUBLIC_IP
Port: 990
Protocol: FTP over TLS (Implicit)
Username: $USER
Password: $PASS
Passive mode: Enabled
"
