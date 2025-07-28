#!/bin/bash

USER="ec2-user"
PASS="ARKANSAS@123"
HOME_DIR="/home/${USER}"

echo "🔒 Setting password for ${USER}..."
echo "${USER}:${PASS}" | chpasswd

echo "📁 Ensuring home directory permissions..."
chown ${USER}:${USER} "$HOME_DIR"
chmod 755 "$HOME_DIR"

echo "🔐 Installing vsftpd and OpenSSL if needed..."
yum install -y vsftpd openssl || apt install -y vsftpd openssl

echo "📜 Generating self-signed SSL certificate..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=$(hostname)" \
  -keyout /etc/ssl/private/vsftpd.key \
  -out /etc/ssl/private/vsftpd.crt

echo "⚙️ Writing vsftpd config for Implicit FTPS on port 990..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

rsa_cert_file=/etc/ssl/private/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
ssl_enable=YES
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
pasv_address=$(curl -s ifconfig.me)

listen_port=990
ftpd_banner=Welcome to secure FTPS.
EOF

echo "🔓 Adjusting firewall..."
iptables -I INPUT -p tcp --dport 990 -j ACCEPT
iptables -I INPUT -p tcp --dport 40000:40010 -j ACCEPT
setsebool -P ftp_home_dir 1 2>/dev/null || true

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "✅ Setup complete! Try connecting to FTPS on port 990 using ec2-user / $PASS"
