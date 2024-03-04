provider "azurerm" {
    features {}
}

data "azurerm_resource_group" "rg" {
     name = "WEST-US-RG"
}

resource "azurerm_virtual_network" "vnet" {
    name = "TEST-VNET"
    location = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    address_space = ["10.190.192.0/22"]
    tags = {
	buildtool = "terraform"
	buildby  = "RahulSharma"
	Date   = "01-06-2021"
	}
}

resource "azurerm_subnet" "subnetv1" {
    name = "testingsubnet01"
    resource_group_name = data.azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.190.192.16/28"]
}