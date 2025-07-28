#!/bin/bash

# Install vsftpd and OpenSSL
yum install -y vsftpd openssl

# Generate SSL Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/vsftpd.key \
-out /etc/ssl/certs/vsftpd.crt \
-subj "/C=US/ST=FTP/L=Server/O=SelfSigned/OU=FTPD/CN=$(hostname)"

# Backup existing config
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

# Write new vsftpd.conf
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES

# Passive mode
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
pasv_address=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# SSL settings
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key

# FTPS implicit
implicit_ssl=YES
listen_port=990
EOF

# Ensure ec2-user is allowed
sed -i '/^ec2-user/d' /etc/vsftpd/user_list
echo "ec2-user" >> /etc/vsftpd/user_list
echo "ec2-user" >> /etc/vsftpd/ftpusers

# Set password (optional override)
echo -e "ARKANSAS@123\nARKANSAS@123" | passwd ec2-user

# Fix permissions
chmod 600 /etc/ssl/private/vsftpd.key
chown root:root /etc/ssl/private/vsftpd.key

# Open firewall ports
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=40000-40010/tcp --permanent
firewall-cmd --reload

# Restart service
systemctl restart vsftpd
systemctl enable vsftpd

echo "✅ FTPS server ready on port 990 for ec2-user (pass: ARKANSAS@123)"
