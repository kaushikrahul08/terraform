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

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "rg_name"{
  type = map(string)
}

variable "nic_id"{
  type = map(string)
}

variable "tags" {}

resource "azurerm_windows_virtual_machine" "vm" {
    for_each              = var.global_details
    name                  = "wvm-${each.value.name}-${var.instance_number}"
    resource_group_name   = lookup(var.rg_name, each.value.name, null)
    location              = each.value.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    admin_password        = var.admin_password
    network_interface_ids = [lookup(var.nic_id, each.value.name, null)]
    
  os_disk {
    name                  = "wvm-osdisk-${each.value.name}-${var.instance_number}"
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}