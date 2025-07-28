#!/bin/bash
set -e

# === 1. Install packages ===
yum install -y vsftpd openssl policycoreutils-python-utils

# === 2. Create SSL certificate ===
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 \
  -subj "/C=US/ST=FTP/L=Server/O=SelfSigned/CN=$(hostname)" \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem

# === 3. Set password for ec2-user ===
echo "ARKANSAS@123" | passwd ec2-user --stdin

# === 4. Fix user home dir permissions ===
chmod 755 /home/ec2-user
chown ec2-user:ec2-user /home/ec2-user

# === 5. Configure SELinux to allow FTP (skip if SELinux is disabled) ===
setsebool -P ftp_home_dir 1 || true
setsebool -P allow_ftpd_full_access 1 || true
semanage port -a -t ftp_port_t -p tcp 990 || true

# === 6. Write vsftpd config for implicit TLS on 990 ===
cat > /etc/vsftpd/vsftpd-990.conf <<EOF
listen=YES
listen_ipv6=NO
ssl_enable=YES
implicit_ssl=YES
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
force_local_logins_ssl=YES
force_local_data_ssl=YES
allow_anon_ssl=NO
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
pam_service_name=vsftpd
user_sub_token=$USER
local_root=/home/\$USER
chroot_local_user=YES
pasv_enable=YES
pasv_min_port=10090
pasv_max_port=10100
EOF

# === 7. Create systemd override to bind to port 990 with custom config ===
mkdir -p /etc/systemd/system/vsftpd.service.d
cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd-990.conf
EOF

# === 8. Open ports in firewalld (skip if you’re not using firewalld) ===
firewall-cmd --permanent --add-port=990/tcp || true
firewall-cmd --permanent --add-port=10090-10100/tcp || true
firewall-cmd --reload || true

# === 9. Reload systemd and restart service ===
systemctl daemon-reload
systemctl restart vsftpd
systemctl enable vsftpd

# === 10. Verify port 990 is listening ===
echo
echo "Verifying port 990..."
ss -tuln | grep :990 || (echo "❌ Port 990 not open" && exit 1)

echo
echo "✅ FTPS is running and accessible for ec2-user on port 990 (pass: ARKANSAS@123)"
