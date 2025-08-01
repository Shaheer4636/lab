# ------------------ SET FIXED CONFIG ------------------
RESOURCE_GROUP="vm-rdp-test"
LOCATION="eastus"
VNET_NAME="vm-rdp-vnet"
VM_SUBNET_NAME="vm-subnet"
BASTION_SUBNET_NAME="AzureBastionSubnet"
VM_NAME="win2019-rdpvm"
BASTION_NAME="bastion-host"
PUBLIC_IP_NAME="bastion-pip"
ADMIN_USERNAME="adminuser"
ADMIN_PASSWORD="P@ssw0rd1234!"
VM_SIZE="Standard_D2s_v3"
DISK_SIZE=64

# ------------------ SET SUBSCRIPTION ------------------
az account set --subscription "Astadia Dev"

# ------------------ CREATE RESOURCE GROUP ------------------
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# ------------------ CREATE VNET AND SUBNETS ------------------
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $VM_SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $BASTION_SUBNET_NAME \
  --address-prefix 10.0.2.0/27

# ------------------ CREATE PUBLIC IP FOR BASTION ------------------
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --sku Standard \
  --location $LOCATION

# ------------------ CREATE BASTION HOST ------------------
az network bastion create \
  --name $BASTION_NAME \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --location $LOCATION \
  --public-ip-address $PUBLIC_IP_NAME \
  --sku Basic

# ------------------ CREATE WINDOWS SERVER 2019 VM ------------------
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest" \
  --size $VM_SIZE \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --vnet-name $VNET_NAME \
  --subnet $VM_SUBNET_NAME \
  --os-disk-size-gb $DISK_SIZE \
  --nsg "" \
  --public-ip-address "" \
  --license-type Windows_Server \
  --location $LOCATION

# ------------------ CREATE 2 ADDITIONAL USERS ------------------
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunPowerShellScript \
  --scripts @- <<'EOF'
net user user1 "UserP@ssw0rd1!" /add
net user user2 "UserP@ssw0rd2!" /add
net localgroup "Remote Desktop Users" user1 /add
net localgroup "Remote Desktop Users" user2 /add
EOF
