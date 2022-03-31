#*****************resource group***************
resource "azurerm_resource_group" "rg_week5" {
  name     = var.resource_group_name
  location = var.location
}
#******************************************************

#***************** Network module ***************
module "Network" {
  source = "./modules/Network"

  resource_group_name   = azurerm_resource_group.rg_week5.name
  location              = azurerm_resource_group.rg_week5.location
  virtual_network_name  = var.virtual_network_name
  address_space         = var.address_space
  subnet_private_prefix = var.subnet_private_prefix
  subnet_public_prefix  = var.subnet_public_prefix
  myIP_Address          = var.myIP_Address


}
#******************************************************

#***************** LoadBalancer module ***************
module "LoadBalancer" {
  source = "./modules/LoadBalancer"

  resource_group_name = azurerm_resource_group.rg_week5.name
  location            = azurerm_resource_group.rg_week5.location
}
#******************************************************

#***************** ManagedDB module ***************
module "PostgerSql" {
  source = "./modules/PostgreSql"

  resource_group_name             = azurerm_resource_group.rg_week5.name
  location                        = azurerm_resource_group.rg_week5.location
  vnet-ID                         = module.Network.vnet-ID
  private_subnet_id               = module.Network.private_subnet_id
  postgres_administrator_login    = var.postgres_administrator_login
  postgres_administrator_password = var.postgres_administrator_password
}
#******************************************************

#***************** VMSS module ***************
module "VMSS" {
  source = "./modules/VMSS"

  resource_group_name    = azurerm_resource_group.rg_week5.name
  location               = azurerm_resource_group.rg_week5.location
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  num_of_instances       = var.num_of_instances
  public_subnet_id       = module.Network.public_subnet_id
  LB_backend_add_pool_id = module.LoadBalancer.LB_backend_add_pool_id
  virtual_network_name   = var.virtual_network_name

  host_url       = module.LoadBalancer.LoadBalacer_ip_address
  pg_host        = "${module.PostgerSql.azurerm_postgresql_flexible_server_name}.postgres.database.azure.com"
  okta_org_url   = var.okta_org_url
  okta_client_id = var.okta_client_id
  okta_secret    = var.okta_secret
  pg_user        = var.postgres_administrator_login
  pg_pass        = var.postgres_administrator_password
  okta_key       = var.okta_key

}
#******************************************************
