#!/bin/bash

set -e

# 1. Create user 'frank' if not exists
if id "frank" &>/dev/null; then
    echo "User 'frank' already exists"
else
    echo "Creating user 'frank'"
    useradd -m -s /bin/bash frank
fi

# 2. Set password for 'frank'
echo "frank:frank@liberty123!" | chpasswd
echo "✅ Password set for user 'frank'"

# 3. Set shell to /bin/bash
chsh -s /bin/bash frank

# 4. Ensure /bin/bash is listed in /etc/shells
grep -qxF '/bin/bash' /etc/shells || echo '/bin/bash' >> /etc/shells

# 5. Ensure correct home permissions
mkdir -p /home/frank
chown -R frank:frank /home/frank
chmod 755 /home/frank

# 6. Fix SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup_$(date +%F_%T)
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# 7. Restart SSH service
systemctl restart ssh

echo "🎉 All done. You can now SSH/SCP with user 'frank'"
