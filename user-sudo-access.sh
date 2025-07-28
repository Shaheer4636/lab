#!/bin/bash

set -e

echo ">>> [1] Install dependencies..."
yum install -y vsftpd openssl policycoreutils-python-utils

echo ">>> [2] Generate self-signed cert if missing..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=ec2"

echo ">>> [3] Create vsftpd config for port 990..."
cat > /etc/vsftpd/vsftpd-990.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES

ssl_enable=YES
implicit_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO

rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem

pam_service_name=vsftpd
EOF

echo ">>> [4] Create override to force vsftpd to use 990 config..."
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-990.conf
EOF

echo ">>> [5] Ensure user exists and password is set..."
useradd -m ec2-user || true
echo "ec2-user:ARKANSAS@123" | chpasswd

echo ">>> [6] Permissions..."
chmod 755 /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user

echo ">>> [7] SELinux rules (only if enabled)..."
setsebool -P ftpd_full_access 1 || true

echo ">>> [8] Open firewall ports..."
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --permanent --add-port=40000-40100/tcp || true
firewall-cmd --reload || true

echo ">>> [9] Restart and verify..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

sleep 2
echo ">>> [10] Checking port 990..."
ss -tuln | grep :990 && echo ">>> ✅ Port 990 is now listening." || echo ">>> ❌ Still NOT listening. Check journalctl -u vsftpd"
