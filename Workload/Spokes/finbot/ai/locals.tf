locals {
  common_tags = {
    Project     = var.project
    Environment = title(var.environment)
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  resource_group_name = "rg-${var.org}-${var.project}-${var.environment}-${var.location_code}-ai-${var.instance}"
  openai_name         = "oai-${var.org}-${var.project}-${var.environment}-${var.location_code}-${var.instance}"
}
