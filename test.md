```

sudo sed -i '/^PubkeyAuthentication/d' /etc/ssh/sshd_config && echo 'PubkeyAuthentication yes' | sudo tee -a /etc/ssh/sshd_config && sudo systemctl restart ssh


```bash
