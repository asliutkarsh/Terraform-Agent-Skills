# Complete RBAC Management Example

End-to-end example of implementing the RBAC management system.

## Scenario

Setting up RBAC for a Hub environment with:
- GitHub Actions CI/CD automation
- Multiple Key Vaults (shared and project-specific)
- Storage accounts for state and data
- Developer access

## Directory Structure

```
Workload/Core/identity/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── locals.tf
└── data.tf

Deployment/Core/identity/
└── identity.tfvars
```

## Implementation

### Step 1: Main Configuration

**File: Workload/Core/identity/main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "azuread" {}

locals {
  resource_group_name = "rg-${var.org}-${var.scope}-${var.location}-identity-${var.instance}"
  
  common_tags = {
    Project     = var.scope
    Environment = "Shared-Core"
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Resource Group
module "resource_group" {
  source = "../../../Modules/resource_group"
  
  resource_group_name     = local.resource_group_name
  resource_group_location = var.resource_group_location
  tags                    = local.common_tags
}

# Managed Identities
module "user_assigned_identity" {
  source   = "../../../Modules/user_managed_identity"
  for_each = local.identities_map
  
  location                    = var.resource_group_location
  resource_group_name         = local.resource_group_name
  user_assigned_identity_name = local.identity_names[each.key]
  federated_credentials       = lookup(local.federated_credentials_per_identity, each.key, {})
  
  depends_on = [module.resource_group]
}

# RBAC Assignments
module "role_assignment" {
  for_each = local.resolved_rbac_assignments
  source   = "../../../Modules/role_assignment"
  
  scope                = each.value.scope_id
  role_definition_name = each.value.role_name
  principal_id         = each.value.principal_id
  description          = each.value.description
  
  depends_on = [
    module.user_assigned_identity,
    data.azurerm_user_assigned_identity.managed_identities,
    data.azuread_user.users,
    data.azuread_service_principal.service_principals,
    data.azurerm_resource_group.resource_groups,
    data.azurerm_key_vault.key_vaults,
    data.azurerm_storage_account.storage_accounts
  ]
}
```

### Step 2: Variables

**File: Workload/Core/identity/variables.tf**

```hcl
variable "org" {
  description = "Organization identifier"
  type        = string
  default     = "ajfc"
}

variable "scope" {
  description = "Scope (hub for Core)"
  type        = string
  default     = "hub"
}

variable "location" {
  description = "Azure region code"
  type        = string
  default     = "cin"
}

variable "instance" {
  description = "Instance number"
  type        = string
  default     = "01"
}

variable "owner" {
  description = "Owner team"
  type        = string
}

variable "resource_group_location" {
  description = "Full Azure region name"
  type        = string
  default     = "centralindia"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "identities" {
  description = "List of managed identities to create"
  type = list(object({
    identity_suffix = string
    federated_credentials = optional(list(object({
      name     = string
      audience = list(string)
      issuer   = string
      subject  = string
    })), [])
  }))
  default = []
}

variable "rbac_assignments" {
  description = "RBAC role assignments configuration"
  type = map(object({
    principal_type                    = string
    principal_name                    = string
    role_name                         = string
    scope_type                        = string
    scope_name                        = string
    resource_group                    = optional(string)
    scope_resource_group              = optional(string)
    managed_identities_resource_group = optional(string)
    description                       = optional(string)
  }))
  default = {}

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
}
```

### Step 3: Data Sources

**File: Workload/Core/identity/data.tf**

```hcl
# Current subscription
data "azurerm_subscription" "subscription" {}

# Managed Identities (for RBAC assignments)
data "azurerm_user_assigned_identity" "managed_identities" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "managed_identity"
  }
  
  name                = each.key
  resource_group_name = each.value.managed_identities_resource_group
}

# Azure AD Users
data "azuread_user" "users" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "user"
  }
  
  user_principal_name = each.key
}

# Service Principals
data "azuread_service_principal" "service_principals" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    assignment.principal_name => assignment
    if assignment.principal_type == "service_principal"
  }
  
  display_name = each.key
}

# Resource Groups (for RBAC scopes)
data "azurerm_resource_group" "resource_groups" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    coalesce(assignment.resource_group, assignment.scope_name) => assignment
    if assignment.scope_type == "resource_group"
  }
  
  name = each.key
}

# Key Vaults
data "azurerm_key_vault" "key_vaults" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    assignment.scope_name => assignment
    if assignment.scope_type == "key_vault"
  }
  
  name                = each.key
  resource_group_name = each.value.scope_resource_group
}

# Storage Accounts
data "azurerm_storage_account" "storage_accounts" {
  for_each = {
    for key, assignment in var.rbac_assignments :
    assignment.scope_name => assignment
    if assignment.scope_type == "storage_account"
  }
  
  name                = each.key
  resource_group_name = each.value.scope_resource_group
}
```

### Step 4: Resolution Logic

**File: Workload/Core/identity/locals.tf**

```hcl
locals {
  # Identity name generation
  identity_names = {
    for idx, identity in var.identities :
    tostring(idx) => "id-${var.org}-${var.scope}-${var.location}-${identity.identity_suffix}-${var.instance}"
  }

  # Convert identities list to map
  identities_map = {
    for idx, identity in var.identities :
    tostring(idx) => identity
  }

  # Organize federated credentials per identity
  federated_credentials_per_identity = {
    for idx, identity in var.identities :
    tostring(idx) => {
      for fc_idx, fc in identity.federated_credentials :
      fc.name => fc
    }
  }

  # Resolve principals to IDs
  resolved_principals = {
    for key, assignment in var.rbac_assignments : key => {
      principal_id = (
        assignment.principal_type == "managed_identity"
        ? try(data.azurerm_user_assigned_identity.managed_identities[assignment.principal_name].principal_id, null)
        : assignment.principal_type == "user"
        ? try(data.azuread_user.users[assignment.principal_name].object_id, null)
        : assignment.principal_type == "service_principal"
        ? try(data.azuread_service_principal.service_principals[assignment.principal_name].object_id, null)
        : null
      )
      principal_type = assignment.principal_type
      principal_name = assignment.principal_name
    }
  }

  # Resolve scopes to IDs
  resolved_scopes = {
    for key, assignment in var.rbac_assignments : key => {
      scope_id = (
        assignment.scope_type == "subscription"
        ? data.azurerm_subscription.subscription.id
        : assignment.scope_type == "resource_group"
        ? try(data.azurerm_resource_group.resource_groups[coalesce(assignment.resource_group, assignment.scope_name)].id, null)
        : assignment.scope_type == "key_vault"
        ? try(data.azurerm_key_vault.key_vaults[assignment.scope_name].id, null)
        : assignment.scope_type == "storage_account"
        ? try(data.azurerm_storage_account.storage_accounts[assignment.scope_name].id, null)
        : null
      )
      scope_type = assignment.scope_type
      scope_name = assignment.scope_name
    }
  }

  # Validation errors
  validation_errors = concat(
    [
      for key, assignment in var.rbac_assignments :
      "RBAC assignment '${key}': Principal '${assignment.principal_name}' of type '${assignment.principal_type}' not found"
      if local.resolved_principals[key].principal_id == null
    ],
    [
      for key, assignment in var.rbac_assignments :
      "RBAC assignment '${key}': Scope '${assignment.scope_name}' of type '${assignment.scope_type}' not found"
      if local.resolved_scopes[key].scope_id == null
    ]
  )

  # Filter valid assignments only
  resolved_rbac_assignments = {
    for key, assignment in var.rbac_assignments : key => {
      principal_id   = local.resolved_principals[key].principal_id
      principal_type = local.resolved_principals[key].principal_type
      principal_name = local.resolved_principals[key].principal_name
      role_name      = assignment.role_name
      scope_id       = local.resolved_scopes[key].scope_id
      scope_type     = local.resolved_scopes[key].scope_type
      scope_name     = local.resolved_scopes[key].scope_name
      description    = lookup(assignment, "description", null)
    }
    if local.resolved_principals[key].principal_id != null && 
       local.resolved_scopes[key].scope_id != null
  }
}
```

### Step 5: Outputs

**File: Workload/Core/identity/outputs.tf**

```hcl
output "resource_group_name" {
  description = "Name of the identity resource group"
  value       = module.resource_group.resource_group_name
}

output "managed_identities" {
  description = "Created managed identities"
  value = {
    for key, identity in module.user_assigned_identity :
    key => {
      name         = identity.user_assigned_identity_name
      principal_id = identity.principal_id
      client_id    = identity.client_id
      id           = identity.user_assigned_identity_id
    }
  }
}

output "rbac_assignments" {
  description = "Applied RBAC assignments"
  value = {
    for key, assignment in local.resolved_rbac_assignments :
    key => {
      principal_name = assignment.principal_name
      principal_type = assignment.principal_type
      role_name      = assignment.role_name
      scope_type     = assignment.scope_type
      scope_name     = assignment.scope_name
      description    = assignment.description
    }
  }
}

output "validation_errors" {
  description = "RBAC validation errors (if any)"
  value       = local.validation_errors
}
```

### Step 6: Configuration

**File: Deployment/Core/identity/identity.tfvars**

```hcl
# Project Configuration
owner = "Platform Team"

# Azure Configuration
resource_group_location = "centralindia"
azure_subscription_id   = "12345678-1234-1234-1234-123456789abc"

# Managed Identities
identities = [
  {
    identity_suffix = "github-terraform"
    federated_credentials = [
      {
        name     = "main"
        audience = ["api://AzureADTokenExchange"]
        issuer   = "https://token.actions.githubusercontent.com"
        subject  = "repo:ajfc-org/terraform-azure-infrastructure:ref:refs/heads/main"
      },
      {
        name     = "pull-request"
        audience = ["api://AzureADTokenExchange"]
        issuer   = "https://token.actions.githubusercontent.com"
        subject  = "repo:ajfc-org/terraform-azure-infrastructure:pull_request"
      }
    ]
  }
]

# RBAC Assignments
rbac_assignments = {
  # GitHub Actions - Full subscription access
  "github_terraform_subscription_owner" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-github-terraform-01"
    role_name                         = "Owner"
    scope_type                        = "subscription"
    scope_name                        = "subscription"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "GitHub Actions Terraform automation with full subscription access for infrastructure deployment"
  }

  # GitHub Actions - Hub Key Vault access
  "github_terraform_hub_keyvault" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-github-terraform-01"
    role_name                         = "Key Vault Secrets User"
    scope_type                        = "key_vault"
    scope_name                        = "kv-ajfc-hub-cin-data-01"
    scope_resource_group              = "rg-ajfc-hub-cin-data-01"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "GitHub Actions read access to Hub Key Vault for deployment secrets"
  }

  # GitHub Actions - Terraform state storage
  "github_terraform_state_storage" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-github-terraform-01"
    role_name                         = "Storage Blob Data Contributor"
    scope_type                        = "storage_account"
    scope_name                        = "stajfchubcindata01"
    scope_resource_group              = "rg-ajfc-hub-cin-data-01"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "GitHub Actions access to Terraform state storage for state management"
  }

  # Platform Team Lead - Subscription contributor
  "platform_lead_subscription_contributor" = {
    principal_type = "user"
    principal_name = "platform.lead@ajfc.com"
    role_name      = "Contributor"
    scope_type     = "subscription"
    scope_name     = "subscription"
    description    = "Platform team lead contributor access for infrastructure management"
  }

  # Platform Team Lead - User Access Administrator
  "platform_lead_access_admin" = {
    principal_type = "user"
    principal_name = "platform.lead@ajfc.com"
    role_name      = "User Access Administrator"
    scope_type     = "subscription"
    scope_name     = "subscription"
    description    = "Platform team lead access management for RBAC operations"
  }

  # DevOps Team - Network contributor
  "devops_network_contributor" = {
    principal_type       = "user"
    principal_name       = "devops.team@ajfc.com"
    role_name            = "Network Contributor"
    scope_type           = "resource_group"
    scope_name           = "rg-ajfc-hub-cin-network-01"
    scope_resource_group = "rg-ajfc-hub-cin-network-01"
    description          = "DevOps team network management access for Hub networking"
  }

  # Monitoring Service - Reader access
  "monitoring_service_reader" = {
    principal_type = "service_principal"
    principal_name = "monitoring-service-principal"
    role_name      = "Reader"
    scope_type     = "subscription"
    scope_name     = "subscription"
    description    = "Monitoring service read access for infrastructure monitoring"
  }
}
```

## Deployment

### Initialize and Plan

```bash
cd Workload/Core/identity

terraform init \
  -backend-config="storage_account_name=stajfchubcindata01" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=core/identity.tfstate" \
  -backend-config="resource_group_name=rg-ajfc-hub-cin-data-01"

terraform plan \
  -var-file="../../../Deployment/Core/identity/identity.tfvars"
```

### Expected Output

```
Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + managed_identities = {
      + "0" = {
          + client_id    = (known after apply)
          + id           = (known after apply)
          + name         = "id-ajfc-hub-cin-github-terraform-01"
          + principal_id = (known after apply)
        }
    }
  + rbac_assignments = {
      + "devops_network_contributor" = {
          + description    = "DevOps team network management access for Hub networking"
          + principal_name = "devops.team@ajfc.com"
          + principal_type = "user"
          + role_name      = "Network Contributor"
          + scope_name     = "rg-ajfc-hub-cin-network-01"
          + scope_type     = "resource_group"
        }
      # ... more assignments
    }
  + validation_errors = []
```

### Apply

```bash
terraform apply \
  -var-file="../../../Deployment/Core/identity/identity.tfvars"
```

## Verification

### Verify Managed Identity

```bash
az identity show \
  --name id-ajfc-hub-cin-github-terraform-01 \
  --resource-group rg-ajfc-hub-cin-identity-01
```

### Verify RBAC Assignments

```bash
# List all role assignments for the identity
PRINCIPAL_ID=$(az identity show \
  --name id-ajfc-hub-cin-github-terraform-01 \
  --resource-group rg-ajfc-hub-cin-identity-01 \
  --query principalId -o tsv)

az role assignment list \
  --assignee $PRINCIPAL_ID \
  --all \
  --query "[].{Role:roleDefinitionName, Scope:scope}" \
  --output table
```

### Test Federated Credential

```bash
# From GitHub Actions
az login \
  --service-principal \
  --username $AZURE_CLIENT_ID \
  --tenant $AZURE_TENANT_ID \
  --federated-token $ACTIONS_ID_TOKEN_REQUEST_TOKEN

# Verify access
az account show
az keyvault secret list --vault-name kv-ajfc-hub-cin-data-01
```

## Extending the Example

### Add New Identity

```hcl
identities = [
  # ... existing identities
  {
    identity_suffix = "aks-workload"
    federated_credentials = []  # No OIDC needed for AKS workload identity
  }
]
```

### Add New RBAC Assignment

```hcl
rbac_assignments = {
  # ... existing assignments
  "aks_workload_storage_reader" = {
    principal_type                    = "managed_identity"
    principal_name                    = "id-ajfc-hub-cin-aks-workload-01"
    role_name                         = "Storage Blob Data Reader"
    scope_type                        = "storage_account"
    scope_name                        = "stajfcragbotdevcindata01"
    scope_resource_group              = "rg-ajfc-ragbot-dev-cin-data-01"
    managed_identities_resource_group = "rg-ajfc-hub-cin-identity-01"
    description                       = "AKS workload read access to application storage"
  }
}
```

## Best Practices Demonstrated

1. ✅ **Security**: No IDs in configuration
2. ✅ **Readability**: Clear names and descriptions
3. ✅ **Validation**: Comprehensive error detection
4. ✅ **Modularity**: Separate identity creation and assignment
5. ✅ **Auditability**: Descriptive assignment keys and descriptions
6. ✅ **Least Privilege**: Scoped permissions where possible
7. ✅ **Documentation**: Clear comments and business context