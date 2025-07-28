#!/bin/bash

set -e

echo "[1/7] Installing required packages..."
yum install -y vsftpd openssl

echo "[2/7] Creating SSL certificate..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 3650 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=ftp.local"

echo "[3/7] Writing vsftpd config for implicit FTPS on port 990..."
cat > /etc/vsftpd/vsftpd-990.conf <<EOF
listen=YES
listen_ipv6=NO
ssl_enable=YES
implicit_ssl=YES
ssl_tlsv1=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
pam_service_name=vsftpd
user_sub_token=\$USER
local_root=/home/\$USER
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
EOF

echo "[4/7] Creating systemd override for vsftpd to use port 990 config..."
mkdir -p /etc/systemd/system/vsftpd.service.d
echo -e "[Service]\nExecStart=\nExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-990.conf" > /etc/systemd/system/vsftpd.service.d/override.conf

echo "[5/7] Adding ec2-user with defined password..."
echo "ec2-user:ARKANSAS@123" | chpasswd

echo "[6/7] Setting correct permissions on ec2-user home..."
chmod 755 /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user

echo "[7/7] Enabling firewall & SELinux exceptions (if applicable)..."
# open firewall port (for systems with firewalld)
if command -v firewall-cmd &> /dev/null; then
  firewall-cmd --add-port=990/tcp --permanent
  firewall-cmd --add-port=40000-40010/tcp --permanent
  firewall-cmd --reload
fi

# Allow through iptables (if no firewalld)
iptables -I INPUT -p tcp --dport 990 -j ACCEPT
iptables -I INPUT -p tcp --dport 40000:40010 -j ACCEPT

# Disable SELinux (or allow vsftpd through)
setsebool -P ftpd_full_access 1 || true

echo "[✓] Reloading systemd and restarting vsftpd..."
systemctl daemon-reload
systemctl restart vsftpd

echo "[✓] Verifying port..."
ss -tuln | grep 990

echo "✅ FTPS on port 990 ready. Connect with:"
echo "User: ec2-user"
echo "Pass: ARKANSAS@123"
