#!/bin/bash

# Define paths
CERT_PATH="/etc/ssl/certs/ftp-cert.pem"
KEY_PATH="/etc/ssl/private/ftp-key.pem"

# Create directory if not exists
mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate the certificate
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout "$KEY_PATH" \
  -out "$CERT_PATH" \
  -subj "/C=PK/ST=Punjab/L=Mianwali/O=MyCompany/OU=IT/CN=your.domain.com"

# Set permissions
chmod 600 "$KEY_PATH"
chmod 644 "$CERT_PATH"

# Optional: Restart your FTPS server
# systemctl restart vsftpd

echo "✅ TLS certificate and key created:"
echo "  Certificate: $CERT_PATH"
echo "  Key:         $KEY_PATH"
