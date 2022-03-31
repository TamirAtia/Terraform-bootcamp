
variable "resource_group_name" {
  type        = string
  description = "RG Name"
}

variable "location" {
  type        = string
  description = "RG Location"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
}

variable "num_of_instances" {
  type = number
  description = "The number of instances for the VM scale-set"
}

variable "public_subnet_id" {
  type        = string
  description = "The ID of the Public Subnet"
}

variable "LB_backend_add_pool_id" {
  type = string
  description = "Load Balancer pool ID"
}

variable "virtual_network_name" {
  type = string
  description = "Virtual Network name"
}

variable "host_url" {
  
}

variable "pg_host" {
  
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
  type = string
}