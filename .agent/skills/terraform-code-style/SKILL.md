---
name: terraform-code-style
description: Apply Terraform coding standards including file structure, naming conventions, formatting rules, and module patterns. Use when writing new Terraform code, refactoring existing code, creating modules, or reviewing Terraform files for style compliance. Triggers include code creation, module development, style validation, or file organization.
---

# Terraform Code Style

Enforce consistent Terraform coding standards for maintainability and collaboration.

## File Structure Standards

### Required Files

Every Terraform component (in `Workload/`) **MUST** contain the following files, even if empty (for future extensibility):

1.  `main.tf` - Primary resources and module calls (NO hardcoded values).
2.  `variables.tf` - Input variable definitions.
3.  `outputs.tf` - Output value definitions.
4.  `providers.tf` - Provider configuration and versions.
5.  `locals.tf` - Complex logic, naming conventions, and constant values.
6.  `backend.tf` - Remote state configuration.
7.  `data.tf` - Data sources (create file even if empty).
8.  `.tflint.hcl` - Linter configuration.

### File Purpose & Rules

-   **`main.tf`**:
    -   Contains **ONLY** resource definitions and module calls.
    -   **STRICT RULE**: No hardcoded strings or numbers. Every value must come from `var.*` or `local.*`.
-   **`locals.tf`**:
    -   Place all hardcoded values, naming logic, SKU definitions, and tag merging here.
-   **`data.tf`**:
    -   Must exist. Use for `data` blocks. If none needed yet, keep empty for future reference.
-   **`.tflint.hcl`**:
    -   Must be present for local linting.

**Never use:** `variable.tf` (wrong), `output.tf` (wrong)

## Naming Conventions

### Resources

**Format:** `azurerm_<resource_type>_<descriptive_name>`

```hcl
# ✅ Good
resource "azurerm_resource_group" "hub_network" {
  name     = local.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.hub_network.name
}

# ❌ Bad
resource "azurerm_resource_group" "rg" {  # Too generic
  ...
}

resource "azurerm_virtual_network" "this" {  # Non-descriptive
  ...
}
```

### Variables

**Use snake_case:**

```hcl
# ✅ Good
variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

# ❌ Bad
variable "resourceGroupLocation" {  # camelCase
  ...
}

variable "Location" {  # PascalCase
  ...
}
```

### Locals

**Use snake_case with descriptive prefixes:**

```hcl
locals {
  # Common tags
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
  
  # Resource names
  resource_group_name = "rg-${var.org}-${var.scope}-${var.location}-${var.component}-${var.instance}"
  vnet_name          = "vnet-${var.org}-${var.scope}-${var.location}-${var.instance}"
  
  # Computed values
  filtered_subnets = [
    for subnet in var.subnets : subnet
    if subnet.enabled
  ]
}
```

## Variable Definitions

### Required Fields

Every variable must have:

```hcl
variable "example" {
  description = "Clear description of the variable"  # Required
  type        = string                               # Required
  default     = "value"                             # Optional
  
  validation {                                       # Optional but recommended
    condition     = length(var.example) > 0
    error_message = "Example cannot be empty"
  }
}
```

### Type Specifications

Use explicit types:

```hcl
# ✅ Good - Explicit types
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnet_names" {
  description = "List of subnet names"
  type        = list(string)
}

variable "vnet_config" {
  description = "Virtual network configuration"
  type = object({
    name          = string
    address_space = list(string)
    dns_servers   = optional(list(string))
  })
}

# ❌ Bad - Implicit any type
variable "config" {
  description = "Configuration"
  # Missing type
}
```

### Nullable Variables

Use `optional()` for nullable fields in objects:

```hcl
variable "storage_config" {
  description = "Storage account configuration"
  type = object({
    name                     = string
    account_tier            = string
    account_replication_type = string
    min_tls_version         = optional(string, "TLS1_2")
    enable_https_only       = optional(bool, true)
  })
}
```

## Code Formatting

### Indentation

Use **2 spaces** (no tabs):

```hcl
resource "azurerm_virtual_network" "hub_vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.hub_network.name
  location            = var.resource_group_location
  address_space       = var.vnet_address_space
  
  tags = merge(
    local.common_tags,
    var.additional_tags
  )
}
```

### Argument Alignment

Align resource arguments consistently:

```hcl
# ✅ Good - Aligned
resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = local.common_tags
}

# ❌ Bad - Misaligned
resource "azurerm_storage_account" "example" {
  name = local.storage_account_name
  resource_group_name = azurerm_resource_group.example.name
  location = var.resource_group_location
  account_tier = "Standard"
}
```

### Conditional Expressions

Use ternary operator format:

```hcl
# ✅ Good
resource "azurerm_key_vault" "example" {
  soft_delete_retention_days = var.environment == "prod" ? 90 : 7
  purge_protection_enabled   = var.environment == "prod" ? true : false
}

# Multiline for complex conditions
locals {
  storage_tier = var.environment == "prod" ? "Premium" : (
    var.environment == "uat" ? "Standard" : "Basic"
  )
}
```

## Module Usage

### Module Source Paths

Use relative paths from the component:

```hcl
# ✅ Good - Relative from Workload/
module "resource_group" {
  source = "../../../Modules/resource_group"
  
  resource_group_name     = local.resource_group_name
  resource_group_location = var.resource_group_location
  tags                    = local.common_tags
}

# ❌ Bad - Absolute path
module "resource_group" {
  source = "/terraform/Modules/resource_group"
  ...
}
```

### Module Dependencies

Use explicit `depends_on` when needed:

```hcl
module "virtual_network" {
  source = "../../../Modules/networking"
  
  vnet_name           = local.vnet_name
  resource_group_name = module.resource_group.resource_group_name
  
  depends_on = [module.resource_group]
}
```

## Provider Configuration

### Version Constraints

Pin Terraform and provider versions:

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Backend config injected via -backend-config flags
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  
  subscription_id = var.azure_subscription_id
}
```

## Comments and Documentation

### When to Comment

Add comments for:
- Complex logic
- Non-obvious decisions
- Workarounds
- Business rules

```hcl
# ✅ Good - Explains why
# Subnets must be /27 or larger to support AKS node pools
variable "subnet_address_prefixes" {
  description = "Address prefixes for subnets"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for prefix in var.subnet_address_prefixes :
      tonumber(split("/", prefix)[1]) <= 27
    ])
    error_message = "Subnets must be /27 or larger for AKS compatibility"
  }
}

# ❌ Bad - States the obvious
# Create resource group
resource "azurerm_resource_group" "example" {
  ...
}
```

### Variable Descriptions

Write clear, actionable descriptions:

```hcl
# ✅ Good
variable "enable_private_endpoint" {
  description = "Enable private endpoint for secure access. Requires VNet integration and DNS configuration."
  type        = bool
  default     = true
}

# ❌ Bad
variable "enable_private_endpoint" {
  description = "Private endpoint flag"
  type        = bool
}
```

## Common Patterns

### Data Source Queries

```hcl
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "existing" {
  name = var.existing_resource_group_name
}

data "azurerm_key_vault" "shared" {
  name                = var.shared_key_vault_name
  resource_group_name = var.shared_resource_group_name
}
```

### For Expressions

```hcl
# Transform list to map
locals {
  subnet_map = {
    for subnet in var.subnets :
    subnet.name => subnet
  }
}

# Filter and transform
locals {
  enabled_subnets = [
    for subnet in var.subnets :
    subnet if subnet.enabled
  ]
}
```

## Quick Reference

For module-specific patterns and advanced formatting, see [references/advanced-patterns.md](references/advanced-patterns.md).