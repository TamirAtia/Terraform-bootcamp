resource "azurerm_resource_group" "rg_week5" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name
}

# subnet public
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg_week5.name
  address_prefixes     = ["10.0.0.0/24"]
}
# subnet private
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg_week5.name
  address_prefixes     = ["10.0.1.0/24"]
}
