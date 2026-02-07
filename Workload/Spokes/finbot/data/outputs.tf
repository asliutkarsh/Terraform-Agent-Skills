output "resource_group_id" {
  description = "Resource group ID"
  value       = module.data_rg.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.data_rg.name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage_account.name
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.key_vault.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.vault_uri
}
