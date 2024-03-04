provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rges" {
    name = "${var.prefix}-RG"
    location = var.location
    tags = var.tags
}