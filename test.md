#!/bin/bash
set -e

# ========== 1. Create user 'preeti' ==========
if ! id "preeti" &>/dev/null; then
    echo "Creating user preeti"
    useradd -m -s /bin/bash preeti
fi

# ========== 2. Set password ==========
echo "preeti:preeti@liberty123!" | chpasswd

# ========== 3. Ensure /bin/bash as shell ==========
chsh -s /bin/bash preeti

# ========== 4. Fix /etc/shells ==========
grep -qxF '/bin/bash' /etc/shells || echo '/bin/bash' >> /etc/shells

# ========== 5. Fix permissions ==========
mkdir -p /home/preeti
chown -R gaurav:preeti /home/preeti
chmod 755 /home/preeti

# ========== 6. SSH config backup ==========
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)

# ========== 7. Enable password login ==========
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
grep -q "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# ========== 8. Restart SSH ==========
systemctl restart ssh

echo "✅ Setup complete. Try logging in again with WinSCP."
