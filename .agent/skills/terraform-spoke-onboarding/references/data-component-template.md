# Data Component Template

Template for spoke data component including storage, databases, and Key Vault.

## Directory Structure

```
Workload/Spokes/{project-code}/data/
├── main.tf
├── variables.tf
├── outputs.tf
└── providers.tf

Deployment/Spokes/{project-code}/data/
└── data.tfvars
```

## Main Configuration

**File: main.tf**

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  
  subscription_id = var.azure_subscription_id
}

locals {
  # Resource naming (no hyphens for storage)
  resource_group_name  = "rg-${var.org}-${var.project}-${var.environment}-${var.location}-data-${var.instance}"
  storage_account_name = "st${var.org}${var.project}${var.environment}${var.location}data${var.instance}"
  key_vault_name      = "kv-${var.org}-${var.project}-${var.environment}-${var.location}-data-${var.instance}"
  
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

# Storage Account
module "storage_account" {
  source = "../../../../Modules/storage"
  
  storage_account_name     = local.storage_account_name
  resource_group_name      = module.resource_group.resource_group_name
  location                 = var.resource_group_location
  account_tier            = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                    = local.common_tags
  
  depends_on = [module.resource_group]
}

# Key Vault
module "key_vault" {
  source = "../../../../Modules/key_vault"
  
  key_vault_name          = local.key_vault_name
  resource_group_name     = module.resource_group.resource_group_name
  location                = var.resource_group_location
  sku_name                = var.key_vault_sku
  soft_delete_retention_days = var.environment == "prod" ? 90 : 7
  purge_protection_enabled   = var.environment == "prod" ? true : false
  tags                    = local.common_tags
  
  depends_on = [module.resource_group]
}

# Optional: SQL Database
module "sql_server" {
  count  = var.create_sql_server ? 1 : 0
  source = "../../../../Modules/sql_server"
  
  sql_server_name         = "sql-${var.org}-${var.project}-${var.environment}-${var.location}-${var.instance}"
  resource_group_name     = module.resource_group.resource_group_name
  location                = var.resource_group_location
  administrator_login     = var.sql_admin_username
  administrator_password  = var.sql_admin_password
  tags                   = local.common_tags
  
  depends_on = [module.resource_group]
}

# Optional: Cosmos DB
module "cosmos_db" {
  count  = var.create_cosmos_db ? 1 : 0
  source = "../../../../Modules/cosmos_db"
  
  cosmos_account_name = "cosmos-${var.org}-${var.project}-${var.environment}-${var.location}-${var.instance}"
  resource_group_name = module.resource_group.resource_group_name
  location           = var.resource_group_location
  offer_type         = "Standard"
  consistency_level  = var.cosmos_consistency_level
  tags              = local.common_tags
  
  depends_on = [module.resource_group]
}
```

## Variables

**File: variables.tf**

```hcl
# Standard variables
variable "org" {
  description = "Organization identifier"
  type        = string
  default     = "ajfc"
}

variable "project" {
  description = "Project code"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
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

# Storage Account
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition = contains(
      ["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"],
      var.storage_replication_type
    )
    error_message = "Invalid replication type."
  }
}

# Key Vault
variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

# Optional SQL Server
variable "create_sql_server" {
  description = "Create SQL Server"
  type        = bool
  default     = false
}

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = null
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
  default     = null
}

# Optional Cosmos DB
variable "create_cosmos_db" {
  description = "Create Cosmos DB account"
  type        = bool
  default     = false
}

variable "cosmos_consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"
  
  validation {
    condition = contains(
      ["Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual"],
      var.cosmos_consistency_level
    )
    error_message = "Invalid consistency level."
  }
}
```

## Outputs

**File: outputs.tf**

```hcl
output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = module.storage_account.storage_account_id
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.vault_uri
}

output "sql_server_name" {
  description = "SQL Server name"
  value       = var.create_sql_server ? module.sql_server[0].sql_server_name : null
}

output "cosmos_account_name" {
  description = "Cosmos DB account name"
  value       = var.create_cosmos_db ? module.cosmos_db[0].cosmos_account_name : null
}
```

## Configuration Example

**File: data.tfvars**

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

# Storage Configuration
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Key Vault Configuration
key_vault_sku = "standard"

# SQL Server (Optional)
create_sql_server   = true
sql_admin_username  = "sqladmin"
sql_admin_password  = "ComplexP@ssw0rd!"

# Cosmos DB (Optional)
create_cosmos_db           = false
cosmos_consistency_level   = "Session"
```

## Deployment

```bash
# Initialize
terraform init \
  -backend-config="storage_account_name=${TF_STATE_SA_NAME}" \
  -backend-config="container_name=${TF_STATE_CONTAINER}" \
  -backend-config="key=spokes/{project-code}/data.tfstate" \
  -backend-config="resource_group_name=${TF_STATE_RG}"

# Plan
terraform plan -var-file=../../../../Deployment/Spokes/{project-code}/data/data.tfvars

# Apply
terraform apply -var-file=../../../../Deployment/Spokes/{project-code}/data/data.tfvars
```