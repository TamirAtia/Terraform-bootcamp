#*****************resource group***************
resource "azurerm_resource_group" "rg_week5" {
  name     = var.resource_group_name
  location = var.location
}


#***********************vnet*******************
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = [var.address_space]
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name
}


#****** Create a subnet public and privet************
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg_week5.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_public_prefix]
}


resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg_week5.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_private_prefix]
}

#***********public ip for web and LB************
resource "azurerm_public_ip" "web_public_ip" {
  name                = var.web_public_ip_name
  resource_group_name = azurerm_resource_group.rg_week5.name
  location            = azurerm_resource_group.rg_week5.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.rg_week5
  ]
}

resource "azurerm_public_ip" "LB_IP" {
  name                = "Public-IP-LB"
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.rg_week5]
}

#***********load Balancer configuration*********
resource "azurerm_lb" "LoadBalancer" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name
  depends_on = [
    azurerm_public_ip.LB_IP
  ]
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.LB_IP.id
  }
}

resource "azurerm_lb_backend_address_pool" "LB_backend_add_pool" {
  loadbalancer_id = azurerm_lb.LoadBalancer.id
  name            = "LB_BackEndAddressPool"
  depends_on = [
    azurerm_lb.LoadBalancer
  ]

}

resource "azurerm_lb_probe" "ProbeA" {
  resource_group_name = azurerm_resource_group.rg_week5.name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = "probeA"
  port                = 8080
  protocol            = "Tcp"
  depends_on = [
    azurerm_lb.LoadBalancer
  ]
}

resource "azurerm_lb_rule" "RuleA" {
  resource_group_name            = azurerm_resource_group.rg_week5.name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.LB_backend_add_pool.id]
}

# *******************scale set virtual machine configuration*************
resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {
  name                            = "scale-set"
  resource_group_name             = azurerm_resource_group.rg_week5.name
  location                        = azurerm_resource_group.rg_week5.location
  sku                             = "Standard_F2"
  instances                       = 2
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  upgrade_mode                    = "Automatic"
  disable_password_authentication = false

  custom_data = filebase64("AppBash.sh")

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "scaleset-interface"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.public_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.LB_backend_add_pool.id]
      
    }
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  lifecycle { 
    ignore_changes = [instances]
  }
}


#***************NSG for the application*****************
resource "azurerm_network_security_group" "App-NSG" {
  name                = "myNetworkSecurityGroupApp"
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name
  depends_on          = [azurerm_resource_group.rg_week5, azurerm_subnet.public_subnet]

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
#******************autoscaling*************
resource "azurerm_monitor_autoscale_setting" "AutoScaling" {
  name                = "AutoScaling"
  resource_group_name = azurerm_resource_group.rg_week5.name
  location            = azurerm_resource_group.rg_week5.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.scale_set.id

  profile {
    name = "Profile"

    capacity {
      default = 2
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale_set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "linux.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale_set.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

#*************associate between the subnet & NSG
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.App-NSG.id
  depends_on = [
    azurerm_network_security_group.App-NSG
  ]
}

#**********network interface for database***********
resource "azurerm_network_interface" "DB-nic" {
  name                = "${var.postgresql_name_server}-nic"
  location            = azurerm_resource_group.rg_week5.location
  resource_group_name = azurerm_resource_group.rg_week5.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# *******************scale set virtual machine configuration*************
resource "azurerm_linux_virtual_machine" "database" {
  name                            = var.postgresql_name_server
  resource_group_name             = azurerm_resource_group.rg_week5.name
  location                        = azurerm_resource_group.rg_week5.location
  size                            = "Standard_F2"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.DB-nic.id,
  ]

  custom_data = filebase64("DbBash.sh")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


