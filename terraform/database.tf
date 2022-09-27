resource "azurerm_sql_server" "sqlserver" {
  name                         = "my-sql-server"
  resource_group_name          = azurerm_resource_group.database.name
  location                     = azurerm_resource_group.database.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "epool" {
  name                = "test-epool"
  resource_group_name = azurerm_resource_group.database.name
  location            = azurerm_resource_group.database.location
  server_name         = azurerm_sql_server.sqlserver.name
  license_type        = "LicenseIncluded"
  max_size_gb         = 756

  sku {
    name     = "BasicPool"
    tier     = "Basic"
    family   = "Gen4"
    capacity = 4
  }

  per_database_settings {
    min_capacity = 0.25
    max_capacity = 4
  }
}

resource "azurerm_mssql_database" "db" {
  name           = "acctest-db-d"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  elastic_pool_id       = azurerm_mssql_elasticpool.epool.id
  sku_name              = "ElasticPool"
  zone_redundant = true
}