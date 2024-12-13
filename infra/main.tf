locals {
  tags = {
    azd-env-name : var.environment_name
    "com.save.provisioner" = "terraform"
    "com.save.responsible" = "brent.rutherford@savethechildren.org.au"
  }
  sha                = base64encode(sha256("lms-poc-save${var.environment_name}${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token     = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  counting_app_name  = "counting-${local.resource_token}"
  dashboard_app_name = "dashboard-${local.resource_token}"
}
# ------------------------------------------------------------------------------------------------------
# Deploy resource Group
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.location

  tags = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy log analytics
# ------------------------------------------------------------------------------------------------------
module "loganalytics" {
  source         = "./modules/loganalytics"
  location       = var.location
  rg_name        = azurerm_resource_group.rg.name
  tags           = azurerm_resource_group.rg.tags
  resource_token = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy key vault
# ------------------------------------------------------------------------------------------------------
module "keyvault" {
  source         = "./modules/keyvault"
  location       = var.location
  principal_id   = var.principal_id
  rg_name        = azurerm_resource_group.rg.name
  tags           = azurerm_resource_group.rg.tags
  resource_token = local.resource_token
  secrets = [
    {
      name  = "secretname"
      value = "secretvalue"
    }
  ]
}

module "container_apps" {
  source                         = "./modules/container_apps"
  resource_group_name            = azurecaf_name.rg_name.result
  location                       = var.location
  container_app_environment_name = var.environment_name

/*  
    container_app_environment = {
    name                = var.environment_name
    resource_group_name = azurecaf_name.rg_name.result
  }
*/
  container_apps = {
    counting = {
      name          = local.counting_app_name
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "countingservicetest1"
            memory = "0.5Gi"
            cpu    = 0.25
            image  = "docker.io/hashicorp/counting-service:0.0.2"
            env = [
              {
                name  = "PORT"
                value = "9001"
              }
            ]
          },
        ]
      }

      ingress = {
        allow_insecure_connections = true
        external_enabled           = true
        target_port                = 9001
        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
    },
    dashboard = {
      name          = local.dashboard_app_name
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "testdashboard"
            memory = "1Gi"
            cpu    = 0.5
            image  = "docker.io/hashicorp/dashboard-service:0.0.4"
            env = [
              {
                name  = "PORT"
                value = "8080"
              },
              {
                name  = "COUNTING_SERVICE_URL"
                value = "http://${local.counting_app_name}"
              }
            ]
          },
        ]
      }

      ingress = {
        allow_insecure_connections = false
        target_port                = 8080
        external_enabled           = true

        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
      }
      identity = {
        type = "SystemAssigned"
      }
    },
  }
  log_analytics_workspace_name = local.resource_token
}
