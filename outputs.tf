output "VMPassword" {
  value       = var.admin_password
  sensitive   = true
  description = "VM password"
}
