#!/bin/bash

set -e

FTP_USER="ec2-user"
FTP_PASS="ARKANSAS@123"
CERT_DIR="/etc/ssl/private"
CERT_FILE="$CERT_DIR/vsftpd.pem"
CONF_FILE="/etc/vsftpd/vsftpd-990.conf"

echo "[+] Installing required packages..."
yum install -y vsftpd openssl policycoreutils-python-utils

echo "[+] Generating self-signed certificate..."
mkdir -p $CERT_DIR
openssl req -x509 -nodes -days 365 \
  -subj "/CN=ftp-server" \
  -newkey rsa:2048 \
  -keyout $CERT_FILE \
  -out $CERT_FILE

chmod 600 $CERT_FILE
chown root:root $CERT_FILE

echo "[+] Writing vsftpd config for implicit FTPS..."
cat > $CONF_FILE <<EOF
listen=YES
listen_ipv6=NO
ssl_enable=YES
implicit_ssl=YES
rsa_cert_file=$CERT_FILE
rsa_private_key_file=$CERT_FILE
force_local_logins_ssl=YES
force_local_data_ssl=YES
local_enable=YES
write_enable=YES
allow_anon_ssl=NO
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
anonymous_enable=NO
pam_service_name=vsftpd
user_sub_token=\$USER
local_root=/home/\$USER
chroot_local_user=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
xferlog_enable=YES
xferlog_std_format=YES
EOF

echo "[+] Creating systemd override for vsftpd..."
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd $CONF_FILE
EOF

echo "[+] Enabling firewall for port 990..."
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --permanent --add-port=40000-40100/tcp || true
firewall-cmd --reload || true

echo "[+] Configuring SELinux if applicable..."
setsebool -P ftpd_full_access 1 || true
setsebool -P allow_ftpd_anon_write=1 || true
setsebool -P ftp_home_dir=1 || true

echo "[+] Ensuring user home permissions..."
usermod -d /home/$FTP_USER $FTP_USER || true
chmod 755 /home/$FTP_USER
echo "$FTP_PASS" | passwd --stdin $FTP_USER

echo "[+] Reloading systemd and restarting vsftpd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

sleep 2
echo "[+] Verifying port 990 is listening..."
ss -tuln | grep :990 || echo "ERROR: Port 990 is NOT listening"
