terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateYOURORG"
    container_name       = "tfstate"
    key                  = "jenkins/dev/terraform.tfstate"
  }
}
