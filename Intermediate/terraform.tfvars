environment    = "dev"
admin_username = "adminuser"
admin_password = "Welcome@12345"
vm_size        = "Standard_B2s"
instance_number = "001"
global_details = {
    "eastus" = {
        name = "eastus"
        location = "eastus"
        address_space = ("10.190.192.0/22")
        subnet = ("10.190.194.16/28")
        subnet_type = "external"
        }
    "westus" = {
        name = "westus"
        location = "westus"
        address_space = ("10.189.192.0/22")
        subnet = ("10.189.194.16/28")
        subnet_type = "intenal"
        }
    }
