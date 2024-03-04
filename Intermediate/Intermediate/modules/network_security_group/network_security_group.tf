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

variable "nic_id"{
  type = map(string)
}

variable "tags" {}

resource "azurerm_network_security_group" "network_security_group" {
    for_each                    = var.global_details
    name                        = "nsg-${each.value.name}-${var.environment}-${var.instance_number}"
    resource_group_name         = lookup(var.rg_name, each.value.name, null)
    location                    = each.value.location
    tags                        = var.tags
}

resource "azurerm_network_interface_security_group_association" "assign_nsg" {
    for_each = var.global_details
    network_interface_id      = lookup(var.nic_id, each.value.name, null)
    network_security_group_id = azurerm_network_security_group.network_security_group[each.key].id
}


# Outputs
output "nsg_names" {
  value = {for k, v in var.global_details : v.name => azurerm_network_security_group.network_security_group[k].name}
}