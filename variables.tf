variable "tags" {
    default = {
    environment = "TEST"
    Buildby     = "Rahul Sharma"
    Builddate   = "24-07-2020"
}
}

variable  "location" {
    default = "Central US"
    type = string
}

variable "prefix" {
    default = "CenUS"
    type    = string
}