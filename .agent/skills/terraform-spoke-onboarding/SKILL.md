---
name: terraform-spoke-onboarding
description: Guide complete spoke project onboarding including directory structure creation, Terraform code generation, tfvars configuration, and CI/CD pipeline setup. Use when creating new spoke projects, onboarding workloads, setting up project infrastructure, or scaffolding complete spoke environments. Triggers include "new spoke", "onboard project", "create spoke", or "setup new workload".
---

# Terraform Spoke Onboarding

Complete workflow for onboarding a new spoke project to the Hub-Spoke architecture.

## Overview

Onboarding a spoke involves:
1. Creating directory structure
2. Writing Terraform code
3. Configuring environment variables
4. Setting up CI/CD pipeline
5. Initial deployment

## Prerequisites

Before starting:
- Project code (max 6 chars, e.g., `ragbot`, `custbot`)
- Target environment (`dev`, `uat`, `prod`)
- Target region (typically `cin` for Central India)
- Required components (network, data, compute, ai)

## Step 1: Create Directory Structure

### Workload Structure

Create Terraform code directories:

```bash
mkdir -p Workload/Spokes/{project-code}/{network,data,compute,ai}
```

Each component needs standard files:

```bash
# For each component (network, data, compute, ai)
cd Workload/Spokes/{project-code}/{component}
touch main.tf variables.tf outputs.tf providers.tf
```

### Deployment Structure

Create configuration directories:

```bash
mkdir -p Deployment/Spokes/{project-code}/{network,data,compute,ai}
```

Create tfvars files:

```bash
# For each component
touch Deployment/Spokes/{project-code}/{component}/{component}.tfvars
```

## Step 2: Write Terraform Code

### Example: Network Component

**File: Workload/Spokes/{project-code}/network/main.tf**

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
    # Injected via -backend-config in CI/CD
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  
  subscription_id = var.azure_subscription_id
}

locals {
  # Resource naming
  resource_group_name = "rg-${var.org}-${var.project}-${var.environment}-${var.location}-network-${var.instance}"
  vnet_name          = "vnet-${var.org}-${var.project}-${var.environment}-${var.location}-${var.instance}"
  
  # Common tags
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Resource Group
module "resource_group" {
  source = "../../../../Modules/resource_group"
  
  resource_group_name     = local.resource_group_name
  resource_group_location = var.resource_group_location
  tags                    = local.common_tags
}

# Virtual Network
module "virtual_network" {
  source = "../../../../Modules/networking"
  
  vnet_name           = local.vnet_name
  resource_group_name = module.resource_group.resource_group_name
  location            = var.resource_group_location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}
```

**File: Workload/Spokes/{project-code}/network/variables.tf**

```hcl
variable "org" {
  description = "Organization identifier"
  type        = string
  default     = "ajfc"
}

variable "project" {
  description = "Project code (max 6 chars)"
  type        = string
  
  validation {
    condition     = length(var.project) <= 6
    error_message = "Project code must be 6 characters or less."
  }
}

variable "environment" {
  description = "Environment (dev, uat, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod."
  }
}

variable "location" {
  description = "Azure region code (cin, eus, weu)"
  type        = string
  default     = "cin"
}

variable "instance" {
  description = "Instance number (01, 02, etc.)"
  type        = string
  default     = "01"
}

variable "owner" {
  description = "Team or individual owning this resource"
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

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Subnet configuration"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = []
}
```

**File: Workload/Spokes/{project-code}/network/outputs.tf**

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.resource_group_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.virtual_network.vnet_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.virtual_network.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.virtual_network.subnet_ids
}
```

## Step 3: Configure Environment Variables

**File: Deployment/Spokes/{project-code}/network/network.tfvars**

```hcl
# Project Configuration
project     = "ragbot"
environment = "dev"
location    = "cin"
instance    = "01"
owner       = "AI Team"

# Azure Configuration
resource_group_location = "centralindia"
azure_subscription_id   = "your-subscription-id"

# Network Configuration
vnet_address_space = ["10.1.0.0/16"]

subnets = [
  {
    name           = "snet-app"
    address_prefix = "10.1.1.0/24"
  },
  {
    name           = "snet-data"
    address_prefix = "10.1.2.0/24"
  },
  {
    name           = "snet-private-endpoint"
    address_prefix = "10.1.3.0/24"
  }
]
```

## Step 4: Create CI/CD Pipeline

**File: .github/workflows/{project-code}-plan-apply.yml**

```yaml
name: {project-code}-Deploy

on:
  workflow_dispatch:
    inputs:
      component:
        description: "Component to deploy"
        required: true
        type: choice
        options:
          - network
          - data
          - compute
          - ai

permissions:
  id-token: write
  contents: read

jobs:
  plan:
    uses: ./.github/workflows/terraform-plan.yml
    with:
      # Point to Spoke Workload Directory
      working_directory: Workload/Spokes/{project-code}/${{ inputs.component }}
      
      # Define unique State Key
      state_key: spokes/{project-code}/${{ inputs.component }}.tfstate
      
      # Name the artifact
      component_name: {project-code}-${{ inputs.component }}
      
      # Point to Spoke Deployment Configuration
      tfvars_file: Deployment/Spokes/{project-code}/${{ inputs.component }}/${{ inputs.component }}.tfvars
    secrets: inherit

  apply:
    needs: plan
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Spokes/{project-code}/${{ inputs.component }}
      state_key: spokes/{project-code}/${{ inputs.component }}.tfstate
      component_name: {project-code}-${{ inputs.component }}
      environment: production
    secrets: inherit
```

## Step 5: Initial Deployment

### Manual Verification

Before CI/CD, test locally:

```bash
# Initialize
cd Workload/Spokes/{project-code}/network
terraform init \
  -backend-config="storage_account_name=${TF_STATE_SA_NAME}" \
  -backend-config="container_name=${TF_STATE_CONTAINER}" \
  -backend-config="key=spokes/{project-code}/network.tfstate" \
  -backend-config="resource_group_name=${TF_STATE_RG}"

# Plan
terraform plan \
  -var-file=../../../../Deployment/Spokes/{project-code}/network/network.tfvars

# Apply (if plan looks good)
terraform apply \
  -var-file=../../../../Deployment/Spokes/{project-code}/network/network.tfvars
```

### CI/CD Deployment

1. Commit all files to repository
2. Go to GitHub Actions
3. Select `{project-code}-Deploy` workflow
4. Choose component (e.g., `network`)
5. Run workflow
6. Review plan in logs
7. Approve apply step

## Component-Specific Templates

### Data Component

Key resources:
- Storage Account
- Key Vault
- Databases (SQL/Cosmos)

See [references/data-component-template.md](references/data-component-template.md)

### Compute Component

Key resources:
- AKS Cluster
- App Service
- Container Registry

See [references/compute-component-template.md](references/compute-component-template.md)

### AI Component

Key resources:
- Azure OpenAI
- Cognitive Services
- AI Search

See [references/ai-component-template.md](references/ai-component-template.md)

## Validation Checklist

Before deploying:

- [ ] Directory structure matches standard layout
- [ ] File names are correct (`variables.tf` not `variable.tf`)
- [ ] Resource names follow naming convention
- [ ] All mandatory tags present
- [ ] Module paths are relative (`../../../../Modules/`)
- [ ] State key follows pattern: `spokes/{project-code}/{component}.tfstate`
- [ ] Pipeline points to correct directories
- [ ] tfvars file has all required variables

## Common Issues

### Path Mismatch

**Problem:** Pipeline can't find tfvars file

**Solution:** Verify paths in workflow file:
```yaml
working_directory: Workload/Spokes/{project-code}/{component}
tfvars_file: Deployment/Spokes/{project-code}/{component}/{component}.tfvars
```

### Module Not Found

**Problem:** Module source path incorrect

**Solution:** Use relative paths from component directory:
```hcl
module "example" {
  source = "../../../../Modules/resource_group"  # 4 levels up from Spokes/{project}/{component}
  ...
}
```

### Naming Convention Violation

**Problem:** Resource names don't match standard

**Solution:** Use locals for consistent naming:
```hcl
locals {
  resource_group_name = "rg-${var.org}-${var.project}-${var.environment}-${var.location}-${var.component}-${var.instance}"
}
```

## Next Steps

After network deployment:
1. Deploy data component (databases, storage)
2. Deploy compute component (AKS, app services)
3. Deploy AI component (OpenAI, cognitive services)
4. Configure VNet peering to Hub (if required)
5. Set up monitoring and alerts

For complete component templates, see references directory.