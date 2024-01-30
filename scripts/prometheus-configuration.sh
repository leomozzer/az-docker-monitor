#!/bin/bash

# Retrieve the container instance IP address and handle potential errors
ci_prometheus=$(az container show --resource-group rg-eus-monitor-01 \
  --name monitor-eus-prometheus-01 --query ipAddress.ip --output tsv | sed 's/ //g')
ci_prometheus="${ci_prometheus%%[[:space:]]}"  # Remove leading spaces
ci_prometheus="${ci_prometheus%[[:space:]]}"   # Remove trailing spaces
if [[ $? -ne 0 ]]; then
  echo "Error retrieving IP address from container instance. Exiting."
  exit 1
fi

cat <<EOL > prometheus/prometheus-tf.yml
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: "app"
    static_configs:
      - targets: ["10.0.0.4:8080"]
        labels:
          app: "app"
  - job_name: "prometheus"
    scrape_interval: 10s
    static_configs:
      - targets: ["$ci_prometheus:9090"]
EOL

st_connection_string=$(az storage account show-connection-string \
  --resource-group rg-eus-monitor-01 \
  --name stacappmon \
  --output tsv)

az storage file upload --share-name prometheus --source ./prometheus/prometheus-tf.yml --path prometheus.yml --connection-string $st_connection_string

az container restart --resource-group rg-eus-monitor-01 --name monitor-eus-prometheus-01