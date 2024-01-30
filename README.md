# Terraform Templates
This repository will be used as base to start a new terraform project or even used as action to be invoked by a GitHub Action from any other repo

## Repo Folder Structure

```bash
📂.github
  └──📂actions
      └──📂azure-backend
          └──📜action.yaml
      └──📂terraform-apply
          └──📜action.yaml
      └──📂terraform-plan
          └──📜action.yaml
  └──📂workflows
      ├──📜audit.yml
      ├──📜terraform-apply.yml
      ├──📜terraform-deploy.yml
      ├──📜terraform-deply-bash.yml
      └──📜terraform-plan.yml
📂scripts
  ├──📜terraform-apply.tf
  ├──📜terraform-backend-local.tf
  ├──📜terraform-backend.tf
  ├──📜terraform-destoy.tf
  └──📜terraform-plan.tf
📂terraform-main
  ├──📜main.tf
  ├──📜outputs.tf
  └──📜variables.tf
📂terraform-modules
  └──📂module1
      ├──📜main.tf
      ├──📜outputs.tf
      └──📜variables.tf
```

## [Workflows](workflows)
### [terraform-deply-bash](.github/workflows/terraform-deply-bash.yml)
- When using this script to run the terraform, first replace the values of the following variables in the files:
  - [terraform-backend.sh](./scripts/terraform-backend.sh)
  ```bash
  WORKING_DIR=./terraform-live
  ENVIRONMENT=prod

  # Set the desired values for the backend configuration
  LOCATION=eastus
  RESOURCE_GROUP_NAME="rg" #name of the resource group where the storage account with the state files will be saved
  STORAGE_ACCOUNT_NAME="stac" #storage account where the state files will be saved
  CONTAINER_NAME="states" #location optional
  KEY="$ENVIRONMENT.tfstate"
  ```

  - [terraform-plan.sh](./scripts/terraform-plan.sh)
  ```bash
  WORKING_DIR=./terraform-live
  ENVIRONMENT=prod
  STORAGE_ACCOUNT_NAME=stac #storage account where the state files will be saved

  VAR_FILE=$ENVIRONMENT.tfvars
  PLAN_FILE=$ENVIRONMENT.plan
  ```

  - [terraform-apply.sh](./scripts/terraform-apply.sh)
  ```bash
  WORKING_DIR=./terraform-live
  ENVIRONMENT=prod
  PLAN_FILE=$ENVIRONMENT.plan
  STORAGE_ACCOUNT_NAME=stac #storage account where the state files will be saved
  ```
- Make sure that the secrets below are configured and available:
   - AZURE_SP
   - ARM_CLIENT_ID
   - ARM_CLIENT_SECRET
   - ARM_SUBSCRIPTION_ID
   - ARM_TENANT_ID

## Configuring
- Run `docker-compose up --build` to validate if the services are running correctly
- Create an Azure container registry with:
```bash
az group create --name rg-eus-acr-01 --location eastus
az acr create --resource-group rg-eus-acr-01 --name acrleomozzerprod --sku Basic
az acr login --name acrleomozzerprod

az network vnet create --resource-group rg-vnet-eus-spoke-application-01 --name vnet-eus-spoke-application-01
az network vnet subnet create --resource-group rg-vnet-eus-spoke-application-01 --vnet-name vnet-eus-spoke-application-01 --name snet-application-01 --address-prefixes 10.0.16.0/24

docker tag az-docker-monitor_app acrleomozzerprod.azurecr.io/app:latest
docker push acrleomozzerprod.azurecr.io/app:latest

az group create --name rg-eus-app-01 --location eastus

az container create --resource-group rg-eus-app-01 --name app --image acrleomozzerprod.azurecr.io/app:latest --cpu 1 --memory 1 --ports 8080 --vnet vnet-eus-spoke-application-01 --subnet snet-application-01 

az network public-ip create --resource-group rg-eus-app-01 --name pip-eus-apgw-01 --allocation-method Static

az network application-gateway create --name apgw-eus-app-01 --location eastus --resource-group rg-eus-app-01 --capacity 2 --sku Standard_v2 --http-settings-protocol http --public-ip-address pip-eus-apgw-01 --vnet-name vnet-eus-spoke-application-01 --subnet snet-apgw-01 --servers 10.0.0.4 --priority 100 --http-settings-port 8080

az storage account create --resource-group rg-eus-app-01 --name staeusapp --sku Standard_LRS --kind storagev2

az storage account show-connection-string \
  --resource-group rg-eus-monitor-01 \
  --name stacappmon \
  --output table

az storage share create --name prometheus --connection-string "<>"

az storage file upload --share-name prometheus --source ./prometheus/prometheus.yml --path prometheus.yml --connection-string "<>"

az container create -g rg-eus-app-01 --name aci-prometheus-01 --image prom/prometheus:latest --azure-file-volume-share-name prometheus --azure-file-volume-account-name staeusapp --azure-file-volume-account-key "<>" --azure-file-volume-mount-path /etc/prometheus --cpu 1 --memory 1 --ports 9090 --vnet vnet-eus-spoke-application-01 --subnet snet-application-01

az network nsg create --resource-group rg-eus-app-01 --name nsg-eus-app-01

az container restart --resource-group rg-acr-prod --name prometheus --image acrleomozzerprod.azurecr.io/prometheus:latest

az network application-gateway http-listener create \
  --resource-group rg-acr-prod \
  --gateway-name myAppGateway \
  --name prometheus \
  --frontend-ip-name myPublicIP \
  --frontend-port 9090 \
  --protocol Http

docker tag grafana/grafana acrleomozzerprod.azurecr.io/grafana:latest
docker push acrleomozzerprod.azurecr.io/grafana:latest
az container create \
  --resource-group rg-acr-prod \
  --name grafana \
  --image acrleomozzerprod.azurecr.io/grafana:latest \
  --cpu 1 \
  --memory 1 \
  --ports 3000 \
  --ip-address public
```

## References
- https://github.com/evandroferreiras/prometheus_tutorial/tree/master
- https://aristides.dev/monitorando-seus-servidores-com-grafana-e-prometheus/