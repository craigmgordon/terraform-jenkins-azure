terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# Provider configuration is intentionally minimal.
# Authentication is handled via environment variables in CI/CD:
# ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
provider "azurerm" {
  features {}

  # Optional: uncomment if your organisation requires it.
  # storage_use_azuread = true
}
