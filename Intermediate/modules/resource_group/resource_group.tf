terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.88.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "environment" {
  
}
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

variable "tags" {}

resource "azurerm_resource_group" "resource_group" {
    for_each = var.global_details
    name     = "rg-${each.value.name}-${var.environment}-${var.instance_number}"
    location = each.value.location
    tags     = var.tags
  
  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}


#Output

output "rg_names" {
  value = {for k, v in var.global_details : v.name => azurerm_resource_group.resource_group[k].name}
}

output "east_rg" {
  value = values(azurerm_resource_group.resource_group)[0].name
}

output "west_rg" {
  value = values(azurerm_resource_group.resource_group)[1].name
}