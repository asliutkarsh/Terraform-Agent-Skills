# ---------------------------------------------------------------------------------------------------------------------
# FINBOT NETWORK RESOURCES
# VNet with application and data subnets
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP
# ---------------------------------------------------------------------------------------------------------------------
module "network_rg" {
  source = "../../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# VIRTUAL NETWORK
# ---------------------------------------------------------------------------------------------------------------------
module "vnet" {
  source = "../../../../modules/network/vnet"

  name                = local.vnet_name
  resource_group_name = module.network_rg.name
  location            = module.network_rg.location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags

  depends_on = [module.network_rg]
}
