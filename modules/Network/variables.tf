variable "resource_group_name" {
  type        = string
  description = "RG Name"
}

variable "location" {
  type        = string
  description = "RG Location"
}

variable "virtual_network_name" {
  type        = string
  description = "Vnet name"
}

variable "address_space" {
  type        = string
  description = "Virtual network address space(CIDR)"
}

variable "subnet_public_prefix" {
  type        = string
  description = "Public subnet"
}

variable "subnet_private_prefix" {
  type        = string
  description = "Private subnet"
}

variable "web_public_ip_name" {
  type        = string
  description = "Public IP name"
}

variable "postgresql_name_server" {
  type        = string
  description = "Postgersql name"
}

