#!/bin/bash

# Variables
FTP_USER="ec2-user"
FTP_PASS="ARKANSAS@123"
PUBLIC_IP="3.82.115.255"

# Create SSL cert directory and generate cert
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/vsftpd/ssl/vsftpd.key \
-out /etc/vsftpd/ssl/vsftpd.crt \
-subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=$(hostname)"

# Write secure vsftpd config
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
listen_port=990

anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

local_root=/home/$FTP_USER
user_sub_token=\$USER

ssl_enable=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key
implicit_ssl=YES

ssl_tlsv1=YES
ssl_tlsv1_1=NO
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES

require_ssl_reuse=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
pasv_address=$PUBLIC_IP

use_localtime=YES
EOF

# Set FTP user password and shell
echo "$FTP_USER:$FTP_PASS" | chpasswd
usermod -s /bin/bash $FTP_USER
mkdir -p /home/$FTP_USER
chown $FTP_USER:$FTP_USER /home/$FTP_USER
chmod 755 /home/$FTP_USER

# Remove ec2-user from block lists
sed -i "/$FTP_USER/d" /etc/vsftpd/ftpusers
sed -i "/$FTP_USER/d" /etc/vsftpd/user_list

# Open firewall ports
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=40000-40010/tcp --permanent
firewall-cmd --reload

# Restart vsftpd
systemctl restart vsftpd

echo "[✔] FTPS Implicit is now ready on port 990 for user $FTP_USER (password: $FTP_PASS)"
