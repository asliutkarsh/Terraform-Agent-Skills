---
name: terraform-azure-standards
description: Enforce Azure naming conventions, tagging standards, and Hub-Spoke resource classification for Azure infrastructure. Use when creating Azure resources, validating Terraform configurations, reviewing infrastructure code, or ensuring compliance with organizational standards. Triggers include mentions of resource naming, tags, Hub/Core resources, Spoke resources, or Azure infrastructure validation.
---

# Terraform Azure Standards

Enforce organization's Azure naming conventions and architectural standards.

## Naming Convention

### Format Rules

**Hub/Core Resources:**
`[ResourceType]-[Org]-[Scope]-[Location]-[Component]-[Instance]`

**Spoke Resources:**
`[ResourceType]-[Org]-[Project]-[Env]-[Location]-[Component]-[Instance]`

### Naming Standards

- **Case**: All lowercase
- **Separator**: Hyphens (`-`) except for Storage Accounts and Container Registries
- **Project codes**: Max 6 characters
- **Instance**: Two-digit sequence (`01`, `02`)

### Resource Abbreviations

Validate against these standard abbreviations from [references/abbreviations.md](references/abbreviations.md).

Common examples:
- Resource Group: `rg`
- Virtual Network: `vnet`
- Storage Account: `st` (no hyphens)
- Key Vault: `kv`
- AKS Cluster: `aks`

### Location Codes

- Central India: `cin`
- East US: `eus`
- West Europe: `weu`
- South India: `sin`

## Tagging Standards

**Mandatory tags for all resources:**

```hcl
tags = {
  Project     = "hub" | "custbot" | "<project-code>"
  Environment = "Production" | "Dev" | "UAT" | "Shared-Core"
  Owner       = "<team-name>"
  ManagedBy   = "Terraform"
}
```

**Hub-specific**: Must include `Environment` tag since it's not in the name.

## Module Structure

Always create modules first in `modules/` directory.

Example:
```
modules/
  |
  └── resource_group/
  └── compute/
      ├── vm/
      └── vmss/
  └── data/
      ├── storage_account/
      └── key_vault/
  └── network/
      ├── vnet/
      └── private_endpoint/
```

Use these modules to create resources in your Terraform code inside `workload/` directory.

Example:
```hcl
module "rg" {
  source = "./modules/resource_group"

  name     = "rg-org-hub-cin-data-01"
  location = "centralindia"

  tags = {
    Project     = "Hub"
    Environment = "Shared-Core"
    Owner       = "Platform Team"
    ManagedBy   = "Terraform"
  }
}
```

## Resource Classification

Create resources in Hub/Core for shared resources and in Spokes for project-specific resources.
Use `workload/core/<component>/` for Hub/Core resources and `workload/spokes/<project>/<component>/` for Spoke resources.

Folder structure:
```
workload/
  ├── core/
  │   ├── data/
  │   │   ├── .tflint.hcl      # Required
  │   │   ├── backend.tf       # Required
  │   │   ├── data.tf          # Required (even if empty)
  │   │   ├── locals.tf        # Naming & Logic
  │   │   ├── main.tf          # Resources (var/local refs only)
  │   │   ├── outputs.tf
  │   │   ├── providers.tf
  │   │   └── variables.tf
  │   └── ...
  └── spokes/
      └── <project>/
          └── <component>/
              ├── .tflint.hcl
              ├── main.tf
              └── ...
```
refer to [terraform-code-style](terraform-code-style) for more details.

### Hub/Core Resources

**Hub Path Pattern:**
- Code: `workload/core/<component>/`
- Config: `deployment/core/<component>/`

### Spoke Resources

**Prohibited in Spokes:**
- RBAC definitions
- Azure Policy definitions
- Governance resources

**Spoke Path Pattern:**
- Code: `workload/spokes/<project>/<component>/`
- Config: `deployment/spokes/<project>/<component>/`

## Validation Workflow

When reviewing Terraform code:

1. **Check resource naming** against format rules
2. **Verify tags** include all mandatory fields
3. **Validate component classification** (Hub vs Spoke)
4. **Confirm path alignment** between Workload/ and Deployment/
5. **Flag prohibited resources** in Spokes

## Examples

### Valid Hub Storage Account

```hcl
resource "azurerm_storage_account" "audit_logs" {
  name                = "storaghubcindata02"  # No hyphens
  resource_group_name = "rg-org-hub-cin-data-01"
  location            = "centralindia"
  
  tags = {
    Project     = "Hub"
    Environment = "Shared-Core"
    Owner       = "Platform Team"
    ManagedBy   = "Terraform"
  }
}
```

### Valid Spoke Resource Group

```hcl
resource "azurerm_resource_group" "ragbot_data" {
  name     = "rg-org-ragbot-dev-cin-data-01"
  location = "centralindia"
  
  tags = {
    Project     = "ragbot"
    Environment = "Dev"
    Owner       = "AI Team"
    ManagedBy   = "Terraform"
  }
}
```

### Invalid Examples

**❌ Wrong naming format:**
```hcl
name = "RG-ORG-HUB-CIN-DATA-01"  # Uppercase
name = "rg_org_hub_cin_data_01"  # Underscores instead of hyphens
```

**❌ Missing tags:**
```hcl
tags = {
  Environment = "Production"
  # Missing Project, Owner, ManagedBy
}
```

**❌ Spoke with governance resources:**
```hcl
# In workload/spokes/ragbot/
resource "azurerm_policy_definition" "..."  # Not allowed in Spokes
```

## Quick Reference
For complete naming rules and all resource abbreviations, see [references/naming-convention.md](references/naming-convention.md).