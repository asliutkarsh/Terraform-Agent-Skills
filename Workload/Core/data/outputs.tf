# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "resource_group_id" {
  description = "Resource group ID"
  value       = module.hub_data_rg.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.hub_data_rg.name
}

# ---------------------------------------------------------------------------------------------------------------------
# STORAGE ACCOUNT OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "storage_account_id" {
  description = "Storage account ID"
  value       = module.hub_storage.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.hub_storage.name
}

output "storage_primary_blob_endpoint" {
  description = "Storage primary blob endpoint"
  value       = module.hub_storage.primary_blob_endpoint
}

# ---------------------------------------------------------------------------------------------------------------------
# LOG ANALYTICS OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "log_analytics_id" {
  description = "Log Analytics workspace ID"
  value       = module.hub_log_analytics.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace GUID for agent configuration"
  value       = module.hub_log_analytics.workspace_id
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY VAULT OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.hub_key_vault.id
}

output "key_vault_uri" {
  description = "Key Vault URI for secret access"
  value       = module.hub_key_vault.vault_uri
}
