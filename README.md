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
az acr create --resource-group rg-eus-acr-01 --name acrleomozzerprod --sku Basic --admin-enabled true
az acr login --name acrleomozzerprod

docker tag az-docker-monitor_app acrleomozzerprod.azurecr.io/app:latest
docker push acrleomozzerprod.azurecr.io/app:latest
```
- Create a Virtual Network:
```bash
#Also it's possible to use an existing one
az network vnet create --resource-group rg-vnet-eus-spoke-application-01 --name vnet-eus-spoke-application-01
az network vnet subnet create --resource-group rg-vnet-eus-spoke-application-01 --vnet-name vnet-eus-spoke-application-01 --name snet-application-01 --address-prefixes 10.0.16.0/24
```
- Create a {env}.tfvars file
```terraform
//prod.tfvars
vnet_application = {
  resource_group_name = "rg-vnet-eus-spoke-application-01"
  vnet_name           = "vnet-eus-spoke-application-01"
  subnet_name         = "snet-application-01"
}
acg_configuration = {
  name           = "acrleomozzerprod"
  resource_group = "rg-eus-acr-01"
}
```
- Allow the script terraform-backend.sh with `chmod +x ./scripts/terraform-backend.sh`
- Allow the script terraform-plan.sh with `chmod +x ./scripts/terraform-plan.sh`
- Allow the script terraform-apply.sh with `chmod +x ./scripts/terraform-apply.sh`
- Allow the script prometheus-configuration.sh with `chmod +x ./scripts/prometheus-configuration.sh`
- Run `./scripts/terraform-backend.sh`
- Run `./scripts/terraform-plan.sh`
- Check the output
- Run `./scripts/terraform-apply.sh`
- Run `./scripts/prometheus-configuration.sh`

## References
- https://github.com/evandroferreiras/prometheus_tutorial/tree/master
- https://aristides.dev/monitorando-seus-servidores-com-grafana-e-prometheus/
