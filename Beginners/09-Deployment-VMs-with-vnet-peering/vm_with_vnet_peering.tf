provider "azurerm" {
    features {}
}

locals {
  common_tags = {
    environment = "${var.environment}"
    buildby     = "Rahul Sharma"
    createdDate = timestamp()
  }
}

resource "azurerm_resource_group" "rges" {
    for_each = var.vm_details
    name     = "rg-${each.value.name}-${var.environment}-${var.postfix}"
    location = each.value.location
    tags = local.common_tags
    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

resource "azurerm_virtual_network" "vnet" {
    for_each = var.vm_details
    name = "vnet-${each.value.name}-${var.environment}-${var.postfix}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location = each.value.location
    address_space = [each.value.address_space]
    tags = local.common_tags
    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}

resource "azurerm_subnet" "subnet" {
    for_each = var.vm_details
    name = "snet-${each.value.name}-${var.environment}-${var.postfix}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    virtual_network_name = azurerm_virtual_network.vnet[each.key].name
    address_prefixes = [each.value.subnet]
}

resource "azurerm_network_interface" "nic" {
    for_each = var.vm_details
    name = "nic-${each.value.name}-${var.environment}-${var.postfix}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location  = each.value.location
    tags = local.common_tags
    ip_configuration {
        name = "ipconfic"
        private_ip_address_allocation= "Dynamic"
        subnet_id = azurerm_subnet.subnet[each.key].id
    }
    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}

resource "azurerm_network_security_group" "nsg" {
    for_each = var.vm_details
    name = "nsg-${each.value.name}-${var.environment}-${var.postfix}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location  = each.value.location

  security_rule {
    name                       = "RDP-Allow"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.source_ip
    destination_address_prefix = "*"
  }

    tags = local.common_tags
    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "assign_nsg" {
    for_each = var.vm_details
    network_interface_id      = azurerm_network_interface.nic[each.key].id
    network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_windows_virtual_machine" "vm" {
    for_each              = var.vm_details
    name                  = "vm-${each.value.name}-${var.postfix}"
    resource_group_name   = azurerm_resource_group.rges[each.key].name
    location              = each.value.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    admin_password        = var.admin_password
    network_interface_ids = [azurerm_network_interface.nic[each.key].id]
    
    os_disk {
    name                  = "osdisk-${var.environment}-${var.postfix}"
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = local.common_tags
  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}

#--[ Peering WEST SPOKE <-> USA EAST  ]--------------------------------------------------------------------------------------------------


resource "azurerm_virtual_network_peering" "peer-hub-spoke-eastus" {
  for_each = { 
    for k,v in azurerm_virtual_network.vnet  : k => v
    }

  name                         = "peer-east-to-${each.key}"
  resource_group_name          = "rg-eastus-dev-001"
  virtual_network_name         = azurerm_virtual_network.vnet[0].name
  remote_virtual_network_id    = each.value.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  depends_on = [
     azurerm_virtual_network.vnet
  ]
}



#Output
output "east_vnet_name" {
  value       = element(values(azurerm_virtual_network.vnet), 0)["name"]
}

output "west_vnet_name" {
  value       = element(values(azurerm_virtual_network.vnet), 1)["name"]
}

output "east_vnet_id" {
  value       = element(values(azurerm_virtual_network.vnet), 0)["id"]
}

output "west_vnet_id" {
  value       = element(values(azurerm_virtual_network.vnet), 1)["id"]
}