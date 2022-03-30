variable "resource_group_name" {
  type        = string
  description = "RG Name"
}

variable "location" {
  type        = string
  description = "RG Location"
}

variable "vnet-ID" {
   description = "Virtual network ID"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet id"
}

variable "postgres_administrator_login" {
  type        = string
  description = "Postgersql name"
}

variable "postgres_administrator_password" {
  type        = string
  description = "Password for Postgersql"
}





