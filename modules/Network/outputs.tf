output "public_subnet_id" {
  value = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private_subnet.id
}

output "DB-nic-id" {
  value = azurerm_network_interface.DB-nic.id
}

