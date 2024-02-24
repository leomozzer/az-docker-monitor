#!/bin/bash

WORKING_DIR=./terraform-live
ENVIRONMENT=prod
STORAGE_ACCOUNT_NAME="stactfomonitor"

VAR_FILE=$ENVIRONMENT.tfvars

# Change to the Terraform directory
cd $WORKING_DIR

#Copy provider and backend file create locally to tffiles container
az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file $VAR_FILE \
    --name $VAR_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite