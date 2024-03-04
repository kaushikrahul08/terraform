environment    = "dev"
admin_username = "adminuser"
admin_password = "Welcome@12345"
vm_size        = "Standard_B2s"
source_ip      = "122.171.102.142"
postfix        = "001"
vm_details = {
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

