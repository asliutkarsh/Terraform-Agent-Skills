# ---------------------------------------------------------------------------------------------------------------------
# FINBOT AI RESOURCES
# Azure OpenAI for financial model
# ---------------------------------------------------------------------------------------------------------------------

module "ai_rg" {
  source = "../../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "openai" {
  source = "../../../../modules/ai/openai"

  name                          = local.openai_name
  resource_group_name           = module.ai_rg.name
  location                      = module.ai_rg.location
  sku_name                      = var.openai_sku
  custom_subdomain_name         = local.openai_name
  public_network_access_enabled = var.openai_public_access
  deployments                   = var.openai_deployments
  tags                          = local.common_tags

  depends_on = [module.ai_rg]
}
