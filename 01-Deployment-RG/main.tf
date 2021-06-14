provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rges" {
    name = "WEST-US-RG"
    location = "WEST US"
    tags = {
    environment = "TEST"
    Buildby     = "Rahul Sharma"
    Builddate   = "01-06-2021"
	}
}