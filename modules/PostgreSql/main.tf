
# ************ Create Managed PostgreSql *************
resource "azurerm_private_dns_zone" "Dns-Zone" {
  name                = "postgres-flexiable.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  depends_on = [var.resource_group_name]

}
# ************************************************

# ************ Link to my Vnet ************
resource "azurerm_private_dns_zone_virtual_network_link" "Vnet-link" {
  name                  = "vnet-zone.com"
  private_dns_zone_name = azurerm_private_dns_zone.Dns-Zone.name
  virtual_network_id    = var.vnet-ID
  resource_group_name   = var.resource_group_name
  depends_on = [var.resource_group_name,azurerm_private_dns_zone.Dns-Zone,var.vnet-ID]

}
# ************************************************

# ************ Create postgresql flexible ************
resource "azurerm_postgresql_flexible_server" "DataBase" {
  name                   = "postgresql-flexible-server"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "12"
  delegated_subnet_id    = var.private_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.Dns-Zone.id
  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password
  zone                   = "1"
  storage_mb = 32768
  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.Vnet-link, var.private_subnet_id]
}


resource "azurerm_postgresql_flexible_server_database" "postgresql_flexible_server_database" {
  name      = "postgres-db"
  server_id = azurerm_postgresql_flexible_server.DataBase.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_server_configuration" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.DataBase.id
  value     = "off"
}

# ************************************************