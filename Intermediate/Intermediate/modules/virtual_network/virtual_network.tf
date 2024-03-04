terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.88.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "environment" {}

# variable "resource_group_name" {
#   type = string
# }

variable "global_details" {
    type = map(object
    ({
    name = string
    location = string
    address_space = string
    subnet        = string
    subnet_type   = string

    }))
}

variable "instance_number" {
  type = string
}

variable "rg_name"{
  type = map(string)
}

variable "tags" {}

resource "azurerm_virtual_network" "vnet" {
    for_each             = var.global_details
    name                 = "vnet-${each.value.name}-${var.environment}-${var.instance_number}"
    resource_group_name  = lookup(var.rg_name, each.value.name, null)
    location             = each.value.location
    address_space        = [each.value.address_space]
    tags                 = var.tags
    
  lifecycle {
      ignore_changes = [
        tags["createdDate"]
      ]
    }

}


#Output
output "vnet_id" {
  value = {for k, v in var.global_details : v.name => azurerm_virtual_network.vnet[k].id}
}

output "vnet_name" {
  value = {for k, v in var.global_details : v.name => azurerm_virtual_network.vnet[k].name}
}

output "east_vnet" {
  value = values(azurerm_virtual_network.vnet)[0].name
}

output "east_vnet_id" {
  value = values(azurerm_virtual_network.vnet)[0].id
}

output "west_vnet" {
  value = values(azurerm_virtual_network.vnet)[1].name
}

output "west_vnet_id" {
  value = values(azurerm_virtual_network.vnet)[1].id
}