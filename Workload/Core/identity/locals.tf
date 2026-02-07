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
  resource_group_name   = "rg-${var.org}-${var.scope}-${var.location_code}-${var.component}-${var.instance}"
  managed_identity_name = "id-${var.org}-${var.scope}-${var.location_code}-${var.identity_purpose}-${var.instance}"
}
