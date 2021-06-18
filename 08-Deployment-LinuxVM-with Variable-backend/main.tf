terraform {   
 backend "azurerm" {   
 resource_group_name   = "WEST-US-RG"  
 storage_account_name  = "westussa0101"     
 container_name        = "tfcontwestus0101"     
 key                   = "terraform-dev-linux.tfstate"   
 } 
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rges" {
    name = "${var.prefix}-RG"
    location = var.location
    tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.prefix}-VNET"
    location = var.location
    resource_group_name = azurerm_resource_group.rges.name
    address_space = [var.address_space]
    tags = var.tags
}

resource "azurerm_subnet" "subnetv1" {
    name = "testingsubnet01"
    resource_group_name = azurerm_resource_group.rges.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.address_prefixes]
}

resource "azurerm_public_ip" "pip" {
    name = "${var.prefix}-PIP"
    resource_group_name = azurerm_resource_group.rges.name
    sku = "Standard"
    #sku = "Basic"
    allocation_method = "Static"
    location = azurerm_resource_group.rges.location    
    tags =var.tags
}

resource "azurerm_network_interface" "nic" {
    name = "${var.prefix}-NIC"
    resource_group_name = azurerm_resource_group.rges.name
    location  = azurerm_resource_group.rges.location

    ip_configuration {
        name = "${var.prefix}-IPCONFIG"
        private_ip_address_allocation= "Dynamic"
        subnet_id = azurerm_subnet.subnetv1.id
        public_ip_address_id = azurerm_public_ip.pip.id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    count = 1
    name = "testingvm${count.index}"
    #availability_set_id = azurerm_availability_set.avset.id
    disable_password_authentication = "false"
    resource_group_name = azurerm_resource_group.rges.name
    location = azurerm_resource_group.rges.location
    size = var.size
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    network_interface_ids = [element(azurerm_network_interface.nic.*.id,count.index)]
    
    os_disk {
    name            = "osdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "8"
    version   = "latest"
  }
}

#--- if you need datadisk un-comment below with required count can be changed
#resource "azurerm_managed_disk" "datadisk" {
 #count                = 2
 #name                 = "datadisk_${count.index}"
 #location             = azurerm_resource_group.rges.location
 #resource_group_name  = azurerm_resource_group.rges.name
 #storage_account_type = "Standard_LRS"
 #create_option        = "Empty"
 #disk_size_gb         = "1023"
#}



