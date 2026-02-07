# ---------------------------------------------------------------------------------------------------------------------
# HUB DATA RESOURCES
# Resource Group, Storage Account, Log Analytics, Key Vault
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUP
# ---------------------------------------------------------------------------------------------------------------------
module "hub_data_rg" {
  source = "../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# STORAGE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------
module "hub_storage" {
  source = "../../../modules/data/storage_account"

  name                     = local.storage_account_name
  resource_group_name      = module.hub_data_rg.name
  location                 = module.hub_data_rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags

  depends_on = [module.hub_data_rg]
}

# ---------------------------------------------------------------------------------------------------------------------
# LOG ANALYTICS WORKSPACE
# ---------------------------------------------------------------------------------------------------------------------
module "hub_log_analytics" {
  source = "../../../modules/data/log_analytics"

  name                = local.log_analytics_name
  resource_group_name = module.hub_data_rg.name
  location            = module.hub_data_rg.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.common_tags

  depends_on = [module.hub_data_rg]
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY VAULT
# ---------------------------------------------------------------------------------------------------------------------
module "hub_key_vault" {
  source = "../../../modules/data/key_vault"

  name                       = local.key_vault_name
  resource_group_name        = module.hub_data_rg.name
  location                   = module.hub_data_rg.location
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = var.key_vault_soft_delete_days
  purge_protection_enabled   = var.key_vault_purge_protection
  tags                       = local.common_tags

  depends_on = [module.hub_data_rg]
}
