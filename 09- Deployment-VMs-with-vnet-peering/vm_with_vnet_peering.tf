provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rges" {
    for_each = var.vm_details
    name     = "rg-${each.value.name}"
    location = each.value.location
    tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    for_each = var.vm_details
    name = "vnet-${each.value.name}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location = each.value.location
    address_space = [each.value.address_space]
    tags = var.tags
}

resource "azurerm_subnet" "subnet" {
    for_each = var.vm_details
    name = "snet-${each.value.name}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    virtual_network_name = azurerm_virtual_network.vnet[each.key].name
    address_prefixes = [each.value.subnet]
}

resource "azurerm_network_interface" "nic" {
    for_each = var.vm_details
    name = "nic-${each.value.name}"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location  = each.value.location
    ip_configuration {
        name = "ipconfic"
        private_ip_address_allocation= "Dynamic"
        subnet_id = azurerm_subnet.subnet[each.key].id
    }
}

resource "azurerm_network_security_group" "nsg" {
    for_each = var.vm_details
    name = "nsg-${each.value.name}"
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

  tags = var.tags
  }

resource "azurerm_network_interface_security_group_association" "assign_nsg" {
    for_each = var.vm_details
    network_interface_id   = azurerm_network_interface.nic[each.key].id
    network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_windows_virtual_machine" "vm" {
    for_each = var.vm_details
    name = "vm-${each.value.name}-001"
    resource_group_name = azurerm_resource_group.rges[each.key].name
    location  = each.value.location
    size = var.vm_size
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    network_interface_ids = [azurerm_network_interface.nic[each.key].id]
    
    os_disk {
    name            = "osdisk-${var.prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
