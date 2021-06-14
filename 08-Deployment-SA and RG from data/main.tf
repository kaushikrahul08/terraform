provider "azurerm" {
    features {}
}


data "azurerm_resource_group" "rg" {
     name = "WEST-US-RG"
}

resource "azurerm_storage_account" "sa" {
  name                     = "westussa0101"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  }

resource "azurerm_storage_container" "sa" {
  name                  = "tfcontwestus0101"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}