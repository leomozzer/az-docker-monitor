#!/bin/bash

WORKING_DIR=./terraform-live
ENVIRONMENT=prod

# Set the desired values for the backend configuration
LOCATION=eastus
RESOURCE_GROUP_NAME="rg-eus-tfstate-monitoring"
STORAGE_ACCOUNT_NAME="stactfomonitor"
CONTAINER_NAME="states"
KEY="$ENVIRONMENT.tfstate"

cd $WORKING_DIR

az group create --location $LOCATION --resource-group $RESOURCE_GROUP_NAME
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --kind StorageV2 --encryption-services blob --access-tier Cool --allow-blob-public-access false

# Retrieve the storage account key using the Azure CLI
account_key=$(az storage account keys list -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME --query '[0].value' -o tsv)

az storage container create --name states --account-name $STORAGE_ACCOUNT_NAME --account-key $account_key
az storage container create --name plans --account-name $STORAGE_ACCOUNT_NAME --account-key $account_key
# 
az storage container create --name $ENVIRONMENT-tf-files --account-name $STORAGE_ACCOUNT_NAME --account-key $account_key

# Wait for 60 seconds
sleep 60

# Create the backend.tf file
cat <<EOL > backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP_NAME"
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "$KEY"
  }
}
EOL

echo "backend.tf file has been created with the specified configuration."

cat <<EOL > provider.tf
provider "azurerm" {
  features {

  }
}
EOL

#Copy provider and backend file create locally to tffiles container
az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file provider.tf \
    --name provider.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite \
    --account-key $account_key

az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file backend.tf \
    --name backend.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite \
    --account-key $account_key