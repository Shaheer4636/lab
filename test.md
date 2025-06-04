You're in a **critical situation**:

> Your Ubuntu production server is **completely out of space**, and you can't even install tools like `cloud-guest-utils`.

---

## 🔥 Emergency Steps to Free Up Space Immediately

### 🛠 1. **Clean APT Cache**

```bash
sudo rm -rf /var/lib/apt/lists/*
sudo apt clean
```

---

### 🧹 2. **Clear Logs**

```bash
sudo rm -rf /var/log/*.gz
sudo rm -rf /var/log/*.1
sudo journalctl --vacuum-time=1d
```

---

### 🧼 3. **Clear Snap Cache (VERY LIKELY culprit)**

```bash
sudo du -sh /var/lib/snapd/snaps
sudo rm -rf /var/lib/snapd/snaps/*
```

Then restart snap:

```bash
sudo systemctl restart snapd
```

---

### 🗑 4. **Delete Old Docker Resources (If Docker Installed)**

```bash
docker system prune -a -f
```

---

### 🧾 5. **Find and Remove Big Files (Optional but Best)**

```bash
sudo du -h --max-depth=1 / | sort -hr | head -n 20
```

This shows the largest directories. For example:

```bash
sudo du -sh /var/lib/docker
sudo rm -rf /var/lib/docker/*
```

---

## ✅ After Freeing 300–500 MB

Now rerun the grow/resize sequence:

```bash
sudo apt update
sudo apt install -y cloud-guest-utils

sudo growpart /dev/xvda 1
sudo resize2fs /dev/xvda1
```

Then verify:

```bash
df -h
```

---

### 🚨 Emergency Space Tip:

If you **just need space for 1 minute** to run apt install:

```bash
sudo mkdir /tmp-recovery
sudo mount -t tmpfs -o size=300M tmpfs /tmp-recovery
sudo ln -s /tmp-recovery /var/lib/apt/lists
```

Then install the utility.

---

Let me know if:

* You want me to SSH in and do it (I can guide line-by-line)
* You use `LVM` or `XFS` (I'll adjust commands)
  This **can be resolved in 2–3 minutes**. You're almost there.
