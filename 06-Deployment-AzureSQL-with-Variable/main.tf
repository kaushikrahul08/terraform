provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rges" {
    name = "${var.prefix}-RG"
    location = var.location
    tags = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                     =  lower(join(var.prefix, ["s","a"]))
  resource_group_name      = azurerm_resource_group.rges.name
  location                 = azurerm_resource_group.rges.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = lower(join(var.prefix, ["sql","server"]))
  resource_group_name          = azurerm_resource_group.rges.name
  location                     = azurerm_resource_group.rges.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

    tags = var.tags
 
}

resource "azurerm_sql_database" "sqldb" {
  name                = lower(join(var.prefix, ["sql","db"]))
  resource_group_name = azurerm_resource_group.rges.name
  location            = azurerm_resource_group.rges.location
  server_name         = azurerm_sql_server.sqlserver.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.sa.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.sa.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = var.retention
  }

tags = var.tags

}