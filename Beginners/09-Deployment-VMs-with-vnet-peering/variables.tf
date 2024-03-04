variable "environment" {
  
}
variable "vm_details" {
    type = map(object
    ({
    name = string
    location = string
    address_space = string
    subnet        = string
    }))
}


variable "postfix" {
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

variable "source_ip" {
    type = string
  
}