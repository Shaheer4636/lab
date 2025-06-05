Thanks — from what you're describing:

* You have created users (`frank`, `brent`, `preeti`, `gaurav`) **on your Ubuntu server**.
* But you **cannot connect to these users directly** from **Windows via WinSCP** or SSH.
* Only the `ubuntu` user (default EC2 user) can connect.

Let’s fix this step-by-step 👇

---

## ✅ Step-by-Step to Allow Login for Other Users (`frank`, etc.)

### 🔹 1. Connect to your server using the working `ubuntu` user

```bash
ssh -i mykey.pem ubuntu@your-server-ip
```

---

### 🔹 2. Check if the users exist and have home directories

```bash
cat /etc/passwd | grep -E 'frank|brent|preeti|gaurav'
ls -ld /home/frank /home/brent /home/preeti /home/gaurav
```

> 🔸 If any of the home folders are missing, you can create them:

```bash
sudo mkdir /home/frank
sudo chown frank:frank /home/frank
sudo chmod 700 /home/frank
```

---

### 🔹 3. Copy the `.ssh/authorized_keys` from `ubuntu` user

This allows them to connect with the **same key file (`.pem`)** used by `ubuntu`.

```bash
sudo mkdir -p /home/frank/.ssh
sudo cp /home/ubuntu/.ssh/authorized_keys /home/frank/.ssh/
sudo chown -R frank:frank /home/frank/.ssh
sudo chmod 700 /home/frank/.ssh
sudo chmod 600 /home/frank/.ssh/authorized_keys
```

🔁 Repeat this for `brent`, `preeti`, and `gaurav`.

---

### 🔹 4. Allow SSH login if restricted

Check `/etc/ssh/sshd_config`:

```bash
sudo nano /etc/ssh/sshd_config
```

Ensure the following are set:

```text
PermitRootLogin no
AllowUsers ubuntu frank brent preeti gaurav
PasswordAuthentication no
```

Then restart SSH:

```bash
sudo systemctl restart sshd
```

---

### 🔹 5. Connect via WinSCP or SSH

Use same `.ppk` (converted from `.pem`) for login:

* **Hostname**: `your-server-ip`
* **Username**: `frank` (or the one you want)
* **Authentication key**: Your `.ppk` file

---

### 🧪 Test SSH

```bash
ssh -i mykey.pem frank@your-server-ip
```

If this works, WinSCP will work too with the same `.ppk`.

---

### ❗ If You Get “Permission Denied”:

* Double-check file/folder ownership:

```bash
sudo chown -R frank:frank /home/frank/.ssh
```

* Make sure `.ssh` is `700` and `authorized_keys` is `600`

---

Let me know if you want an Ansible or bash script to automate all this for every user.
