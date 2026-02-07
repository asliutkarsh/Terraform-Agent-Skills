output "id" {
  description = "Azure OpenAI resource ID"
  value       = azurerm_cognitive_account.main.id
}

output "name" {
  description = "Azure OpenAI resource name"
  value       = azurerm_cognitive_account.main.name
}

output "endpoint" {
  description = "Azure OpenAI endpoint URL"
  value       = azurerm_cognitive_account.main.endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_cognitive_account.main.primary_access_key
  sensitive   = true
}

output "deployment_ids" {
  description = "Map of deployment names to IDs"
  value       = { for k, v in azurerm_cognitive_deployment.deployments : k => v.id }
}
