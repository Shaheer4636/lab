#!/bin/bash
set -e

USER="ec2-user"
PASS="ARKANSAS@123"

echo "[*] Installing required packages..."
yum install -y vsftpd openssl policycoreutils-python-utils

echo "[*] Creating TLS cert..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.key \
  -out /etc/ssl/certs/vsftpd.crt \
  -subj "/C=US/ST=NA/L=NA/O=FTPS/CN=localhost"

echo "[*] Backing up original config..."
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_port=990
connect_from_port_20=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=/home/\$USER
pam_service_name=vsftpd
ssl_enable=YES
require_ssl_reuse=NO
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_ciphers=HIGH
rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
force_local_data_ssl=YES
force_local_logins_ssl=YES
implicit_ssl=YES
seccomp_sandbox=NO
EOF

echo "[*] Setting user password..."
echo "${USER}:${PASS}" | chpasswd

echo "[*] Fixing home directory and permissions..."
chmod 755 /home/${USER}

echo "[*] Adjusting SELinux policies..."
setsebool -P ftpd_full_access 1
semanage fcontext -a -t public_content_t "/home/${USER}(/.*)?"
restorecon -Rv /home/${USER}

echo "[*] Opening firewall ports..."
firewall-cmd --add-port=990/tcp --permanent
firewall-cmd --add-port=30000-30100/tcp --permanent
firewall-cmd --reload

echo "[*] Enabling and restarting vsftpd..."
systemctl enable vsftpd
systemctl restart vsftpd

echo "[✔] FTPS server is now running on port 990 for user: ${USER}"
