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
    address_space = ["10.190.192.0/22"]
    tags = var.tags
}

resource "azurerm_subnet" "subnetv1" {
    name = "testingsubnet01"
    resource_group_name = azurerm_resource_group.rges.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.190.194.16/28"]
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

resource "azurerm_windows_virtual_machine" "vm" {
    name = "${var.prefix}-VM"
    #availability_set_id = azurerm_availability_set.avset.id
    resource_group_name = azurerm_resource_group.rges.name
    location = var.location
    size = "Standard_F2"
    admin_username      = "adminuser"
    admin_password      = "Welcome@12345"
    network_interface_ids = [azurerm_network_interface.nic.id]
    
    os_disk {
    name            = "${var.prefix}-OSD"
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

resource "azurerm_virtual_machine_extension" "ext" {
  name                 = "${var.prefix}-EXTFORPROJECT"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.8"

settings = <<SETTINGS
    {
		"fileUris": [ "https://csg100320009f275bed.blob.core.windows.net/data/create-webserver-and-deploy-app.ps1"],
		"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File create-webserver-and-deploy-app.ps1"
    }
SETTINGS

}


resource "azurerm_network_security_group" "nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rges.name

  security_rule {
    name                       = "RDP-Allow"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "106.51.108.249"
    destination_address_prefix = "*"
  }

  tags = var.tags
  }
  
  #resource "azurerm_subnet_network_security_group_association" "assign_nsg" {
  #subnet_id                 = azurerm_subnet.subnetv1.id
  #network_security_group_id = azurerm_network_security_group.nsg.id
#}

resource "azurerm_network_interface_security_group_association" "assign_nsg" {
    network_interface_id   = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
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



