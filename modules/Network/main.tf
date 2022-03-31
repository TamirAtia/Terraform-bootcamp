#*********************** Declaring Vnet *******************
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}
#******************************************************

#*************** Declaring a public and Web Tier NSG ************

#****** Declaring a public subnet************
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_public_prefix]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
#******************************************************

#*************** NSG for the Web Tier *****************
resource "azurerm_network_security_group" "Web-Tier-NSG" {
  name                = "Web_Tier"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [var.resource_group_name, azurerm_subnet.public_subnet]

  security_rule {
    name                       = "Port_SSH_Allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.myIP_Address
    destination_address_prefix = "*"

  }
  security_rule {
    name                       = "Port_8080_Allow"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "blockAll"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#******************************************************

#************* associate between the public subnet & NSG **********
resource "azurerm_subnet_network_security_group_association" "nsg_app_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.Web-Tier-NSG.id
  depends_on = [
    azurerm_network_security_group.Web-Tier-NSG
  ]
}
#******************************************************

#************************************************************************************************************


#*************** Declaring a private subnet and Data Tier NSG ************

#****** Declaring a public subnet************
resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_private_prefix]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
#******************************************************


#***************NSG for the Data Tier*****************
resource "azurerm_network_security_group" "Data-Tier-NSG" {
  name                = "Data-Tier"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [var.resource_group_name, azurerm_subnet.private_subnet]

    security_rule {
    name                       = "port_5432_Allow"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "5432"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}
#******************************************************

#*************associate between the private subnet & NSG**********
resource "azurerm_subnet_network_security_group_association" "nsg_db_association" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.Data-Tier-NSG.id
   depends_on = [
    azurerm_network_security_group.Data-Tier-NSG
  ]
}

#******************************************************

#************************************************************************************************************