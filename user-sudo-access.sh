# ---------------------- SET FIXED VALUES ----------------------
RESOURCE_GROUP="vm-rdp-test"
LOCATION="eastus"
VNET_NAME="vm-rdp-vnet"
VM_SUBNET_NAME="vm-subnet"
BASTION_SUBNET_NAME="AzureBastionSubnet"
VM_NAME="rdp-vm"
BASTION_NAME="bastion-host"
PUBLIC_IP_NAME="bastion-pip"
ADMIN_USERNAME="azureadmin"
ADMIN_PASSWORD="P@ssw0rd1234!"  # Meets Azure complexity

# ---------------------- CREATE RESOURCE GROUP ----------------------
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# ---------------------- CREATE VNET AND SUBNETS ----------------------
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $VM_SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $BASTION_SUBNET_NAME \
  --address-prefix 10.0.2.0/27

# ---------------------- CREATE PUBLIC IP FOR BASTION ----------------------
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $PUBLIC_IP_NAME \
  --sku Standard \
  --location $LOCATION

# ---------------------- CREATE BASTION HOST ----------------------
az network bastion create \
  --name $BASTION_NAME \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --location $LOCATION \
  --public-ip-address $PUBLIC_IP_NAME \
  --sku Basic

# ---------------------- CREATE WINDOWS VM (NO PUBLIC IP) ----------------------
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Win2022Datacenter \
  --size Standard_D2s_v3 \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --vnet-name $VNET_NAME \
  --subnet $VM_SUBNET_NAME \
  --nsg "" \
  --public-ip-address "" \
  --license-type Windows_Server \
  --location $LOCATION
