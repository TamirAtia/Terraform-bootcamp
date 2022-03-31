
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


variable "admin_username" {
  type        = string
  description = "Admin username for VM"
}

# Defines a variable for administrator password
variable "admin_password" {
  type        = string
  description = "Admin password for VM"
}


variable "postgres_administrator_login" {
  type        = string
  description = "Postgersql name"
}

variable "postgres_administrator_password" {
  type        = string
  description = "Password for Postgersql"
}

variable "num_of_instances" {
  type        = number
  description = "The number of instances for the VM scale-set"
}

variable "myIP_Address" {
  type        = string
  description = "IP address to connect ssh to the VM"
}


variable "okta_org_url" {

}

variable "okta_client_id" {

}

variable "okta_secret" {

}

variable "pg_user" {

}

variable "pg_pass" {

}

variable "okta_key" {

}