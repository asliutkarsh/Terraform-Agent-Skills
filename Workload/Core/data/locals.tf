# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VALUES
# All naming logic, computed values, and tag definitions
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Common tags for Hub resources
  common_tags = {
    Project     = "Hub"
    Environment = "Shared-Core"
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  # Resource names following AJFC naming convention
  # Hub format: [ResourceType]-[Org]-[Scope]-[Location]-[Component]-[Instance]
  resource_group_name  = "rg-${var.org}-${var.scope}-${var.location_code}-${var.component}-${var.instance}"
  storage_account_name = "st${var.org}${var.scope}${var.location_code}${var.component}${var.instance}"
  log_analytics_name   = "log-${var.org}-${var.scope}-${var.location_code}-${var.instance}"
  key_vault_name       = "kv-${var.org}-${var.scope}-${var.location_code}-${var.component}-${var.instance}"
}
