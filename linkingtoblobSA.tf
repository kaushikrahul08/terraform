terraform {
backend "azurerm" {
resource_group_name = "demo-terraform-rg"
storage_account_name = "SAFORTF"
container_name = "appservice"
key = "KEY"
}
}
