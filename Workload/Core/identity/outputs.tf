# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "resource_group_id" {
  description = "Resource group ID"
  value       = module.hub_identity_rg.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.hub_identity_rg.name
}

# ---------------------------------------------------------------------------------------------------------------------
# MANAGED IDENTITY OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "managed_identity_id" {
  description = "Managed identity resource ID"
  value       = module.github_managed_identity.id
}

output "managed_identity_principal_id" {
  description = "Principal ID for RBAC assignments"
  value       = module.github_managed_identity.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID for OIDC configuration in GitHub Actions"
  value       = module.github_managed_identity.client_id
}

output "managed_identity_tenant_id" {
  description = "Tenant ID for OIDC configuration"
  value       = module.github_managed_identity.tenant_id
}
