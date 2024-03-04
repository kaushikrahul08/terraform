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

variable "vnet_names"{
  type = map(string)
}

variable "tags" {}


resource "azurerm_subnet" "subnet" {
    for_each = var.global_details
    name = "snet-${each.value.name}-${var.environment}-${each.value.subnet_type}"
    resource_group_name  = lookup(var.rg_name, each.value.name, null)
    virtual_network_name = lookup(var.vnet_names, each.value.name, null)
    address_prefixes = [each.value.subnet]
}


#Output
output "subnet_ids" {
  value = {for k, v in var.global_details : v.name => azurerm_subnet.subnet[k].id}
}