#!/bin/bash

set -e

echo "🔧 Updating packages..."
yum update -y

echo "📦 Installing required packages..."
yum install -y vsftpd openssh-server openssl firewalld policycoreutils-python-utils

echo "🚀 Enabling and starting services..."
systemctl enable --now sshd
systemctl enable --now vsftpd
systemctl enable --now firewalld

echo "📁 Creating SFTP user directory..."
useradd -m sftpuser
echo "sftpuser:StrongPassword@123" | chpasswd
mkdir -p /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh
chown sftpuser:sftpuser /home/sftpuser/.ssh

echo "🔐 Generating SSH key pair if needed..."
if [ ! -f /home/sftpuser/.ssh/authorized_keys ]; then
    su - sftpuser -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
    cat /home/sftpuser/.ssh/id_rsa.pub > /home/sftpuser/.ssh/authorized_keys
fi

chmod 600 /home/sftpuser/.ssh/authorized_keys
chown sftpuser:sftpuser /home/sftpuser/.ssh/authorized_keys

echo "✅ SSH for SFTP is ready on port 22"

echo "🔐 Generating self-signed TLS certificate for FTPS..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/ftp-key.pem \
  -out /etc/ssl/certs/ftp-cert.pem \
  -subj "/C=PK/ST=Punjab/L=Mianwali/O=MyCompany/OU=IT/CN=$(hostname)"

chmod 600 /etc/ssl/private/ftp-key.pem
chmod 644 /etc/ssl/certs/ftp-cert.pem

echo "⚙️ Configuring vsftpd..."
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
xferlog_std_format=YES
ftpd_banner=Welcome to Secure FTP Service.
chroot_local_user=YES
allow_writeable_chroot=YES

rsa_cert_file=/etc/ssl/certs/ftp-cert.pem
rsa_private_key_file=/etc/ssl/private/ftp-key.pem
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH

pasv_min_port=30000
pasv_max_port=30100

listen_port=990
EOF

echo "🧱 Allowing ports in firewall..."
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=990/tcp
firewall-cmd --permanent --add-port=30000-30100/tcp
firewall-cmd --reload

echo "🔐 Updating SELinux for vsftpd to allow FTPS..."
setsebool -P allow_ftpd_full_access 1
setsebool -P ftp_home_dir 1
semanage port -a -t ftp_port_t -p tcp 990 || true
semanage port -a -t ftp_data_port_t -p tcp 30000-30100 || true

echo "🔁 Restarting services..."
systemctl restart vsftpd
systemctl restart sshd

echo "✅✅ All done! SFTP is available on port 22, FTPS on port 990."
echo "➡️ Connect as user: sftpuser / StrongPassword@123"
