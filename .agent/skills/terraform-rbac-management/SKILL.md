---
name: terraform-rbac-management
description: Create and validate Azure RBAC assignments using human-readable configuration with dynamic runtime resolution. Use when managing identity and access control, assigning permissions, configuring managed identities, or setting up RBAC for CI/CD pipelines. Triggers include mentions of RBAC, role assignments, permissions, managed identities, access control, or federated credentials.
---

# Terraform RBAC Management

Secure, human-readable approach to managing Azure RBAC using dynamic runtime resolution.

## Core Principles

1. **Security First**: No sensitive IDs in configuration files
2. **Human-Readable**: Use names instead of IDs for auditability
3. **Dynamic Resolution**: Principals and scopes resolved at runtime via data sources
4. **Validation-Driven**: Comprehensive validation at variable and runtime levels

## Architecture Overview

```
Configuration (tfvars)
    ↓
Variables with Validation
    ↓
Data Sources (Runtime Resolution)
    ↓
Locals (Resolution Logic)
    ↓
Module (Role Assignment)
    ↓
Azure RBAC
```

## RBAC Assignment Structure

### Basic Assignment Format

```hcl
rbac_assignments = {
  "assignment_key" = {
    principal_type                    = "managed_identity" | "user" | "service_principal"
    principal_name                    = "name-of-principal"
    role_name                         = "Azure-Built-In-Role"
    scope_type                        = "subscription" | "resource_group" | "key_vault" | "storage_account"
    scope_name                        = "name-of-scope"
    scope_resource_group              = "rg-name" (required except for subscription)
    managed_identities_resource_group = "rg-name" (required for managed_identity)
    description                       = "Business context for audit"
  }
}
```

### Field Descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `principal_type` | Yes | Type of principal: managed_identity, user, or service_principal |
| `principal_name` | Yes | Name of the principal (not the ID) |
| `role_name` | Yes | Built-in Azure role name (e.g., "Owner", "Contributor") |
| `scope_type` | Yes | Type of scope: subscription, resource_group, key_vault, storage_account |
| `scope_name` | Yes | Name of the scope resource |
| `scope_resource_group` | Conditional | Required for all scope_types except subscription |
| `managed_identities_resource_group` | Conditional | Required when principal_type is managed_identity |
| `description` | No | Business context for the assignment |

## Common Patterns

### Pattern 1: GitHub Actions CI/CD Access

**Scenario:** Grant GitHub Actions pipeline access to subscription

```hcl
rbac_assignments = {
  "github_terraform_subscription_owner" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-github-terraform-01"
    role_name                         = "Owner"
    scope_type                        = "subscription"
    scope_name                        = "subscription"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "GitHub Actions Terraform automation with full subscription access"
  }
}
```

### Pattern 2: Key Vault Secrets Access

**Scenario:** Allow CI/CD to read secrets from Key Vault

```hcl
rbac_assignments = {
  "github_terraform_keyvault_secrets" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-github-terraform-01"
    role_name                         = "Key Vault Secrets User"
    scope_type                        = "key_vault"
    scope_name                        = "kv-ajfc-hub-cin-data-01"
    scope_resource_group              = "rg-ajfc-hub-cin-data-01"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "Read-only access to Hub Key Vault secrets for CI/CD"
  }
}
```

### Pattern 3: Storage Account Access

**Scenario:** Grant application managed identity storage access

```hcl
rbac_assignments = {
  "app_storage_blob_contributor" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-ragbot-dev-cin-app-01"
    role_name                         = "Storage Blob Data Contributor"
    scope_type                        = "storage_account"
    scope_name                        = "stajfcragbotdevcindata01"
    scope_resource_group              = "rg-ajfc-ragbot-dev-cin-data-01"
    managed_identities_resource_group = "rg-ajfc-ragbot-dev-cin-identity-01"
    description                       = "Application access to blob storage for data processing"
  }
}
```

### Pattern 4: User Access

**Scenario:** Grant user access to resource group

```hcl
rbac_assignments = {
  "dev_team_lead_rg_contributor" = {
    principal_type       = "user"
    principal_name       = "john.doe@ajfc.com"
    role_name            = "Contributor"
    scope_type           = "resource_group"
    scope_name           = "rg-ajfc-ragbot-dev-cin-data-01"
    scope_resource_group = "rg-ajfc-ragbot-dev-cin-data-01"
    description          = "Development team lead access to ragbot dev environment"
  }
}
```

### Pattern 5: Service Principal Access

**Scenario:** Grant service principal access

```hcl
rbac_assignments = {
  "monitoring_sp_reader" = {
    principal_type       = "service_principal"
    principal_name       = "monitoring-service-principal"
    role_name            = "Reader"
    scope_type           = "resource_group"
    scope_name           = "rg-ajfc-hub-cin-network-01"
    scope_resource_group = "rg-ajfc-hub-cin-network-01"
    description          = "Monitoring service read access to network resources"
  }
}
```

## Implementation Components

### 1. Managed Identity Creation

Create managed identities with optional federated credentials:

```hcl
identities = [
  {
    identity_suffix = "github-terraform"
    federated_credentials = [
      {
        name     = "main"
        audience = ["api://AzureADTokenExchange"]
        issuer   = "https://token.actions.githubusercontent.com"
        subject  = "repo:organization/repository:ref:refs/heads/main"
      }
    ]
  }
]
```

### 2. Data Sources for Resolution

The system uses data sources to resolve names to IDs:

```hcl
# Managed Identities
data "azurerm_user_assigned_identity" "managed_identities" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "managed_identity"
  }
  name                = each.key
  resource_group_name = each.value.managed_identities_resource_group
}

# Users
data "azuread_user" "users" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "user"
  }
  user_principal_name = each.key
}

# Service Principals
data "azuread_service_principal" "service_principals" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "service_principal"
  }
  display_name = each.key
}

# Scopes
data "azurerm_subscription" "subscription" {}

data "azurerm_resource_group" "resource_groups" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.resource_group => assignment
    if assignment.scope_type == "resource_group"
  }
  name = each.key
}

data "azurerm_key_vault" "key_vaults" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.scope_name => assignment
    if assignment.scope_type == "key_vault"
  }
  name                = each.key
  resource_group_name = each.value.scope_resource_group
}

data "azurerm_storage_account" "storage_accounts" {
  for_each = {
    for assignment in var.rbac_assignments :
    assignment.scope_name => assignment
    if assignment.scope_type == "storage_account"
  }
  name                = each.key
  resource_group_name = each.value.scope_resource_group
}
```

### 3. Resolution Logic

Locals resolve names to IDs and validate existence:

```hcl
locals {
  # Resolve principals
  resolved_principals = {
    for key, assignment in var.rbac_assignments : key => {
      principal_id = assignment.principal_type == "managed_identity" 
        ? data.azurerm_user_assigned_identity.managed_identities[assignment.principal_name].principal_id
        : assignment.principal_type == "user"
        ? data.azuread_user.users[assignment.principal_name].object_id
        : assignment.principal_type == "service_principal"
        ? data.azuread_service_principal.service_principals[assignment.principal_name].object_id
        : null
      principal_type = assignment.principal_type
      principal_name = assignment.principal_name
    }
  }

  # Resolve scopes
  resolved_scopes = {
    for key, assignment in var.rbac_assignments : key => {
      scope_id = assignment.scope_type == "subscription"
        ? data.azurerm_subscription.subscription.id
        : assignment.scope_type == "resource_group"
        ? data.azurerm_resource_group.resource_groups[assignment.resource_group].id
        : assignment.scope_type == "key_vault"
        ? data.azurerm_key_vault.key_vaults[assignment.scope_name].id
        : assignment.scope_type == "storage_account"
        ? data.azurerm_storage_account.storage_accounts[assignment.scope_name].id
        : null
      scope_type = assignment.scope_type
      scope_name = assignment.scope_name
    }
  }

  # Detect errors
  validation_errors = concat(
    [
      for key, assignment in var.rbac_assignments : 
      "RBAC assignment '${key}': Principal '${assignment.principal_name}' not found"
      if local.resolved_principals[key].principal_id == null
    ],
    [
      for key, assignment in var.rbac_assignments : 
      "RBAC assignment '${key}': Scope '${assignment.scope_name}' not found"
      if local.resolved_scopes[key].scope_id == null
    ]
  )

  # Filter valid assignments
  resolved_rbac_assignments = {
    for key in var.rbac_assignments : key => {
      principal_id   = local.resolved_principals[key].principal_id
      principal_type = local.resolved_principals[key].principal_type
      principal_name = local.resolved_principals[key].principal_name
      role_name      = var.rbac_assignments[key].role_name
      scope_id       = local.resolved_scopes[key].scope_id
      scope_type     = local.resolved_scopes[key].scope_type
      scope_name     = local.resolved_scopes[key].scope_name
      description    = lookup(var.rbac_assignments[key], "description", null)
    }
    if local.resolved_principals[key].principal_id != null && 
       local.resolved_scopes[key].scope_id != null
  }
}
```

### 4. Module Integration

Call the role assignment module:

```hcl
module "role_assignment" {
  for_each = local.resolved_rbac_assignments
  
  source               = "../../../Modules/role_assignment"
  scope                = each.value.scope_id
  role_definition_name = each.value.role_name
  principal_id         = each.value.principal_id
  description          = each.value.description
  
  depends_on = [
    module.user_assigned_identity,
    data.azurerm_user_assigned_identity.managed_identities,
    data.azuread_user.users,
    data.azuread_service_principal.service_principals
  ]
}
```

## Built-In Azure Roles

Common built-in roles (use exact names):

### Administrative Roles
- `Owner` - Full access including access management
- `Contributor` - Full access except access management
- `Reader` - Read-only access

### Key Vault Roles
- `Key Vault Administrator` - Full Key Vault management
- `Key Vault Secrets User` - Read secrets
- `Key Vault Secrets Officer` - Manage secrets
- `Key Vault Certificates Officer` - Manage certificates
- `Key Vault Crypto Officer` - Manage cryptographic keys

### Storage Roles
- `Storage Account Contributor` - Manage storage accounts
- `Storage Blob Data Owner` - Full access to blob data
- `Storage Blob Data Contributor` - Read, write, delete blobs
- `Storage Blob Data Reader` - Read blob data

### Compute Roles
- `Virtual Machine Contributor` - Manage VMs
- `Virtual Machine Administrator Login` - Login to VMs as admin

### Network Roles
- `Network Contributor` - Manage networks

For complete role reference, see [references/azure-roles.md](references/azure-roles.md).

## Validation Rules

### Variable-Level Validation

```hcl
variable "rbac_assignments" {
  description = "RBAC role assignments"
  type = map(object({
    principal_type                    = string
    principal_name                    = string
    role_name                         = string
    scope_type                        = string
    scope_name                        = string
    scope_resource_group              = optional(string)
    managed_identities_resource_group = optional(string)
    description                       = optional(string)
  }))

  validation {
    condition = alltrue([
      for assignment in values(var.rbac_assignments) : contains([
        "managed_identity", "user", "service_principal"
      ], assignment.principal_type)
    ])
    error_message = "principal_type must be: managed_identity, user, or service_principal."
  }

  validation {
    condition = alltrue([
      for assignment in values(var.rbac_assignments) : contains([
        "subscription", "resource_group", "key_vault", "storage_account"
      ], assignment.scope_type)
    ])
    error_message = "scope_type must be: subscription, resource_group, key_vault, or storage_account."
  }

  validation {
    condition = alltrue([
      for assignment in values(var.rbac_assignments) :
      assignment.scope_type == "subscription" ||
      assignment.scope_resource_group != null
    ])
    error_message = "scope_resource_group required for non-subscription scopes."
  }

  validation {
    condition = alltrue([
      for assignment in values(var.rbac_assignments) :
      assignment.principal_type != "managed_identity" ||
      assignment.managed_identities_resource_group != null
    ])
    error_message = "managed_identities_resource_group required for managed_identity principals."
  }
}
```

## Security Best Practices

### 1. Principle of Least Privilege

```hcl
# ❌ Bad - Too permissive
rbac_assignments = {
  "app_access" = {
    role_name  = "Owner"
    scope_type = "subscription"
    # ...
  }
}

# ✅ Good - Minimum required permissions
rbac_assignments = {
  "app_keyvault_access" = {
    role_name  = "Key Vault Secrets User"
    scope_type = "key_vault"
    scope_name = "kv-ajfc-ragbot-dev-cin-data-01"
    # ...
  }
}
```

### 2. Scoped Access

```hcl
# ❌ Bad - Subscription-wide access
rbac_assignments = {
  "dev_storage_access" = {
    role_name  = "Storage Blob Data Contributor"
    scope_type = "subscription"
    # ...
  }
}

# ✅ Good - Storage account scope
rbac_assignments = {
  "dev_storage_access" = {
    role_name  = "Storage Blob Data Contributor"
    scope_type = "storage_account"
    scope_name = "stajfcragbotdevcindata01"
    # ...
  }
}
```

### 3. Descriptive Contexts

```hcl
# ❌ Bad - No context
rbac_assignments = {
  "access1" = {
    description = "Storage access"
    # ...
  }
}

# ✅ Good - Clear business context
rbac_assignments = {
  "app_ml_model_storage" = {
    description = "Application access to ML model storage for inference workload"
    # ...
  }
}
```

## Complete Example

For a complete working example, see [references/complete-example.md](references/complete-example.md).

## Troubleshooting

### Principal Not Found

**Error:** `Principal 'id-ajfc-hub-cin-github-01' not found`

**Solution:** Verify principal exists and resource group is correct:
```bash
az identity show \
  --name id-ajfc-hub-cin-github-01 \
  --resource-group rg-ajfc-hub-cin-identity-01
```

### Scope Not Found

**Error:** `Scope 'kv-ajfc-hub-cin-data-01' not found`

**Solution:** Verify resource exists:
```bash
az keyvault show \
  --name kv-ajfc-hub-cin-data-01 \
  --resource-group rg-ajfc-hub-cin-data-01
```

### Permission Denied

**Error:** `Authorization failed for role assignment`

**Solution:** Ensure you have `Owner` or `User Access Administrator` role