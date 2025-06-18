```

#!/bin/bash

# === CONFIG: REPLACE this with your .pem private key converted to public key ===
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."  # <-- Replace with actual public key

echo "[*] Creating .ssh directory and fixing permissions for ubuntu user..."

sudo mkdir -p /home/ubuntu/.ssh
echo "$PUBLIC_KEY" | sudo tee /home/ubuntu/.ssh/authorized_keys >/dev/null

sudo chmod 700 /home/ubuntu/.ssh
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh

echo "[*] Updating sshd_config to allow key-based login..."
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

echo "[*] Restarting SSH service..."
sudo systemctl restart sshd

echo "[✓] Done. You should now be able to SSH with your .pem file again."



```bash
