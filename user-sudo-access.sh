#!/bin/bash

set -e

echo ">>> Installing required packages..."
yum install -y vsftpd openssl firewalld policycoreutils-python-utils

echo ">>> Creating self-signed SSL certificate..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.key \
  -out /etc/ssl/private/vsftpd.pem \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/OU=FTPD/CN=$(hostname)"

echo ">>> Writing vsftpd.conf for Implicit TLS..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
ssl_enable=YES
implicit_ssl=YES
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.key
force_local_logins_ssl=YES
force_local_data_ssl=YES
ssl_tlsv1=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
EOF

echo ">>> Creating systemd override for port 990 config..."
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
EOF

echo ">>> Opening firewall ports..."
systemctl enable firewalld --now
firewall-cmd --permanent --add-port=990/tcp
firewall-cmd --permanent --add-port=40000-40100/tcp
firewall-cmd --reload

echo ">>> Enabling SELinux booleans (ignore if disabled)..."
setsebool -P ftpd_full_access 1 || true
setsebool -P allow_ftpd_anon_write 1 || true
setsebool -P allow_ftpd_use_cifs 1 || true

echo ">>> Ensuring ec2-user exists and has home dir..."
id ec2-user &>/dev/null || useradd ec2-user
mkdir -p /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user
chmod 755 /home/ec2-user
echo "ec2-user:ARKANSAS@123" | chpasswd

echo ">>> Reloading systemd and restarting vsftpd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

echo ">>> Verifying vsftpd is listening on port 990..."
ss -tuln | grep :990 && echo "SUCCESS: FTPS is listening on port 990!" || echo "FAIL: Port 990 not listening!"

echo ">>> DONE. Use FileZilla or WinSCP with:"
echo "- Host: Your EC2 Public IP"
echo "- Port: 990"
echo "- Protocol: FTPS (Implicit TLS)"
echo "- User: ec2-user"
echo "- Password: ARKANSAS@123"
