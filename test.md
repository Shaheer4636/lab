```

#!/bin/bash

# Create user joseph
sudo useradd -m -s /bin/bash joseph

# Set password
echo 'joseph:joseph@liberty123!' | sudo chpasswd

# Add to sudo group
sudo usermod -aG sudo joseph

# Ensure SSH is installed
sudo apt update && sudo apt install -y openssh-server

# Enable password auth in SSH (if needed)
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Disable root login for better security
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh

echo "User 'joseph' created with sudo access. You can now login using: ssh joseph@<server-ip>"


```bash
