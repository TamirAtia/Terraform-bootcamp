output "LB_backend_add_pool_id" {
  value = azurerm_lb_backend_address_pool.LB_backend_add_pool.id
}

output "LoadBalacer_ip_address" {
  value = azurerm_public_ip.LB_IP.ip_address
}