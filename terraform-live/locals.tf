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
  rg_app_name    = "rg-${local.region_name_standardize[var.default_location]}-app-01"
  ci_app_name_01 = "ci-${local.region_name_standardize[var.default_location]}-app-01"

  snet_monitoring = "snet-monitor-01"

  rg_monitoring_name  = "rg-${local.region_name_standardize[var.default_location]}-monitor-01"
  sta_monitoring_name = "stacappmon"
  ci_prometheus_name  = "ci-${local.region_name_standardize[var.default_location]}-prometheus-01"

  apgw_pip_name         = "pip-${local.region_name_standardize[var.default_location]}-apgw-01"
  pip_allocation_method = "Static"
  apgw_name             = "apgw-${local.region_name_standardize[var.default_location]}-01"

  appgw_frontend_ip_configuration_name = "frontend"
}
