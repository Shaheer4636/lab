```

echo "$PUBKEY" | sudo tee /home/ubuntu/.ssh/authorized_keys
sudo chmod 700 /home/ubuntu/.ssh
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh


```bash
