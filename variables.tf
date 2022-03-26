
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

variable "webAppPrefix" {
  description = "The prefix which should be used for all resources connected to the web app."
  default     = "WA"
}

variable "DBPrefix" {
  description = "The prefix which should be used for all resources connected to the database."
  default     = "DB"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM"
}

# Defines a variable for administrator password
variable "admin_password" {
  type        = string
  description = "Admin password for VM"
}

variable "vm_size" {
  type        = string
  description = "Virtual machine size"
}

variable "postgresql_name_server" {
  type = string
  description = "Postgersql name"
}

# variable "username_db" {
#   type        = string
#   description = "Username PostgreSQL"
# }

# variable "password_db" {
#   type        = string
#   description = "Password  PostgreSQL "
# }

# variable "postgresql_firewall_name" {
#   type = string
#   description = "PostgreSQL firewall name"
# }

