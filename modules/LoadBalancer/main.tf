#***********public ip for LB************
resource "azurerm_public_ip" "LB_IP" {
  name                = "Public-IP-LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku = "Standard"
  depends_on          = [var.resource_group_name]
}
#**************************************************

#***********load Balancer configuration*********
resource "azurerm_lb" "LoadBalancer" {
  name                = "LoadBalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku = "Standard"
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
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = "probeA"
  port                = 8080
  protocol            = "Tcp"
  depends_on = [
    azurerm_lb.LoadBalancer
  ]
}

resource "azurerm_lb_rule" "RuleA" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.LB_backend_add_pool.id]
   disable_outbound_snat = true
}


resource "azurerm_lb_rule" "ssh" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.LB_backend_add_pool.id]
  disable_outbound_snat = true
}

resource "azurerm_lb_outbound_rule" "http" {
  resource_group_name     = var.resource_group_name
  loadbalancer_id         = azurerm_lb.LoadBalancer.id
  name                    = "http"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.LB_backend_add_pool.id
  frontend_ip_configuration {
    name = "PublicIPAddress"
  }

}
#************************************************************************************************************