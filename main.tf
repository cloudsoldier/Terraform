resource "azurerm_resource_group" "terraformrg" {
  name     = local.resource_group_name
  location = local.location  
}

