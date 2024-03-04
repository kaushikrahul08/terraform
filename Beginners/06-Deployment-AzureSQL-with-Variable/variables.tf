variable "tags" {
    default = {
    environment = "TEST"
    Buildby     = "Terraform"
    Owner       = "Rahul Sharma"
    Builddate   = "01-06-2021"
}
}

variable  "location" {
    type = string
}

variable "prefix" {
    type    = string

}

variable "address_space" {
    type = string
  }

variable "address_prefixes" {
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

variable "retention" {
    type = string
  
}