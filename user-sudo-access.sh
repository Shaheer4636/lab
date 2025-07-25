#!/bin/bash

echo "🔧 Resetting ec2-user to have full SFTP/SSH access..."

# 1. Remove Match block from sshd_config
echo "👉 Cleaning up sshd_config restrictions..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -q "Match User ec2-user" "$SSHD_CONFIG"; then
    sudo sed -i '/^Match User ec2-user/,+5d' "$SSHD_CONFIG"
    echo "✅ Match block for ec2-user removed."
else
    echo "ℹ️ No Match block found for ec2-user."
fi

# 2. Ensure ec2-user has a valid shell
echo "👉 Ensuring ec2-user has /bin/bash shell..."
sudo usermod -s /bin/bash ec2-user

# 3. Open port 22 in iptables if not already open
echo "👉 Checking iptables rule for port 22..."
if ! sudo iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
    sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
    sudo iptables-save | sudo tee /etc/sysconfig/iptables > /dev/null
    echo "✅ Port 22 allowed in iptables."
else
    echo "ℹ️ Port 22 already open in iptables."
fi

# 4. Restart SSHD
echo "🔄 Restarting sshd..."
sudo systemctl restart sshd

# 5. Final Check
echo "✅ ec2-user now has full SFTP and SSH access on port 22."
echo "➡️ Test using: sftp ec2-user@<your-ec2-ip>"
