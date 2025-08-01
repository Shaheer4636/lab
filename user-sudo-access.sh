Understood. Below is a **fully filled Azure CLI script** that will:

* Create a VNet with both VM and Bastion subnets
* Deploy a **Windows Server 2022 VM** with **no public IP**
* Deploy an **Azure Bastion Host**
* Use predefined names, location, VM size, admin username/password, and RDS-ready image
* You won't have to fill in a **single value**

---

### ✅ FULL AZURE CLI SCRIPT — BASTION + RDP VM + NETWORK

```bash
# Set variables
RESOURCE_GROUP="vm-rdp-test"
LOCATION="eastus"
VNET_NAME="vm-rdp-vnet"
VM_SUBNET_NAME="vm-subnet"
BASTION_SUBNET_NAME="AzureBastionSubnet"
VM_NAME="rdp-vm"
BASTION_NAME="bastion-host"
PUBLIC_IP_NAME="bastion-pip"
ADMIN_USERNAME="azureadmin"
ADMIN_PASSWORD="P@ssw0rd1234!"  # Change this if needed

# Create VNet and subnets
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $VM_SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $BASTION_SUBNET_NAME \
  --address-prefix 10.0.2.0/27

# Create public IP for Bastion
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --sku Standard

# Create Bastion Host
az network bastion create \
  --name $BASTION_NAME \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --location $LOCATION \
  --public-ip-address $PUBLIC_IP_NAME \
  --sku Basic

# Create Windows Server VM (no public IP)
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Win2022Datacenter \
  --size Standard_D2s_v3 \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --vnet-name $VNET_NAME \
  --subnet $VM_SUBNET_NAME \
  --public-ip-address "" \
  --nsg "" \
  --license-type Windows_Server \
  --location $LOCATION
```

---

### 🧾 Output Summary:

* **VM Name:** `rdp-vm`
* **Bastion Name:** `bastion-host`
* **Username:** `azureadmin`
* **Password:** `P@ssw0rd1234!`
* **VM Size:** `Standard_D2s_v3`
* **Region:** `East US`
* **Public IP:** Only for Bastion (VM stays private)

---

### 📌 Final Step (After CLI Runs):

Go to Azure Portal → Resource Group → `rdp-vm` → **Connect** → **Bastion**
Use the above username/password to open the RDP session in browser.

---

Let me know if you want a one-click **Bicep or Terraform** version.
