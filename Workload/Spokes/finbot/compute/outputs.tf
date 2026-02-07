output "resource_group_id" {
  description = "Resource group ID"
  value       = module.compute_rg.id
}

output "aks_id" {
  description = "AKS cluster ID"
  value       = module.aks.id
}

output "aks_name" {
  description = "AKS cluster name"
  value       = module.aks.name
}

output "aks_fqdn" {
  description = "AKS FQDN"
  value       = module.aks.fqdn
}

output "kube_config" {
  description = "Kube config"
  value       = module.aks.kube_config
  sensitive   = true
}
