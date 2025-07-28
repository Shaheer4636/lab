#!/bin/bash

set -e

USER="ec2-user"
PASS="ARKANSAS@123"
HOME="/home/$USER"
CONF="/etc/vsftpd/vsftpd.conf"

echo "🔧 Forcing valid shell..."
usermod -s /bin/bash $USER

echo "🔐 Resetting password..."
echo "$USER:$PASS" | chpasswd

echo "📁 Fixing home directory..."
mkdir -p "$HOME"
chown $USER:$USER "$HOME"
chmod 755 "$HOME"

echo "👤 Whitelisting user..."
touch /etc/vsftpd/user_list
grep -qxF "$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "⚙️ Updating vsftpd.conf for implicit FTPS..."
cat <<EOF > $CONF
listen=YES
listen_ipv6=NO
listen_port=990
implicit_ssl=YES
ssl_enable=YES

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
use_localtime=YES
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
ftpd_banner=Welcome to ec2-user's FTPS!
chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100

userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
EOF

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd

echo "🔍 Logging last 50 vsftpd messages (for debugging)..."
tail -n 50 /var/log/messages | grep -i vsftpd || echo "⚠️ No vsftpd logs found."

echo "✅ ec2-user FTPS setup forced. Try login now."
