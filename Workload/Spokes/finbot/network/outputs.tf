# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "resource_group_id" {
  description = "Resource group ID"
  value       = module.network_rg.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.network_rg.name
}

# ---------------------------------------------------------------------------------------------------------------------
# VNET OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "vnet_id" {
  description = "Virtual network ID"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.vnet.subnet_ids
}
