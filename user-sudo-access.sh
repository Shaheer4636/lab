#!/bin/bash
set -e

# Install vsftpd
yum install -y vsftpd openssl

# Create SSL cert if missing
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=$(hostname)" \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem

# Set FTP password for ec2-user
echo "ARKANSAS@123" | passwd ec2-user --stdin

# Backup and configure vsftpd for implicit TLS
cat > /etc/vsftpd/vsftpd-990.conf <<EOF
listen=YES
listen_ipv6=NO

ssl_enable=YES
implicit_ssl=YES
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO

ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES

anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
pam_service_name=vsftpd
EOF

# Create systemd override
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-990.conf
EOF

# Reload and enable
systemctl daemon-reload
systemctl restart vsftpd
systemctl enable vsftpd

# Allow firewall port 990
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --reload || true

echo "✅ FTPS server is ready on port 990 for ec2-user. Use password: ARKANSAS@123"
