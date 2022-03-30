output "VMPassword" {
  value       = azurerm_linux_virtual_machine_scale_set.scale_set.admin_password
  sensitive   = true
  description = "VM password"
}
