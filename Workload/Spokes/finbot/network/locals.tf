# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VALUES
# Spoke naming: [ResourceType]-[Org]-[Project]-[Env]-[Location]-[Component]-[Instance]
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common_tags = {
    Project     = var.project
    Environment = title(var.environment)
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  resource_group_name = "rg-${var.org}-${var.project}-${var.environment}-${var.location_code}-network-${var.instance}"
  vnet_name           = "vnet-${var.org}-${var.project}-${var.environment}-${var.location_code}-${var.instance}"
}
