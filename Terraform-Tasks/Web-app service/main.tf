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

# Define the Azure resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.rglocation
}

# Define the Azure App Service Plan
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = var.appserviceplan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = var.appserviceplan_sku_tier
    size = var.appserviceplan_sku_size
  }
}
# Define the Azure Web App (Linux)
resource "azurerm_linux_web_app" "web-app" {
  name                = var.web-app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.appserviceplan.id
  site_config {
    always_on = true
  }
}

# Define the Azure Monitor Autoscale Setting

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = var.autoscale_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_app_service_plan.appserviceplan.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      maximum = 5
      minimum = 1
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
