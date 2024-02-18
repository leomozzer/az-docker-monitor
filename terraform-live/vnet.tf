resource "azurerm_resource_group" "rg_vnet_monitoring" {
  name     = local.rg_vnet_name
  location = var.default_location
}

resource "azurerm_virtual_network" "vnet_monitoring" {
  name                = local.vnet_name
  location            = var.default_location
  resource_group_name = azurerm_resource_group.rg_vnet_monitoring.name
  address_space       = local.vnet_address_space
}

resource "azurerm_subnet" "subnet_appgw" {
  name                 = local.snet_appgw_name
  resource_group_name  = azurerm_resource_group.rg_vnet_monitoring.name
  virtual_network_name = azurerm_virtual_network.vnet_monitoring.name
  address_prefixes     = local.snet_appgw_address_space
}

resource "azurerm_subnet" "subnet_monitoring" {
  name                 = local.snet_monitoring_name
  resource_group_name  = azurerm_resource_group.rg_vnet_monitoring.name
  virtual_network_name = azurerm_virtual_network.vnet_monitoring.name
  address_prefixes     = local.snet_monitoring_address_space
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}
