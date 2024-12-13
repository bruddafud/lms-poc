#Set the terraform required version, and Configure the Azure Provider.Use local storage

# Configure the Azure Provider
terraform {
  required_version = ">= 1.2, < 2.0.0"
  backend "azurerm" {
    resource_group_name  = "pe-devops"
    storage_account_name = "plearthtfstate"
    container_name       = "plearthtfstate"
    use_azuread_auth     = false
    key                  = "terraform.lmspocstate"
  }
  required_providers {
    azurerm = {
      version = "~>3.98"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.24"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
