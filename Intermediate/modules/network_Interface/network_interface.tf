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

variable "subnet_ids"{
  type = map(string)
}

variable "rg_name"{
  type = map(string)
}

variable "tags" {}

resource "azurerm_network_interface" "nic" {
    for_each                    = var.global_details
    name                        = "nic-${each.value.name}-${var.environment}-${var.instance_number}"
    resource_group_name         = lookup(var.rg_name, each.value.name, null)
    location                    = each.value.location
    tags                        = var.tags
    
    ip_configuration {
        name = "ipconfic"
        private_ip_address_allocation= "Dynamic"
        subnet_id = lookup(var.subnet_ids, each.value.name, null)
    }

    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}

#Output
output "nic_ids" {
  value = {for k, v in var.global_details : v.name => azurerm_network_interface.nic[k].id}
}