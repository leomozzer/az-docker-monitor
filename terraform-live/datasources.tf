# data "azurerm_virtual_network" "vnet_application" {
#   resource_group_name = var.vnet_application["resource_group_name"]
#   name                = var.vnet_application["vnet_name"]
# }

# data "azurerm_subnet" "subnet_application" {
#   resource_group_name  = var.vnet_application["resource_group_name"]
#   virtual_network_name = var.vnet_application["vnet_name"]
#   name                 = var.vnet_application["subnet_name"]
# }

data "azurerm_container_registry" "acr" {
  name                = var.acg_configuration["name"]
  resource_group_name = var.acg_configuration["resource_group"]
}
