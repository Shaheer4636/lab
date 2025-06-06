Perfect. Here's **exactly what you need to do** to create a shared folder for the users: `frank`, `ubuntu`, `ssm`, `preeti`, `gaurav`, and `brent` on your Ubuntu server.

---

### 🔧 Step-by-Step Setup

#### ✅ 1. Create the Shared Folder

```bash
sudo mkdir /srv/shared
```

---

#### ✅ 2. Create a Shared Group

Create a group called `sharedgroup`:

```bash
sudo groupadd sharedgroup
```

---

#### ✅ 3. Add All Users to the Group

Run these commands one by one:

```bash
sudo usermod -aG sharedgroup frank
sudo usermod -aG sharedgroup ubuntu
sudo usermod -aG sharedgroup ssm
sudo usermod -aG sharedgroup preeti
sudo usermod -aG sharedgroup gaurav
sudo usermod -aG sharedgroup brent
```

⚠️ **All users must log out and log back in** to apply the new group membership.

---

#### ✅ 4. Set Group Ownership and Permissions on the Folder

```bash
sudo chown root:sharedgroup /srv/shared
sudo chmod 2775 /srv/shared
```

* `2775` sets the **setgid bit** so new files keep the group ownership.
* All users in `sharedgroup` can **read, write, and list files**.

---

#### ✅ 5. (Optional but Recommended) Set Default Permissions for New Files

Install ACL (if not already installed):

```bash
sudo apt install acl
```

Then set default ACL:

```bash
sudo setfacl -d -m g::rwx /srv/shared
sudo setfacl -d -m o::rx /srv/shared
```

This ensures all **new files or folders inside `/srv/shared` automatically** get group read-write permissions.

---

### ✅ Final Verification

You can test as any of the users:

```bash
cd /srv/shared
touch testfile
```

Run `ls -l` to confirm the file is group-owned by `sharedgroup`.

---

Let me know if you want this shared folder to be accessible via **Samba**, **NFS**, or over the **network** too.
