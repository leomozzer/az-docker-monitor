#!/bin/bash

CI_PROMETHEUS_NAME="ci-eus-prometheus-01"
CI_PROMETHEUS_RG="rg-eus-monitor-01"
ST_MONITORING="stacappmon"

CI_APP_01_NAME="ci-eus-app-01"
CI_APP_RG="rg-eus-app-01"


# Retrieve the container instance IP address and handle potential errors
CI_PROMETHEUS_IP=$(az container show --resource-group $CI_PROMETHEUS_RG  \
  --name $CI_PROMETHEUS_NAME --query ipAddress.ip --output tsv | sed 's/ //g')
CI_PROMETHEUS_IP="${CI_PROMETHEUS_IP%%[[:space:]]}"  # Remove leading spaces
CI_PROMETHEUS_IP="${CI_PROMETHEUS_IP%[[:space:]]}"   # Remove trailing spaces

# Retrieve the container instance IP address and handle potential errors
CI_APP_01_IP=$(az container show --resource-group $CI_APP_RG  \
  --name $CI_APP_01_NAME --query ipAddress.ip --output tsv | sed 's/ //g')
CI_APP_01_IP="${CI_APP_01_IP%%[[:space:]]}"  # Remove leading spaces
CI_APP_01_IP="${CI_APP_01_IP%[[:space:]]}"   # Remove trailing spaces

if [[ $? -ne 0 ]]; then
  echo "Error retrieving IP address from container instance. Exiting."
  exit 1
fi

cat <<EOL > prometheus/prometheus.yml
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: "app_01"
    static_configs:
      - targets: ["$CI_APP_01_IP:8080"]
        labels:
          app: "app"
  - job_name: "prometheus"
    scrape_interval: 10s
    static_configs:
      - targets: ["$CI_PROMETHEUS_IP:9090"]
EOL

ST_CONNECTION_STRING=$(az storage account show-connection-string \
  --resource-group $CI_PROMETHEUS_RG  \
  --name $ST_MONITORING \
  --output tsv)

az storage file upload --share-name prometheus --source ./prometheus/prometheus.yml --path prometheus.yml --connection-string $ST_CONNECTION_STRING

az container restart --resource-group $CI_PROMETHEUS_RG  --name $CI_PROMETHEUS_NAME