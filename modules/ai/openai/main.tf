# ---------------------------------------------------------------------------------------------------------------------
# AZURE OPENAI SERVICE
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_cognitive_account" "main" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = var.sku_name
  custom_subdomain_name = var.custom_subdomain_name

  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

resource "azurerm_cognitive_deployment" "deployments" {
  for_each = { for d in var.deployments : d.name => d }

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.main.id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.capacity
  }
}
