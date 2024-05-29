terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name = var.rgname
  location= var.rglocation
}
resource "azurerm_container_registry" "acr" {
  name = var.container_registry_name
  location = azurerm_resource_group.rg.location
  resource_group_name =azurerm_resource_group.rg.name
   sku = var.registry_sku
   admin_enabled = var.admin_enabled
    /*georeplications {
      location = var.rglocation
    }*/
}