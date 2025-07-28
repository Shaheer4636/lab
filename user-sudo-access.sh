#!/bin/bash
set -e

USER="ec2-user"
PASS="ARKANSAS@123"
PUBLIC_IP="3.82.115.255"  # Replace with your EC2 public IP

echo "🔧 Fixing password and shell..."
echo "$USER:$PASS" | chpasswd
usermod -s /bin/bash $USER
chmod 755 /home/$USER
chown $USER:$USER /home/$USER

echo "✅ Removing user from deny lists..."
sed -i "/^$USER$/d" /etc/ftpusers || true
sed -i "/^$USER$/d" /etc/vsftpd/ftpusers || true

echo "✅ Whitelisting user..."
touch /etc/vsftpd/user_list
grep -qxF "$USER" /etc/vsftpd/user_list || echo "$USER" >> /etc/vsftpd/user_list

echo "🔧 Updating PAM config..."
cat <<EOF > /etc/pam.d/vsftpd
auth       required     pam_unix.so
account    required     pam_unix.so
session    required     pam_unix.so
EOF

echo "🔐 Regenerating strong TLS cert..."
mkdir -p /etc/vsftpd/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/vsftpd/ssl/vsftpd.key \
  -out /etc/vsftpd/ssl/vsftpd.crt \
  -subj "/C=US/ST=None/L=None/O=None/CN=$PUBLIC_IP"

echo "⚙️ Writing final vsftpd.conf..."
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_port=990
listen_ipv6=NO
ssl_enable=YES
implicit_ssl=YES
require_ssl_reuse=NO

rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key

ssl_tlsv1=NO
ssl_tlsv1_1=NO
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_sslv2=NO
ssl_sslv3=NO
ssl_ciphers=HIGH

local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

force_local_logins_ssl=YES
force_local_data_ssl=YES

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
pasv_address=$PUBLIC_IP
pasv_addr_resolve=NO

seccomp_sandbox=NO
xferlog_enable=YES
log_ftp_protocol=YES
EOF

echo "🔓 Opening firewall ports..."
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=30000-30100/tcp --permanent
firewall-cmd --reload

echo "🔁 Restarting vsftpd..."
systemctl restart vsftpd

echo "✅ FTPS with Implicit TLS ready on $PUBLIC_IP:990"
echo "➡️ Login as: $USER / $PASS"
