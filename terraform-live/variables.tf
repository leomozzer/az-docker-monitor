variable "default_location" {
  type    = string
  default = "eastus"
}

variable "vnet_application" {
  type = object({
    resource_group_name = string
    vnet_name           = string
    subnet_name         = string
  })
  default = {
    resource_group_name = ""
    vnet_name           = ""
    subnet_name         = ""
  }
}

variable "acg_configuration" {
  type = object({
    name           = string
    resource_group = string
  })
}
