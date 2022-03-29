#*****************resource group***************
resource "azurerm_resource_group" "rg_week5" {
  name     = var.resource_group_name
  location = var.location
}
#******************************************************

#*****************Network module***************
module "Network" {
  source = "./modules/Network"

  resource_group_name    = azurerm_resource_group.rg_week5.name
  location               = azurerm_resource_group.rg_week5.location
  virtual_network_name   = var.virtual_network_name
  address_space          = var.address_space
  subnet_private_prefix  = var.subnet_private_prefix
  subnet_public_prefix   = var.subnet_public_prefix
  web_public_ip_name     = var.web_public_ip_name
  postgresql_name_server = var.postgresql_name_server

}
#******************************************************

#*****************LoadBalancer module***************
module "LoadBalancer" {
  source = "./modules/LoadBalancer"

  resource_group_name = azurerm_resource_group.rg_week5.name
  location            = azurerm_resource_group.rg_week5.location
}
#******************************************************

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
      subnet_id                              = module.Network.public_subnet_id
      load_balancer_backend_address_pool_ids = [module.LoadBalancer.LB_backend_add_pool_id]

    }
  }
  depends_on = [
    var.virtual_network_name
  ]
  lifecycle {
    ignore_changes = [instances]
  }
}
#******************************************************

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
#******************************************************

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
    module.Network.DB-nic-id,
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
#******************************************************

