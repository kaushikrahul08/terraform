provider "azurerm" {
    features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.88.0"
    }
  }

  required_version = ">= 1.1.0"
}

#--[ VARIABLES]--------------------------------------------------------------------------------------------------------------

variable "enable_linux_vm" {
  type        = bool
  description = "Controls the deployment of the linux vm"
  default     = true
}

variable "enable_windows_vm" {
  type        = bool
  description = "Controls the deployment of the linux vm"
  default     = false
}

variable "vm_size" {}
variable "admin_username" {}
variable "admin_password" {}


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

variable "environment" {
  description = "Environment: dev, test, prod"
  default     = "dev"
}

variable "instance_number" {
  description = "Instance Number: 001, 002, ..., 998, 999"
  default     = "001"
}

locals {
  common_tags = {
    environment = "${var.environment}"
    buildby     = "Rahul Sharma"
    createdDate = timestamp()
  }
}


#--[ RESOURCE GROUP (RG) ]--------------------------------------------------------------------------------------------------------------

module "resource_group" {
  source            = "./modules/resource_group"
  global_details    = var.global_details
  instance_number   = var.instance_number
  environment       = var.environment                          
  tags              = local.common_tags
}


#--[ VIRTUAL NETWORK (VNET) ]--------------------------------------------------------------------------------------------------------------

module "virtual_network" {
  source              = "./modules/virtual_network"
  global_details      = var.global_details
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  rg_name            = module.resource_group.rg_names
  depends_on          = [ module.resource_group ]

}

#--[ SUBNETs (SUBNET) ]--------------------------------------------------------------------------------------------------------------

module "subnets" {
  source              = "./modules/subnet"
  global_details      = var.global_details
  rg_name            = module.resource_group.rg_names
  vnet_names          = module.virtual_network.vnet_name
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  depends_on          = [ module.virtual_network ]
}


#--[ NETWORK INTERFACE CARD (NICs) ]--------------------------------------------------------------------------------------------------------------

module "network_interface" {
  source              = "./modules/network_interface"
  global_details      = var.global_details
  rg_name             = module.resource_group.rg_names
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  subnet_ids          = module.subnets.subnet_ids
  depends_on          = [ module.subnets ]
}


#--[ NETWORK SECURITY GROUP  (NSGs) ]--------------------------------------------------------------------------------------------------------------

module "network_groups" {
  source              = "./modules/network_security_group"
  global_details      = var.global_details
  rg_name             = module.resource_group.rg_names
  nic_id              = module.network_interface.nic_ids
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  depends_on          = [ module.resource_group ]
}

#--[ Virtual Machine Windows (VM) ]--------------------------------------------------------------------------------------------------------------

module "windows_vm" {
  count               = var.enable_windows_vm == true ? 1 : 0
  source              = "./modules/virtual_machine_windows"
  global_details      = var.global_details
  rg_name             = module.resource_group.rg_names
  nic_id              = module.network_interface.nic_ids
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  depends_on          = [ module.resource_group,module.network_interface ]
}

#--[ Virtual Machine Windows (VM) ]--------------------------------------------------------------------------------------------------------------

module "linux_vm" {
  count               = var.enable_linux_vm == true ? 1 : 0
  source              = "./modules/virtual_machine_linux"
  global_details      = var.global_details
  rg_name             = module.resource_group.rg_names
  nic_id              = module.network_interface.nic_ids
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  environment         = var.environment              
  instance_number     = var.instance_number  
  tags                = local.common_tags
  depends_on          = [ module.resource_group,module.network_interface ]
}

#--[ VNET Peering ]--------------------------------------------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "peer-eastus-to-westus" {
  name                         = "peer-eastus-${var.environment}-to-westus"
  resource_group_name          = module.resource_group.east_rg
  virtual_network_name         = module.virtual_network.east_vnet
  remote_virtual_network_id    = module.virtual_network.west_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  depends_on                   = [ module.virtual_network,module.resource_group]
}

resource "azurerm_virtual_network_peering" "peer-westus-to-eastus" {
  name                         = "peer-westus-${var.environment}-to-eastus"
  resource_group_name          = module.resource_group.west_rg
  virtual_network_name         = module.virtual_network.west_vnet
  remote_virtual_network_id    = module.virtual_network.east_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  depends_on                   = [ module.virtual_network,module.resource_group]
}


#--[ OUTPUTs ]--------------------------------------------------------------------------------------------------------------
output "subnet_ids" {
  value = module.subnets.subnet_ids
}

output "rg_names" {
  value = module.resource_group.rg_names
}

output "vnet_names" {
  value = module.virtual_network.vnet_name
}

output "vnet_ids" {
  value = module.virtual_network.vnet_id
}
