```

# Replace this with your actual public key
PUBKEY="ssh-rsa AAAAB3Nz...your_actual_key... user@host"

# List of users to fix
for user in ubuntu gaurav brent preeti frank jacob; do
  sudo mkdir -p /home/$user/.ssh
  echo "$PUBKEY" | sudo tee /home/$user/.ssh/authorized_keys > /dev/null
  sudo chmod 700 /home/$user/.ssh
  sudo chmod 600 /home/$user/.ssh/authorized_keys
  sudo chown -R $user:$user /home/$user/.ssh
done


```bash
