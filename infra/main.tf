resource "azurerm_resource_group" "project" {
  name     = "rg-bnp-${var.project_suffix}"
  location = var.location
}
resource "azurerm_mssql_server" "bnp" {
  name                          = "sql-bnp-${var.project_suffix}"
  resource_group_name           = azurerm_resource_group.project.name
  location                      = azurerm_resource_group.project.location
  version                       = "12.0"
  administrator_login           = var.sql_admin
  administrator_login_password  = var.sql_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
}
output "sql_server" {
  value = azurerm_mssql_server.bnp.fully_qualified_domain_name
}
output "resource_group" {
  value = azurerm_resource_group.project.name
}
