#***********************vnet*******************
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}
#******************************************************

#****** Create a subnet public and privet************
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_public_prefix]
}


resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_private_prefix]
}
#******************************************************

#******************public ip for *****************
resource "azurerm_public_ip" "web_public_ip" {
  name                = var.web_public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  depends_on = [
    var.resource_group_name
  ]
}
#******************************************************

#***************NSG for the application*****************
resource "azurerm_network_security_group" "App-NSG" {
  name                = "myNetworkSecurityGroupApp"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [var.resource_group_name, azurerm_subnet.public_subnet]

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" //need to add IP
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Port_8080"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#******************************************************

#*************associate between the public subnet & NSG**********
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.App-NSG.id
  depends_on = [
    azurerm_network_security_group.App-NSG
  ]
}

#******************************************************

#**********network interface for database***********
resource "azurerm_network_interface" "DB-nic" {
  name                = "${var.postgresql_name_server}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
#******************************************************
