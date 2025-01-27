Installing Chocolatey on Windows 11 is straightforward. Follow these steps:

---

### **1. Open PowerShell as Administrator**
1. Press **Win + S** and type `PowerShell`.
2. Right-click **Windows PowerShell** and select **Run as administrator**.

---

### **2. Check for Execution Policy**
Chocolatey requires the execution policy to allow running scripts:
1. Run the command below to see the current policy:
   ```powershell
   Get-ExecutionPolicy
   ```
2. If it returns **Restricted**, set it to **AllSigned** or **RemoteSigned** by running:
   ```powershell
   Set-ExecutionPolicy AllSigned
   ```
   Or:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```
   Press `A` to confirm.

---

### **3. Install Chocolatey**
Run the following command in the administrator PowerShell to install Chocolatey:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

---

### **4. Verify Installation**
After the installation is complete, check if Chocolatey was installed successfully by running:
```powershell
choco -v
```
You should see the version of Chocolatey installed.

---

### **5. Use Chocolatey**
You can now install software using Chocolatey. For example, to install Google Chrome:
```powershell
choco install googlechrome -y
```

---

### **Troubleshooting**
- Ensure you have an active internet connection.
- If a proxy is used, configure it in PowerShell.
- Run PowerShell as **Administrator** during installation.

Let me know if you face any issues!
