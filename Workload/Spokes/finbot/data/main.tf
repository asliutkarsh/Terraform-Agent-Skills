# ---------------------------------------------------------------------------------------------------------------------
# FINBOT DATA RESOURCES
# Storage Account for transaction logs, Key Vault for secrets
# ---------------------------------------------------------------------------------------------------------------------

module "data_rg" {
  source = "../../../../modules/resource_group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "storage_account" {
  source = "../../../../modules/data/storage_account"

  name                     = local.storage_account_name
  resource_group_name      = module.data_rg.name
  location                 = module.data_rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags

  depends_on = [module.data_rg]
}

module "key_vault" {
  source = "../../../../modules/data/key_vault"

  name                       = local.key_vault_name
  resource_group_name        = module.data_rg.name
  location                   = module.data_rg.location
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = var.key_vault_soft_delete_days
  purge_protection_enabled   = var.key_vault_purge_protection
  tags                       = local.common_tags

  depends_on = [module.data_rg]
}
