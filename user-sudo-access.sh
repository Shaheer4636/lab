#!/bin/bash

set -e

echo "🔧 Installing dependencies..."
yum install -y vsftpd openssl firewalld policycoreutils-python-utils

echo "🔐 Generating TLS certificate if not present..."
mkdir -p /etc/ssl/private /etc/ssl/certs
if [ ! -f /etc/ssl/certs/ftp-cert.pem ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/ftp-key.pem \
    -out /etc/ssl/certs/ftp-cert.pem \
    -subj "/C=PK/ST=Punjab/L=Mianwali/O=MyCompany/OU=IT/CN=$(hostname)"
  chmod 600 /etc/ssl/private/ftp-key.pem
  chmod 644 /etc/ssl/certs/ftp-cert.pem
fi

echo "🔧 Fixing shell for ec2-user..."
chsh -s /bin/bash ec2-user || true

echo "🔑 Setting password for ec2-user..."
echo "ec2-user:ARKANSAS@123" | chpasswd

echo "👤 Allowing ec2-user in vsftpd user_list..."
touch /etc/vsftpd/user_list
grep -qxF 'ec2-user' /etc/vsftpd/user_list || echo 'ec2-user' >> /etc/vsftpd/user_list

echo "📝 Writing vsftpd.conf for IMPLICIT TLS (port 990)..."
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
listen_port=990

ssl_enable=YES
implicit_ssl=YES

rsa_cert_file=/etc/ssl/certs/ftp-cert.pem
rsa_private_key_file=/etc/ssl/private/ftp-key.pem

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

anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
ftpd_banner=Welcome to Secure Implicit FTPS.
chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100

userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
EOF

echo "🧱 Opening firewall ports..."
firewall-cmd --permanent --add-port=990/tcp
firewall-cmd --permanent --add-port=30000-30100/tcp
firewall-cmd --reload

echo "🔐 Configuring SELinux..."
setsebool -P allow_ftpd_full_access 1
semanage port -a -t ftp_port_t -p tcp 990 || true
semanage port -a -t ftp_data_port_t -p tcp 30000-30100 || true

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "✅ IMPLICIT TLS FTPS setup complete on port 990"

