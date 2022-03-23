
variable "resource_group_name" {
  type    = string
  default = "rg_week5"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "vnet" {
  default = "srvs_vnet"
}

variable "address_space" {
  default = "10.0.0.0/16"
}

# variable "cidr_block" {
#     description = "subnet cidr block"
#     type    = list
#     default = ["10.0.1.0/24", "10.0.2.0/24"]
# }
