#!/bin/bash
set -e

# ========== 1. Create user 'frank' ==========
if ! id "frank" &>/dev/null; then
    echo "Creating user frank"
    useradd -m -s /bin/bash frank
fi

# ========== 2. Set password ==========
echo "frank:frank@liberty123!" | chpasswd

# ========== 3. Ensure /bin/bash as shell ==========
chsh -s /bin/bash frank

# ========== 4. Fix /etc/shells ==========
grep -qxF '/bin/bash' /etc/shells || echo '/bin/bash' >> /etc/shells

# ========== 5. Fix permissions ==========
mkdir -p /home/frank
chown -R frank:frank /home/frank
chmod 755 /home/frank

# ========== 6. SSH config backup ==========
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# ========== 7. Enable password login ==========
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# ========== 8. Restart SSH ==========
systemctl restart ssh

echo "✅ Setup complete. Try logging in again with WinSCP."
