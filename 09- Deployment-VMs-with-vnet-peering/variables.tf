variable "tags" {
    default = {
    environment = "TEST"
    Buildby     = "Rahul Sharma"
    Builddate   = "15-02-2024"
}
}


variable "vm_details" {
    type = map(object
    ({
    name = string
    location = string
    address_space = string
    subnet        = string
    }))
default = { 
    "eastus" = {
        name = "eastus"
        location = "eastus"
        address_space = ("10.190.192.0/22")
        subnet = ("10.190.194.16/28")
        }
    "westus" = {
        name = "westus"
        location = "westus"
        address_space = ("10.189.192.0/22")
        subnet = ("10.189.194.16/28")

        }

    }
}


variable  "location" {
    default = "westus"
}


variable "vnet_prefix" {
  type = list
  default = [
    {
      range    = "10.190.192.0/22"
      name     = "vnet-east"
      location = "eastus"
    },
    {
      range    = "10.189.192.0/22"
      name     = "vnet-west"
      location = "westus"
    }
   ]
}

variable "subnet_prefix" {
  type = list
  default = [
    {
      range    = "10.190.194.16/28"
      name     = "snet-public"
    },
    {
      range      = "10.189.194.16/28"
      name     = "snet-private"
    }
   ]
}



variable "prefix" {
    type    = list
default = "001"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "address_space_east" {
    type = string
  }
variable "address_space_west" {
    type = string
  }


variable "address_prefixes_public" {
    type = string
  
}
variable "address_prefixes_private" {
    type = string
  
}

variable "admin_username" {
    type = string
  
}

variable "admin_password" {
    type = string
  
}

variable "source_ip" {
    type = string
  
}