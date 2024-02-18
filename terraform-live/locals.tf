locals {
  region_name_standardize = {
    "East US"           = "eus"
    "eastus"            = "eus"
    "east us"           = "eus"
    "West US"           = "wus"
    "North Central US"  = "ncus"
    "South Central US"  = "scus"
    "East US 2"         = "eastus2"
    "West US 2"         = "westus2"
    "Central US"        = "cus"
    "West Central US"   = "wcus"
    "Canada East"       = "canadaeast"
    "Canada Central"    = "canadacentral"
    "West Europe"       = "weu"
    "westeurope"        = "weu"
    "west europe"       = "weu"
    "North Europe"      = "neu"
    "northeurope"       = "neu"
    "UK South"          = "uks"
    "UK West"           = "ukw"
    "France Central"    = "francecentral"
    "France South"      = "francesouth"
    "Germany North"     = "germanynorth"
    "Germany West"      = "germanywest"
    "Switzerland North" = "chnorth"
    "Switzerland West"  = "chwest"
    "Norway East"       = "noeast"
    "Norway West"       = "nowest"
    # Add more mappings as needed
  }
}

locals {
  rg_vnet_name       = "rg-vnet-${local.region_name_standardize[var.default_location]}-spoke-monitoring-01"
  vnet_name          = "vnet-${local.region_name_standardize[var.default_location]}-spoke-monitoring-01"
  vnet_address_space = ["10.140.15.0/26"]

  snet_monitoring_name          = "snet-monitoring-01"
  snet_monitoring_address_space = ["10.140.15.0/28"]

  snet_appgw_name          = "snet-appgw-01"
  snet_appgw_address_space = ["10.140.15.16/28"]

  rg_app_name    = "rg-${local.region_name_standardize[var.default_location]}-app-01"
  ci_app_name_01 = "ci-${local.region_name_standardize[var.default_location]}-app-01"

  rg_monitoring_name  = "rg-${local.region_name_standardize[var.default_location]}-monitor-01"
  sta_monitoring_name = "stacappmon"
  ci_prometheus_name  = "ci-${local.region_name_standardize[var.default_location]}-prometheus-01"
  ci_grafana_name     = "ci-${local.region_name_standardize[var.default_location]}-grafana-01"

  apgw_pip_name         = "pip-${local.region_name_standardize[var.default_location]}-apgw-01"
  pip_allocation_method = "Static"
  apgw_name             = "apgw-${local.region_name_standardize[var.default_location]}-01"

  appgw_frontend_ip_configuration_name = "frontend"
}
