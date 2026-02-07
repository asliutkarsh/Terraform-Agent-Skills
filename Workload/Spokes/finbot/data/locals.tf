# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VALUES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common_tags = {
    Project     = var.project
    Environment = title(var.environment)
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  resource_group_name  = "rg-${var.org}-${var.project}-${var.environment}-${var.location_code}-data-${var.instance}"
  storage_account_name = "st${var.org}${var.project}${var.environment}${var.location_code}${var.instance}"
  key_vault_name       = "kv-${var.org}-${var.project}-${var.environment}-${var.location_code}-${var.instance}"
}
