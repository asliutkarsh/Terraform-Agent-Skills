---
name: terraform-network-architecture
description: Generate Azure Network architecture code following the "Split-File Pattern". Enforces separation of NSG rules and Routes into dedicated files, standardizes VNet/Subnet structures, and ensures naming compliance. Use when creating VNets, Subnets, NSGs, UDRs, or peering configurations. Triggers include "new vnet", "add subnet", "nsg rules", "route table", or "network stack".
---

# Terraform Network Architecture

Standardized pattern for Azure Networking components focusing on maintainability and separation of concerns.

## Core Architecture Principles

1.  **Split-File Pattern**: Network logic is dense. Never dump everything in `main.tf`.
    * `main.tf`: Core resources (VNet, Subnets, Associations).
    * `nsg_rules.tf`: Security rules only.
    * `routes.tf`: User Defined Routes (UDR) only.
    * `locals.tf`: Naming logic and map transformations.
2.  **No Hardcoded Rules**: NSG rules and Routes must be defined as variables or locals maps, not inline blocks.
3.  **Strict Naming**: All resources use `locals.tf` to resolve names via `terraform-azure-standards`.

## Directory Structure

Every network component **MUST** follow this file layout:

```text
network/
├── main.tf           # VNet, Subnets, NSGs, Route Tables, Peerings
├── nsg_rules.tf      # azurerm_network_security_rule resources
├── routes.tf         # azurerm_route resources
├── variables.tf      # Standard inputs
├── locals.tf         # Naming & tagging logic
├── outputs.tf        # Exposed IDs (Subnets, VNet ID)
└── providers.tf      # Azure provider config

```

## Pattern: NSG Rule Separation

**File:** `nsg_rules.tf`

Do not put rules inside the `azurerm_network_security_group` resource block. Use separate resources or a dynamic block fed by a local variable.

```hcl
# ✅ GOOD: Rules defined in a dedicated file
resource "azurerm_network_security_rule" "rules" {
  for_each = var.nsg_rules

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

```

## Pattern: Route Management

**File:** `routes.tf`

Routes should be managed similarly to NSG rules to prevent `main.tf` bloat.

```hcl
# ✅ GOOD: Routes in a dedicated file
resource "azurerm_route" "this" {
  for_each = var.routes

  name                   = each.key
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = try(each.value.next_hop_in_ip_address, null)
}

```

## Pattern: Naming via Locals

**File:** `locals.tf`

Never hardcode names in `main.tf`. Calculate them once in `locals.tf`.

```hcl
locals {
  # Standardize naming
  resource_group_name = "rg-${var.org}-${var.scope}-${var.location}-${var.component}-${var.instance}"
  vnet_name           = "vnet-${var.org}-${var.scope}-${var.location}-${var.instance}"
  nsg_name            = "nsg-${var.org}-${var.scope}-${var.location}-${var.instance}"
  rt_name             = "rt-${var.org}-${var.scope}-${var.location}-${var.instance}"

  common_tags = {
    Project     = var.scope
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

```

## Variable Schemas

### NSG Rules Input

```hcl
variable "nsg_rules" {
  description = "Map of NSG rules"
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

```

### Routes Input

```hcl
variable "routes" {
  description = "Map of UDR routes"
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

```

## Validation Checklist

1. [ ] **File Split**: Are rules in `nsg_rules.tf` and routes in `routes.tf`?
2. [ ] **Naming**: Does `main.tf` refer to `local.vnet_name` (not a string)?
3. [ ] **Subnets**: Are subnets defined using `for_each` if creating multiple?
4. [ ] **Linter**: Is `.tflint.hcl` present?