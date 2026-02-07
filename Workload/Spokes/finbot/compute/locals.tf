locals {
  common_tags = {
    Project     = var.project
    Environment = title(var.environment)
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  resource_group_name = "rg-${var.org}-${var.project}-${var.environment}-${var.location_code}-compute-${var.instance}"
  aks_name            = "aks-${var.org}-${var.project}-${var.environment}-${var.location_code}-${var.instance}"
  aks_dns_prefix      = "${var.project}-${var.environment}"
}
