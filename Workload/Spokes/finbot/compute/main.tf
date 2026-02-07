# ---------------------------------------------------------------------------------------------------------------------
# FINBOT COMPUTE RESOURCES
# AKS cluster for application workloads
# ---------------------------------------------------------------------------------------------------------------------

module "compute_rg" {
  source = "../../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "aks" {
  source = "../../../../modules/compute/aks"

  name                = local.aks_name
  resource_group_name = module.compute_rg.name
  location            = module.compute_rg.location
  dns_prefix          = local.aks_dns_prefix
  kubernetes_version  = var.kubernetes_version
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  subnet_id           = data.terraform_remote_state.network.outputs.subnet_ids["snet-app"]
  enable_auto_scaling = var.aks_enable_autoscaling
  min_count           = var.aks_min_count
  max_count           = var.aks_max_count
  tags                = local.common_tags

  depends_on = [module.compute_rg]
}
