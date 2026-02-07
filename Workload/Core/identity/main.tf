# ---------------------------------------------------------------------------------------------------------------------
# HUB IDENTITY RESOURCES
# Resource Group and User Managed Identity for GitHub Actions OIDC
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP
# ---------------------------------------------------------------------------------------------------------------------
module "hub_identity_rg" {
  source = "../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# USER MANAGED IDENTITY
# Used for GitHub Actions OIDC authentication
# ---------------------------------------------------------------------------------------------------------------------
module "github_managed_identity" {
  source = "../../../modules/identity/managed_identity"

  name                = local.managed_identity_name
  resource_group_name = module.hub_identity_rg.name
  location            = module.hub_identity_rg.location
  tags                = local.common_tags

  depends_on = [module.hub_identity_rg]
}
