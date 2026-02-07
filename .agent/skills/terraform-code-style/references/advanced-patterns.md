# Advanced Terraform Patterns

Advanced coding patterns for complex Terraform scenarios.

## Dynamic Blocks

Use `dynamic` blocks to generate repeated nested blocks:

```hcl
resource "azurerm_network_security_group" "example" {
  name                = local.nsg_name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.example.name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

## Complex Locals Transformations

### Flattening Nested Structures

```hcl
locals {
  # Flatten subnets from multiple VNets
  all_subnets = flatten([
    for vnet_key, vnet in var.vnets : [
      for subnet in vnet.subnets : {
        vnet_name   = vnet.name
        subnet_name = subnet.name
        subnet_cidr = subnet.address_prefix
        key         = "${vnet_key}-${subnet.name}"
      }
    ]
  ])
  
  # Convert to map for resource iteration
  subnet_map = {
    for subnet in local.all_subnets :
    subnet.key => subnet
  }
}
```

### Conditional Resource Creation

```hcl
locals {
  # Create private endpoints only for enabled storage accounts
  storage_private_endpoints = {
    for key, storage in var.storage_accounts :
    key => storage
    if storage.enable_private_endpoint == true
  }
}

resource "azurerm_private_endpoint" "storage" {
  for_each = local.storage_private_endpoints
  
  name                = "pe-${each.value.name}"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  
  private_service_connection {
    name                           = "psc-${each.value.name}"
    private_connection_resource_id = azurerm_storage_account.example[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
```

## Module Patterns

### Output All Module Attributes

```hcl
# modules/resource_group/outputs.tf
output "resource_group" {
  description = "Complete resource group object"
  value       = azurerm_resource_group.this
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.this.location
}
```

### Optional Nested Blocks

```hcl
# modules/storage/variables.tf
variable "network_rules" {
  description = "Network rules for storage account"
  type = object({
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
    bypass                     = optional(list(string), ["AzureServices"])
  })
  default = null
}

# modules/storage/main.tf
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
      bypass                     = network_rules.value.bypass
    }
  }
}
```

## Validation Patterns

### Complex Validations

```hcl
variable "storage_config" {
  description = "Storage account configuration"
  type = object({
    name                     = string
    account_tier            = string
    account_replication_type = string
  })
  
  validation {
    condition = contains(
      ["Standard", "Premium"],
      var.storage_config.account_tier
    )
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
  
  validation {
    condition = (
      var.storage_config.account_tier == "Premium" ?
      contains(["LRS", "ZRS"], var.storage_config.account_replication_type) :
      contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_config.account_replication_type)
    )
    error_message = "Premium tier only supports LRS and ZRS replication."
  }
  
  validation {
    condition     = length(var.storage_config.name) <= 24
    error_message = "Storage account name must be 24 characters or less."
  }
}
```

### Cross-Variable Validation

```hcl
variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
  
  validation {
    condition     = !var.enable_private_endpoint || var.subnet_id != null
    error_message = "subnet_id is required when enable_private_endpoint is true."
  }
}
```

## Data Source Patterns

### Conditional Data Sources

```hcl
# Only query existing VNet if not creating new one
data "azurerm_virtual_network" "existing" {
  count = var.create_new_vnet ? 0 : 1
  
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_rg
}

locals {
  vnet_id = var.create_new_vnet ? (
    azurerm_virtual_network.new[0].id
  ) : (
    data.azurerm_virtual_network.existing[0].id
  )
}
```

### Multiple Data Source Queries

```hcl
# Query all storage accounts in a resource group
data "azurerm_storage_account" "existing" {
  for_each = toset(var.existing_storage_account_names)
  
  name                = each.value
  resource_group_name = var.resource_group_name
}

locals {
  # Create map of storage account properties
  existing_storage_configs = {
    for name, storage in data.azurerm_storage_account.existing :
    name => {
      id                       = storage.id
      primary_blob_endpoint    = storage.primary_blob_endpoint
      primary_connection_string = storage.primary_connection_string
    }
  }
}
```

## Error Handling

### Precondition Checks

```hcl
resource "azurerm_private_endpoint" "example" {
  # Ensure subnet exists before creating private endpoint
  lifecycle {
    precondition {
      condition     = var.subnet_id != null && var.subnet_id != ""
      error_message = "Private endpoint requires a valid subnet_id."
    }
  }
  
  name                = local.private_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  
  # ... rest of configuration
}
```

### Postcondition Checks

```hcl
data "azurerm_key_vault" "existing" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  
  lifecycle {
    postcondition {
      condition     = self.soft_delete_enabled
      error_message = "Key Vault must have soft delete enabled for production use."
    }
  }
}
```

## Resource Dependencies

### Implicit vs Explicit Dependencies

```hcl
# Implicit dependency (preferred when possible)
resource "azurerm_virtual_network" "example" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.example.name  # Implicit
  location            = var.resource_group_location
  address_space       = var.vnet_address_space
}

# Explicit dependency (use when order matters but no direct reference)
resource "azurerm_network_watcher" "example" {
  name                = local.network_watcher_name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.example.name
  
  depends_on = [
    azurerm_virtual_network.example  # Explicit - must exist first
  ]
}
```

### Module Dependency Chains

```hcl
module "resource_group" {
  source = "../../../Modules/resource_group"
  
  resource_group_name     = local.resource_group_name
  resource_group_location = var.resource_group_location
  tags                    = local.common_tags
}

module "virtual_network" {
  source = "../../../Modules/networking"
  
  vnet_name           = local.vnet_name
  resource_group_name = module.resource_group.resource_group_name
  
  depends_on = [module.resource_group]
}

module "storage_account" {
  source = "../../../Modules/storage"
  
  storage_account_name = local.storage_account_name
  resource_group_name  = module.resource_group.resource_group_name
  subnet_id           = module.virtual_network.subnet_ids["private-endpoints"]
  
  depends_on = [
    module.resource_group,
    module.virtual_network
  ]
}
```

## Performance Optimization

### Efficient For Expressions

```hcl
# ✅ Good - Single pass
locals {
  enabled_subnets = {
    for key, subnet in var.subnets :
    key => {
      name          = subnet.name
      address_prefix = subnet.address_prefix
      nsg_id        = subnet.enable_nsg ? azurerm_network_security_group.nsg[key].id : null
    }
    if subnet.enabled
  }
}

# ❌ Bad - Multiple passes
locals {
  enabled_subnet_names = [
    for key, subnet in var.subnets :
    subnet.name if subnet.enabled
  ]
  
  enabled_subnet_prefixes = [
    for key, subnet in var.subnets :
    subnet.address_prefix if subnet.enabled
  ]
}
```

### Minimize Data Source Queries

```hcl
# ✅ Good - Query once, use multiple times
data "azurerm_client_config" "current" {}

locals {
  current_tenant_id      = data.azurerm_client_config.current.tenant_id
  current_subscription_id = data.azurerm_client_config.current.subscription_id
  current_object_id      = data.azurerm_client_config.current.object_id
}

# ❌ Bad - Multiple identical queries
data "azurerm_client_config" "for_kv" {}
data "azurerm_client_config" "for_storage" {}
data "azurerm_client_config" "for_rbac" {}
```