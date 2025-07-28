#!/bin/bash

set -e

echo ">>> Enforcing override for port 990..."
mkdir -p /etc/systemd/system/vsftpd.service.d

cat > /etc/systemd/system/vsftpd.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
EOF

echo ">>> Reloading systemd and restarting vsftpd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart vsftpd

sleep 2
echo ">>> Checking port 990..."
ss -tuln | grep :990 && echo "SUCCESS: vsftpd is now listening on port 990." || echo "FAIL: Still not listening. Check logs."

echo ">>> Done."
