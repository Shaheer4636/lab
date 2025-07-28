#!/bin/bash

set -e

echo "🔧 Ensuring required packages are installed..."
yum install -y vsftpd openssl firewalld policycoreutils-python-utils

echo "🔐 Generating self-signed TLS cert for FTPS (if not exists)..."
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

if [ ! -f /etc/ssl/certs/ftp-cert.pem ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/ftp-key.pem \
    -out /etc/ssl/certs/ftp-cert.pem \
    -subj "/C=PK/ST=Punjab/L=Mianwali/O=MyCompany/OU=IT/CN=$(hostname)"
  chmod 600 /etc/ssl/private/ftp-key.pem
  chmod 644 /etc/ssl/certs/ftp-cert.pem
fi

echo "⚙️ Updating vsftpd.conf..."
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
listen_port=990
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
use_localtime=YES
dirmessage_enable=YES
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
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
EOF

echo "🔓 Allowing FTPS ports via firewall..."
firewall-cmd --permanent --add-port=990/tcp
firewall-cmd --permanent --add-port=30000-30100/tcp
firewall-cmd --reload

echo "🔐 Configuring SELinux (if enabled)..."
setsebool -P allow_ftpd_full_access 1
semanage port -a -t ftp_port_t -p tcp 990 || true
semanage port -a -t ftp_data_port_t -p tcp 30000-30100 || true

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "✅ FTPS (TLS) is ready on port 990."
echo "➡️ Connect using: FTP with TLS (explicit), port 990, user: ec2-user"
