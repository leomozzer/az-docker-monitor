#############################
# Monitoring Infrastructure #
#############################

resource "azurerm_resource_group" "rg_monitoring" {
  name     = local.rg_monitoring_name
  location = var.default_location
}

resource "azurerm_storage_account" "stac" {
  resource_group_name      = azurerm_resource_group.rg_monitoring.name
  name                     = local.sta_monitoring_name
  location                 = var.default_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_storage_share" "prometheus_fs" {
  name                 = "prometheus"
  storage_account_name = azurerm_storage_account.stac.name
  quota                = 10
}

resource "azurerm_container_group" "prometheus" {
  resource_group_name = azurerm_resource_group.rg_monitoring.name
  name                = local.ci_prometheus_name
  location            = var.default_location
  os_type             = "Linux"
  subnet_ids          = [azurerm_subnet.subnet_monitoring.id]
  ip_address_type     = "Private"

  container {
    name   = "prometheus"
    image  = "prom/prometheus:latest"
    cpu    = "1.5"
    memory = "1"

    volume {
      name                 = "prometheus"
      mount_path           = "/etc/prometheus"
      share_name           = azurerm_storage_share.prometheus_fs.name
      storage_account_name = azurerm_storage_account.stac.name
      storage_account_key  = azurerm_storage_account.stac.primary_access_key
    }

    ports {
      port     = 9090
      protocol = "TCP"
    }
  }
}

resource "azurerm_container_group" "grafana" {
  resource_group_name = azurerm_resource_group.rg_monitoring.name
  name                = local.ci_grafana_name
  location            = var.default_location
  os_type             = "Linux"
  subnet_ids          = [azurerm_subnet.subnet_monitoring.id]
  ip_address_type     = "Private"

  container {
    name   = "grafana"
    image  = "grafana/grafana:latest"
    cpu    = "1.5"
    memory = "1"

    environment_variables = {
      GF_SECURITY_ADMIN_USER     = "admin"
      GF_SECURITY_ADMIN_PASSWORD = "admin"
      GF_USERS_ALLOW_SIGN_UP     = false
    }

    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
}

############################
# Monitored Infrastructure #
############################

resource "azurerm_resource_group" "rg_app_01" {
  name     = local.rg_app_name
  location = var.default_location
}

resource "azurerm_container_group" "app_01" {
  #Deploying app in the same subnet as the monitoring
  resource_group_name = azurerm_resource_group.rg_app_01.name
  name                = local.ci_app_name_01
  location            = var.default_location
  os_type             = "Linux"
  subnet_ids          = [azurerm_subnet.subnet_monitoring.id]
  ip_address_type     = "Private"

  image_registry_credential {
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
    server   = data.azurerm_container_registry.acr.login_server
  }

  container {
    name   = "app"
    image  = "${data.azurerm_container_registry.acr.login_server}/app:latest"
    cpu    = "1.5"
    memory = "1"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}

##########################
# Accessing applications #
##########################

resource "azurerm_public_ip" "apgw_pip" {
  name                = local.apgw_pip_name
  resource_group_name = azurerm_resource_group.rg_monitoring.name
  location            = azurerm_resource_group.rg_monitoring.location
  allocation_method   = local.pip_allocation_method
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "apgw" {
  name                = local.apgw_name
  resource_group_name = azurerm_resource_group.rg_monitoring.name
  location            = azurerm_resource_group.rg_monitoring.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  frontend_ip_configuration {
    name                 = local.appgw_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.apgw_pip.id
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  #app-01 routing
  frontend_port {
    name = "application"
    port = 8080
  }

  backend_address_pool {
    name         = "application"
    ip_addresses = [azurerm_container_group.app_01.ip_address]
  }

  backend_http_settings {
    name                  = "application"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "application"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "application"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "application"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "application"
    backend_address_pool_name  = "application"
    backend_http_settings_name = "application"
  }

  #Prometheus routing
  frontend_port {
    name = "prometheus"
    port = 9090
  }

  backend_address_pool {
    name         = "prometheus"
    ip_addresses = [azurerm_container_group.prometheus.ip_address]
  }

  backend_http_settings {
    name                  = "prometheus"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 9090
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "prometheus"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "prometheus"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "prometheus"
    priority                   = 110
    rule_type                  = "Basic"
    http_listener_name         = "prometheus"
    backend_address_pool_name  = "prometheus"
    backend_http_settings_name = "prometheus"
  }

  #Grafana routing
  frontend_port {
    name = "grafana"
    port = 3000
  }

  backend_address_pool {
    name         = "grafana"
    ip_addresses = [azurerm_container_group.grafana.ip_address]
  }

  backend_http_settings {
    name                  = "grafana"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "grafana"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "grafana"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "grafana"
    priority                   = 120
    rule_type                  = "Basic"
    http_listener_name         = "grafana"
    backend_address_pool_name  = "grafana"
    backend_http_settings_name = "grafana"
  }
}
