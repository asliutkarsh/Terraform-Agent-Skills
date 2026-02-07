# ---------------------------------------------------------------------------------------------------------------------
# DATA SOURCES
# Reference network component outputs for subnet ID
# ---------------------------------------------------------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_storage_account
    container_name       = var.state_container
    key                  = "spokes/finbot/network.tfstate"
    resource_group_name  = var.state_resource_group
  }
}
