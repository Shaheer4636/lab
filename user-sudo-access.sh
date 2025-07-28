
#!/bin/bash

set -e

echo "[+] Installing vsftpd and OpenSSL..."
if command -v yum >/dev/null; then
    yum install -y vsftpd openssl
elif command -v apt >/dev/null; then
    apt update && apt install -y vsftpd openssl
else
    echo "Unsupported package manager. Install vsftpd and openssl manually."
    exit 1
fi

echo "[+] Creating SSL certificate..."
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=US/ST=State/L=City/O=Org/OU=Dept/CN=$(hostname)" \
    -keyout /etc/ssl/private/vsftpd.key \
    -out /etc/ssl/private/vsftpd.crt

echo "[+] Backing up old config..."
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak || true

echo "[+] Writing new vsftpd.conf for implicit FTPS on port 990..."
PUBLIC_IP=$(curl -s ifconfig.me)
cat > /etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

rsa_cert_file=/etc/ssl/private/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
ssl_enable=YES
require_ssl_reuse=NO
ssl_tlsv1=YES
ssl_tlsv1_1=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=NO
ssl_ciphers=HIGH

implicit_ssl=YES
listen_port=990

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
pasv_address=$PUBLIC_IP

ftpd_banner=Welcome to Secure FTPS on port 990
EOF

echo "[+] Creating FTP user 'ec2-user' with password..."
echo "ec2-user:ARKANSAS@123" | chpasswd
usermod -s /sbin/nologin ec2-user
chmod 755 /home/ec2-user

echo "[+] Opening ports in firewall..."
if command -v firewall-cmd >/dev/null; then
    firewall-cmd --permanent --add-port=990/tcp
    firewall-cmd --permanent --add-port=40000-40010/tcp
    firewall-cmd --reload
elif command -v iptables >/dev/null; then
    iptables -I INPUT -p tcp --dport 990 -j ACCEPT
    iptables -I INPUT -p tcp --dport 40000:40010 -j ACCEPT
fi

echo "[+] Restarting vsftpd service..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "[+] FTPS Implicit is ready on port 990 for user ec2-user (password: ARKANSAS@123)"
