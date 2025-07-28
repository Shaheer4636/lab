#!/bin/bash

FTPUSER=ftpuser
FTPPASS='ARKANSAS@123'
PUBIP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# 1. Install necessary packages
yum install -y vsftpd openssl

# 2. Create FTP user
useradd -m -s /sbin/nologin $FTPUSER
echo "$FTPUSER:$FTPPASS" | chpasswd

# 3. Create SSL cert
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
 -keyout /etc/vsftpd/ssl/vsftpd.key \
 -out /etc/vsftpd/ssl/vsftpd.crt \
 -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/OU=FTPD/CN=$PUBIP"

# 4. Configure vsftpd.conf
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
listen_port=990
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=$FTPUSER
local_root=/home/$FTPUSER
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
pasv_address=$PUBIP
use_localtime=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key
ssl_enable=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
require_ssl_reuse=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
implicit_ssl=YES
EOF

# 5. Set permissions
chmod 600 /etc/vsftpd/ssl/vsftpd.key
chown -R $FTPUSER:$FTPUSER /home/$FTPUSER

# 6. Disable SELinux temporarily (or make proper policy)
setenforce 0

# 7. Open firewall
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=40000-40010/tcp --permanent
firewall-cmd --reload

# 8. Restart vsftpd
systemctl restart vsftpd
systemctl enable vsftpd

echo "✅ DONE: Connect using username '$FTPUSER' password '$FTPPASS' to $PUBIP:990 with Implicit TLS"
