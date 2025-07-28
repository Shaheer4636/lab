#!/bin/bash

set -e

echo "🔧 Checking vsftpd is installed..."
yum install -y vsftpd openssl

echo "🛠 Updating vsftpd.conf to enable TLS 1.2 and 1.3..."

cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
listen_port=990

anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
ftpd_banner=Welcome to Secure FTPS.
chroot_local_user=YES
allow_writeable_chroot=YES

rsa_cert_file=/etc/ssl/certs/ftp-cert.pem
rsa_private_key_file=/etc/ssl/private/ftp-key.pem

ssl_enable=YES
force_local_logins_ssl=YES
force_local_data_ssl=YES

ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
EOF

echo "✅ Restarting vsftpd..."
systemctl restart vsftpd

echo "✅ TLS 1.2 and 1.3 are now enabled for FTPS on port 990."
