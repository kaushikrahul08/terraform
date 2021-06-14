variable "tags" {
    default = {
    environment = "TEST"
    Buildby     = "Rahul Sharma"
    Builddate   = "01-06-2021"
}
}

variable  "location" {
    type = string
}

variable "prefix" {
    type    = string

}