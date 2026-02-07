output "id" {
  description = "Managed identity ID"
  value       = azurerm_user_assigned_identity.main.id
}

output "name" {
  description = "Managed identity name"
  value       = azurerm_user_assigned_identity.main.name
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.main.principal_id
}

output "client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

output "tenant_id" {
  description = "Tenant ID"
  value       = azurerm_user_assigned_identity.main.tenant_id
}
