#!/bin/bash
set -e

FTP_USER="ec2-user"
FTP_PASS="ARKANSAS@123"
CONF_FILE="/etc/vsftpd/vsftpd-990.conf"
CERT_FILE="/etc/ssl/private/vsftpd.pem"
OVERRIDE_PATH="/etc/systemd/system/vsftpd.service.d/override.conf"

echo "[*] Removing old vsftpd if exists..."
yum remove -y vsftpd || true

echo "[*] Installing vsftpd..."
yum install -y vsftpd openssl policycoreutils-python-utils firewalld

echo "[*] Generating self-signed certificate..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $CERT_FILE -out $CERT_FILE \
  -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=ftp.local"

chmod 600 $CERT_FILE

echo "[*] Writing vsftpd config for port 990..."
cat > $CONF_FILE <<EOF
listen=YES
listen_ipv6=NO
listen_port=990

anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
xferlog_std_format=YES

ssl_enable=YES
implicit_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO

rsa_cert_file=$CERT_FILE
rsa_private_key_file=$CERT_FILE

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100

pam_service_name=vsftpd
EOF

echo "[*] Creating systemd override..."
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > $OVERRIDE_PATH <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd $CONF_FILE
EOF

echo "[*] Enabling firewall ports..."
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --permanent --add-port=40000-40100/tcp || true
firewall-cmd --reload || true

echo "[*] Disabling SELinux temporarily..."
setenforce 0 || true

echo "[*] Ensuring FTP user exists..."
useradd -m $FTP_USER || true
echo "$FTP_PASS" | passwd --stdin $FTP_USER
chmod 755 /home/$FTP_USER

echo "[*] Reloading systemd and restarting vsftpd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

sleep 2

echo "[*] Checking port 990..."
ss -tuln | grep :990 && echo "✅ Port 990 is listening." || echo "❌ Port 990 is NOT listening."

echo "[*] Done. Use FileZilla or WinSCP with:"
echo "    Host: <your-EC2-Public-IP>"
echo "    Port: 990"
echo "    Protocol: FTPS (Implicit TLS)"
echo "    User: $FTP_USER"
echo "    Pass: $FTP_PASS"
