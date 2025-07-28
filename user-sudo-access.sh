#!/bin/bash
set -e

# === 1. Remove old vsftpd setup ===
echo "[*] Removing existing vsftpd setup..."
systemctl stop vsftpd || true
yum remove -y vsftpd || true
rm -rf /etc/vsftpd /etc/systemd/system/vsftpd.service.d /etc/ssl/private/vsftpd.pem

# === 2. Reinstall vsftpd ===
echo "[*] Installing vsftpd..."
yum install -y vsftpd

# === 3. Generate self-signed SSL cert ===
echo "[*] Generating self-signed SSL cert..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=$(hostname)"

# === 4. Write vsftpd config for implicit TLS on port 990 ===
echo "[*] Writing vsftpd config for port 990..."
mkdir -p /etc/vsftpd
cat > /etc/vsftpd/vsftpd-990.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
xferlog_std_format=YES
connect_from_port_20=YES

ssl_enable=YES
implicit_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem

pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
EOF

# === 5. Override systemd to use new config ===
echo "[*] Creating systemd override..."
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-990.conf
EOF

# === 6. Open required firewall ports ===
echo "[*] Configuring firewall..."
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --permanent --add-port=40000-40100/tcp || true
firewall-cmd --reload || true

# === 7. Configure SELinux ===
echo "[*] Configuring SELinux..."
setsebool -P ftpd_full_access 1 || true

# === 8. Setup user ===
echo "[*] Creating FTP user..."
useradd -m ec2-user || true
echo "ec2-user:ARKANSAS@123" | chpasswd
chmod 755 /home/ec2-user

# === 9. Restart services ===
echo "[*] Reloading systemd and restarting vsftpd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

# === 10. Check if port 990 is open ===
echo "[*] Checking port 990..."
ss -tuln | grep :990 && echo "✅ FTPS is now listening on port 990." || echo "❌ ERROR: Port 990 is still not listening. Check logs with: journalctl -xeu vsftpd"

# === Done ===
echo "Done. Use FileZilla or WinSCP with:"
echo "  Host: YOUR_EC2_PUBLIC_IP"
echo "  Port: 990"
echo "  Protocol: FTPS (Implicit TLS)"
echo "  User: ec2-user"
echo "  Password: ARKANSAS@123"
