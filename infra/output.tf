output "AZURE_KEY_VAULT_ENDPOINT" {
  value     = module.keyvault.AZURE_KEY_VAULT_ENDPOINT
  sensitive = true
}

output "REACT_APP_WEB_BASE_URL" {
  value = module.web.URI
}

output "AZURE_LOCATION" {
  value = var.location
}

output "APPLICATIONINSIGHTS_CONNECTION_STRING" {
  value     = module.applicationinsights.APPLICATIONINSIGHTS_CONNECTION_STRING
  sensitive = true
}