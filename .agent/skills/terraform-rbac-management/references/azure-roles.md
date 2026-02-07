# Azure Built-In Roles Reference

Complete reference of commonly used Azure built-in roles for RBAC assignments.

## General Access Roles

### Owner
- **ID:** `8e3af657-a8ff-443c-a75c-2fe8c4bcb635`
- **Description:** Full access to all resources, including the ability to assign roles
- **Use cases:** Platform administrators, automation accounts with full control
- **Caution:** Highest level of access, use sparingly

### Contributor
- **ID:** `b24988ac-6180-42a0-ab88-20f7382dd24c`
- **Description:** Full access to manage all resources, but cannot assign roles
- **Use cases:** Development teams, operators who manage resources
- **Limitation:** Cannot grant access to others

### Reader
- **ID:** `acdd72a7-3385-48ef-bd42-f606fba81ae7`
- **Description:** View all resources but cannot make changes
- **Use cases:** Auditing, monitoring, read-only access
- **Limitation:** No write or delete permissions

## Key Vault Roles

### Key Vault Administrator
- **ID:** `00482a5a-887f-4fb3-b363-3b7fe8e74483`
- **Description:** Perform all data plane operations on a key vault and all objects in it
- **Use cases:** Key Vault full management
- **Scope:** Key Vault level

### Key Vault Secrets User
- **ID:** `4633458b-17de-408a-b874-0445c86b69e6`
- **Description:** Read secret contents
- **Use cases:** Applications reading secrets, CI/CD pipelines
- **Best practice:** Prefer this over broader roles for secret access

### Key Vault Secrets Officer
- **ID:** `b86a8fe4-44ce-4948-aee5-eccb2c155cd7`
- **Description:** Perform any action on secrets except manage permissions
- **Use cases:** Secret management, rotation automation
- **Scope:** Key Vault level

### Key Vault Certificates Officer
- **ID:** `a4417e6f-fecd-4de8-b567-7b0420556985`
- **Description:** Perform any action on certificates except manage permissions
- **Use cases:** Certificate management, renewal automation
- **Scope:** Key Vault level

### Key Vault Crypto Officer
- **ID:** `14b46e9e-c2b7-41b4-b07b-48a6ebf60603`
- **Description:** Perform any action on keys except manage permissions
- **Use cases:** Key management, encryption operations
- **Scope:** Key Vault level

### Key Vault Crypto User
- **ID:** `12338af0-0e69-4776-bea7-57ae8d297424`
- **Description:** Perform cryptographic operations using keys
- **Use cases:** Encryption/decryption operations in applications
- **Scope:** Key Vault level

## Storage Roles

### Storage Account Contributor
- **ID:** `17d1049b-9a84-46fb-8f53-869881c3d3ab`
- **Description:** Manage storage accounts, but not access to data
- **Use cases:** Storage account management, configuration
- **Note:** Does not include data access

### Storage Blob Data Owner
- **ID:** `b7e6dc6d-f1e8-4753-8033-0f276bb0955b`
- **Description:** Full access to Azure Storage blob containers and data
- **Use cases:** Full blob data management
- **Includes:** Read, write, delete, and manage ACLs

### Storage Blob Data Contributor
- **ID:** `ba92f5b4-2d11-453d-a403-e96b0029c9fe`
- **Description:** Read, write, and delete Azure Storage blob containers and data
- **Use cases:** Application data access, data processing
- **Common:** Most applications use this role

### Storage Blob Data Reader
- **ID:** `2a2b9908-6ea1-4ae2-8e65-a410df84e7d1`
- **Description:** Read Azure Storage blob containers and data
- **Use cases:** Read-only application access, data consumers
- **Best practice:** Use when write access not needed

### Storage Queue Data Contributor
- **ID:** `974c5e8b-45b9-4653-ba55-5f855dd0fb88`
- **Description:** Read, write, and delete Azure Storage queues and queue messages
- **Use cases:** Queue processing applications
- **Scope:** Storage account or queue level

### Storage Queue Data Reader
- **ID:** `19e7f393-937e-4f77-808e-94535e297925`
- **Description:** Read Azure Storage queues and queue messages
- **Use cases:** Queue monitoring, read-only queue access
- **Scope:** Storage account or queue level

### Storage Table Data Contributor
- **ID:** `0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3`
- **Description:** Read, write, and delete Azure Storage tables and entities
- **Use cases:** Table storage applications
- **Scope:** Storage account or table level

## Identity & Access Management Roles

### User Access Administrator
- **ID:** `18d7d88d-d35e-4fb5-a5c3-7773c20a72d9`
- **Description:** Manage user access to Azure resources
- **Use cases:** Delegated access management
- **Scope:** Typically subscription or management group

### Managed Identity Operator
- **ID:** `f1a07417-d97a-45cb-824c-7a7467783830`
- **Description:** Read and assign user-assigned managed identities
- **Use cases:** Assigning identities to resources
- **Scope:** Resource group or subscription

### Managed Identity Contributor
- **ID:** `e40ec5ca-96e0-45a2-b4ff-59039f2c2b59`
- **Description:** Create, read, update, and delete user-assigned managed identities
- **Use cases:** Identity lifecycle management
- **Scope:** Resource group or subscription

## Compute Roles

### Virtual Machine Contributor
- **ID:** `9980e02c-c2be-4d73-94e8-173b1dc7cf3c`
- **Description:** Manage virtual machines but not access to them
- **Use cases:** VM lifecycle management
- **Note:** Does not include network or storage management

### Virtual Machine Administrator Login
- **ID:** `1c0163c0-47e6-4577-8991-ea5c82e286e4`
- **Description:** View VMs and login as administrator
- **Use cases:** Admin access to VMs
- **Requires:** Azure AD authentication on VM

### Virtual Machine User Login
- **ID:** `fb879df8-f326-4884-b1cf-06f3ad86be52`
- **Description:** View VMs and login as a regular user
- **Use cases:** Standard user access to VMs
- **Requires:** Azure AD authentication on VM

### Azure Kubernetes Service Cluster Admin Role
- **ID:** `0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8`
- **Description:** List cluster admin credentials
- **Use cases:** Full AKS cluster access
- **Scope:** AKS cluster level

### Azure Kubernetes Service Cluster User Role
- **ID:** `4abbcc35-e782-43d8-92c5-2d3f1bd2253f`
- **Description:** List cluster user credentials
- **Use cases:** Standard AKS cluster access
- **Scope:** AKS cluster level

### Azure Kubernetes Service Contributor Role
- **ID:** `ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8`
- **Description:** Manage AKS clusters
- **Use cases:** AKS cluster management
- **Scope:** Resource group or subscription

## Network Roles

### Network Contributor
- **ID:** `4d97b98b-1d4f-4787-a291-c67834d212e7`
- **Description:** Manage networks but not access to them
- **Use cases:** Network infrastructure management
- **Scope:** Network resources

### DNS Zone Contributor
- **ID:** `befefa01-2a29-4197-83a8-272ff33ce314`
- **Description:** Manage DNS zones and record sets
- **Use cases:** DNS management, automation
- **Scope:** DNS zones

## Monitoring & Logging Roles

### Monitoring Contributor
- **ID:** `749f88d5-cbae-40b8-bcfc-e573ddc772fa`
- **Description:** Read all monitoring data and edit monitoring settings
- **Use cases:** Monitoring configuration, alert management
- **Scope:** Monitoring resources

### Monitoring Reader
- **ID:** `43d0d8ad-25c7-4714-9337-8ba259a9fe05`
- **Description:** Read all monitoring data
- **Use cases:** Read-only monitoring access
- **Scope:** Monitoring resources

### Log Analytics Contributor
- **ID:** `92aaf0da-9dab-42b6-94a3-d43ce8d16293`
- **Description:** Read all monitoring data and edit monitoring settings
- **Use cases:** Log Analytics workspace management
- **Scope:** Log Analytics workspaces

### Log Analytics Reader
- **ID:** `73c42c96-874c-492b-b04d-ab87d138a893`
- **Description:** View and search all monitoring data
- **Use cases:** Log query and analysis
- **Scope:** Log Analytics workspaces

## Database Roles

### SQL DB Contributor
- **ID:** `9b7fa17d-e63e-47b0-bb0a-15c516ac86ec`
- **Description:** Manage SQL databases but not access to them
- **Use cases:** Database lifecycle management
- **Note:** Does not include data access

### SQL Server Contributor
- **ID:** `6d8ee4ec-f05a-4a1d-8b00-a9b17e38b437`
- **Description:** Manage SQL servers and databases but not access to them
- **Use cases:** SQL Server management
- **Note:** Does not include data access

### Cosmos DB Account Reader Role
- **ID:** `fbdf93bf-df7d-467e-a4d2-9458aa1360c8`
- **Description:** Read Azure Cosmos DB account data
- **Use cases:** Read-only Cosmos DB access
- **Scope:** Cosmos DB account

### Cosmos DB Operator
- **ID:** `230815da-be43-4aae-9cb4-875f7bd000aa`
- **Description:** Manage Azure Cosmos DB accounts
- **Use cases:** Cosmos DB management
- **Note:** Cannot access data

## Application Roles

### Application Insights Component Contributor
- **ID:** `ae349356-3a1b-4a5e-921d-050484c6347e`
- **Description:** Manage Application Insights components
- **Use cases:** Application Insights management
- **Scope:** Application Insights resources

### App Service Contributor
- **ID:** `de139f84-1756-47ae-9be6-808fbbe84772`
- **Description:** Manage App Service but not access to them
- **Use cases:** App Service lifecycle management
- **Scope:** App Service resources

### Web Plan Contributor
- **ID:** `2cc479cb-7b4d-49a8-b449-8c00fd0f0a4b`
- **Description:** Manage the web plans for websites
- **Use cases:** App Service Plan management
- **Scope:** App Service Plans

## Backup & Recovery Roles

### Backup Contributor
- **ID:** `5e467623-bb1f-42f4-a55d-6e525e11384b`
- **Description:** Manage backup services but cannot remove protection
- **Use cases:** Backup operations management
- **Scope:** Recovery Services Vault

### Backup Operator
- **ID:** `00c29273-979b-4161-815c-10b084fb9324`
- **Description:** Manage backup services except removal of backup and vault creation
- **Use cases:** Backup job execution
- **Scope:** Recovery Services Vault

### Backup Reader
- **ID:** `a795c7a0-d4a2-40c1-ae25-d81f01202912`
- **Description:** View backup services
- **Use cases:** Backup monitoring
- **Scope:** Recovery Services Vault

## Role Selection Guide

### For CI/CD Pipelines

**Full automation:**
```hcl
role_name = "Owner"
scope_type = "subscription"
```

**Infrastructure deployment:**
```hcl
role_name = "Contributor"
scope_type = "subscription"
```

**Secret management:**
```hcl
role_name = "Key Vault Secrets Officer"
scope_type = "key_vault"
```

### For Applications

**Reading secrets:**
```hcl
role_name = "Key Vault Secrets User"
scope_type = "key_vault"
```

**Storage access:**
```hcl
role_name = "Storage Blob Data Contributor"
scope_type = "storage_account"
```

### For Users

**Development team:**
```hcl
role_name = "Contributor"
scope_type = "resource_group"
```

**Read-only access:**
```hcl
role_name = "Reader"
scope_type = "resource_group"
```

## Best Practices

1. **Start with least privilege** - Begin with Reader, add permissions as needed
2. **Prefer specific roles** - Use "Key Vault Secrets User" over "Contributor"
3. **Scope appropriately** - Assign at resource level when possible
4. **Document assignments** - Always include description field
5. **Regular audits** - Review assignments quarterly
6. **Avoid Owner** - Use only when absolutely necessary

## Finding Role IDs

```bash
# List all roles
az role definition list --query "[].{Name:roleName, ID:name}" -o table

# Search for specific role
az role definition list --name "Storage Blob Data Contributor"

# Get role details
az role definition list --name "Key Vault Secrets User" --query "[0]"
```