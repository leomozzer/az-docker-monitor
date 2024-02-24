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
- Make sure you're logged with az cli
- Allow the script terraform-backend.sh with `chmod +x ./scripts/terraform-backend.sh`
- Create the prod.tfvars (or the respective environment like dev.tfvars, test.tfvars, etc)
```terraform
//prod.tfvars
#optional to add existing vnet
# vnet_application = {
#   resource_group_name = "rg-vnet-eus-spoke-application-01"
#   vnet_name           = "vnet-eus-spoke-application-01"
#   subnet_name         = "snet-application-01"
# }
acg_configuration = {
  name           = "<container-registry-name>"
  resource_group = "rg-eus-acr-01"
}
```
- Allow the script terraform-plan.sh with `chmod +x ./scripts/terraform-save-tfvars.sh`, or upload the file directly in the container
- Run the script `./scripts/terraform-save-tfvars.sh`
- Run `docker-compose up --build` to validate if the services are running correctly
- Create an Azure container registry with:
```bash
az group create --name rg-eus-acr-01 --location eastus
az acr create --resource-group rg-eus-acr-01 --name <container-registry-name> --sku Basic --admin-enabled true
az acr login --name <container-registry-name>

docker tag az-docker-monitor_app <container-registry-name>.azurecr.io/app:latest
docker push <container-registry-name>.azurecr.io/app:latest
```
- Allow the script terraform-plan.sh with `chmod +x ./scripts/terraform-plan.sh`
- Allow the script terraform-apply.sh with `chmod +x ./scripts/terraform-apply.sh`
- Allow the script prometheus-configuration.sh with `chmod +x ./scripts/prometheus-configuration.sh`
- Run `./scripts/terraform-plan.sh`
- Check the output
- Run `./scripts/terraform-apply.sh`
- Run `./scripts/prometheus-configuration.sh`
- Access the Application Gateway Public IP
  - Port 8080 to access the app
  - Port 9090 to access Prometheus
  - Port 3000 to access Grafana
- Create a Virtual Network (optional):
```bash
#Also it's possible to use an existing one
az network vnet create --resource-group rg-vnet-eus-spoke-monitoring-01 --name vnet-eus-spoke-monitoring-01
az network vnet subnet create --resource-group rg-vnet-eus-spoke-monitoring-01 --vnet-name vnet-eus-spoke-monitoring-01 --name snet-monitoring-01 --address-prefixes 10.140.15.0/26
```

## References
- https://github.com/evandroferreiras/prometheus_tutorial/tree/master
- https://aristides.dev/monitorando-seus-servidores-com-grafana-e-prometheus/
