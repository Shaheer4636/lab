#!/bin/bash

set -e

echo "🔓 Disabling SELinux temporarily to test..."
setenforce 0 || echo "SELinux already permissive."

echo "👤 Verifying user config..."
usermod -s /bin/bash ec2-user
echo "ec2-user:ARKANSAS@123" | chpasswd
mkdir -p /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user
chmod 755 /home/ec2-user

echo "👁️ Whitelisting ec2-user..."
touch /etc/vsftpd/user_list
grep -qxF "ec2-user" /etc/vsftpd/user_list || echo "ec2-user" >> /etc/vsftpd/user_list

echo "⚙️ Enforcing vsftpd fallback config..."
cat <<EOF > /etc/vsftpd/vsftpd.conf
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

local_enable=YES
write_enable=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
chroot_local_user=YES
allow_writeable_chroot=YES
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd/user_list

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100

log_ftp_protocol=YES
xferlog_enable=YES
xferlog_std_format=YES
dirmessage_enable=YES
use_localtime=YES
ftpd_banner=Welcome.
EOF

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd

echo "🔍 Tailing logs for login attempt..."
echo "Try WinSCP login now and leave this running:"
echo "---------------------------------------------"
tail -f /var/log/messages | grep -i vsftpd
