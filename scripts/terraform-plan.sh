#!/bin/bash

WORKING_DIR=./terraform-live
ENVIRONMENT=prod
STORAGE_ACCOUNT_NAME="stactfomonitor"

VAR_FILE=$ENVIRONMENT.tfvars
PLAN_FILE=$ENVIRONMENT.plan

# Check if required environment variables are set
if [[ -z "$ENVIRONMENT" || -z "$STORAGE_ACCOUNT_NAME" ]]; then
  echo "Error: Please set the required environment variables: ENVIRONMENT and STORAGE_ACCOUNT_NAME"
  exit 1
fi

# Check if the blob exists using az storage blob exists command
az storage blob exists \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --container-name "$ENVIRONMENT-tf-files" \
  --name $VAR_FILE

# Get the exit code from the previous command
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  echo "Error: Blob $ENVIRONMENT.tfvars not found in container $ENVIRONMENT-tf-files"
  exit 1
fi

# Change to the Terraform directory
cd $WORKING_DIR

#Run terraform formating
terraform fmt

az storage blob download \
    --file provider.tf \
    --name provider.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

az storage blob download \
    --file backend.tf \
    --name backend.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

 az storage blob download \
    --file $ENVIRONMENT.tfvars \
    --name $ENVIRONMENT.tfvars \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

# Initialize Terraform (if not already initialized)
terraform init -reconfigure

# Run Terraform plan and save the output to a plan file
terraform plan -var-file=$VAR_FILE -out=$PLAN_FILE
echo "Terraform plan completed"

az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file $PLAN_FILE \
    --name $PLAN_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file $VAR_FILE \
    --name $VAR_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

# Optionally, you can print the plan to the console
# terraform show -json tfplan | jq '.'
