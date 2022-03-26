# resource "azurerm_postgresql_server" "postgres" {
#   name                = var.postgresql_name_server
#   location            = azurerm_resource_group.rg_week5.location
#   resource_group_name = azurerm_resource_group.rg_week5.name

#   administrator_login          = var.username_db
#   administrator_login_password = var.password_db

#   sku_name   = "GP_Gen5_4"
#   version    = "9.6"
#   storage_mb = 5120

#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false
#   auto_grow_enabled            = true

#   ssl_enforcement_enabled          = false
#   depends_on = [
#     azurerm_resource_group.rg_week5
#   ]

# }

# resource "azurerm_postgresql_firewall_rule" "postgresql_firewall" {
#   name                = var.postgresql_firewall_name
#   resource_group_name = azurerm_resource_group.rg_week5
#   server_name         = azurerm_postgresql_server.postgres
#   start_ip_address    = 
#   end_ip_address      =
#   depends_on = [
#     azurerm_resource_group.rg_week5
#   ]
# }