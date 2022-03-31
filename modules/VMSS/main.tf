# *******************scale set virtual machine configuration*************
resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {
  name                            = "scale-set"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard_F2"
  instances                       = var.num_of_instances
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  upgrade_mode                    = "Automatic"
  disable_password_authentication = false

  custom_data = base64encode(templatefile("AppBash.tftpl",local.vars))

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
      subnet_id                              = var.public_subnet_id
      load_balancer_backend_address_pool_ids = [var.LB_backend_add_pool_id]

    }
  }
  depends_on = [
    var.virtual_network_name
  ]
  lifecycle {
    ignore_changes = [instances]
  }
}
# ****************************************************************

#****************** autoscaling setting *************
resource "azurerm_monitor_autoscale_setting" "AutoScaling" {
  name                = "AutoScaling"
  resource_group_name = var.resource_group_name
  location            = var.location
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
# ****************************************************************