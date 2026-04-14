# Azure Naming Convention Complete Reference

Complete naming standards for Azure resources.

## Naming Formulas

### Hub/Core Resources

**Format:**
```
[ResourceType]-[Org]-[Scope]-[Location]-[Component]-[Instance]
```

**Segments:**
- `ResourceType`: Standard abbreviation (e.g., `rg`, `vnet`, `kv`)
- `Org`: Organization identifier
- `Scope`: Always `hub` for Core resources
- `Location`: Region code (`cin`, `eus`, `weu`, `sin`)
- `Component`: Architectural layer (`network`, `data`, `compute`, `ai`, `identity`, `governance`)
- `Instance`: Two-digit sequence (`01`, `02`, `03`)

**Examples:**
- `rg-org-hub-cin-network-01`
- `vnet-org-hub-cin-01`
- `kv-org-hub-cin-data-01`
- `log-org-hub-cin-01`

### Spoke Resources

**Format:**
```
[ResourceType]-[Org]-[Project]-[Env]-[Location]-[Component]-[Instance]
```

**Segments:**
- `ResourceType`: Standard abbreviation
- `Org`: Organization identifier
- `Project`: Project code (max 6 chars, e.g., `ragbot`, `custbot`, `finbot`)
- `Env`: Environment (`dev`, `uat`, `prod`)
- `Location`: Region code
- `Component`: Architectural layer (`network`, `data`, `compute`, `ai`)
- `Instance`: Two-digit sequence

**Examples:**
- `rg-org-ragbot-dev-cin-data-01`
- `aks-org-ragbot-prod-cin-01`
- `kv-org-custbot-uat-cin-data-01`

## Location Codes

| Azure Region | Code |
|-------------|------|
| Central India | `cin` |
| East US | `eus` |
| West Europe | `weu` |
| South India | `sin` |

## Component Classifications

### Hub Components

- **network**: Networking infrastructure (VNet, Firewall, Bastion, VPN, Private DNS)
- **data**: Data services (Log Analytics, Storage for logs/backup, Key Vault)
- **compute**: Compute services (APIM, Shared App Service Plans)
- **ai**: AI services (Centralized Azure OpenAI)
- **identity**: Identity management (Managed Identities, RBAC)
- **governance**: Governance (Azure Policy, Defender for Cloud)

### Spoke Components

- **network**: Spoke networking (VNet, Subnets, NSGs, Private Endpoints)
- **data**: Data services (Storage, Databases, Key Vault, Messaging)
- **compute**: Compute resources (VMs, AKS, App Service, Functions)
- **ai**: AI services (Project-specific OpenAI, Cognitive Services)

## Validation Rules

### General Rules

1. **All lowercase**: No uppercase letters allowed
2. **Hyphen separator**: Use hyphens except for Storage Accounts and Container Registries
3. **No special characters**: Only lowercase letters, numbers, and hyphens
4. **Length limits**: Respect Azure resource name length limits (varies by resource type)

### Storage Accounts & Container Registries

These resources do NOT support hyphens:
- Remove all hyphens from the standard format
- Concatenate all segments together
- Result must be 3-24 characters (lowercase letters and numbers only)

**Example transformations:**
- Standard: `st-org-hub-cin-data-01`
- Actual: `storaghubcindata01`

- Standard: `acr-org-ragbot-dev-cin-01`
- Actual: `acrragbotdevcin01`

## Environment Codes

| Environment | Code |
|------------|------|
| Development | `dev` |
| UAT/Testing | `uat` |
| Production | `prod` |

**Hub Note:** Hub resources do NOT include environment in the name. Environment is specified via tags instead.

## Real-World Scenarios

### Scenario 1: New Spoke Project

Creating "Finance Automation Bot" (`finbot`) in Dev, Central India:

```
Resource Group:  rg-org-finbot-dev-cin-data-01
Key Vault:       kv-org-finbot-dev-cin-data-01
Storage:         storfinbotdevcindata01
AKS:             aks-org-finbot-dev-cin-01
```

### Scenario 2: Hub Storage for Audit Logs

Adding audit log storage in Hub, Central India:

```
Resource Group:  rg-org-hub-cin-data-01
Storage Account: storaghubcindata02
```

### Scenario 3: Multi-Environment Spoke

Same project across environments:

```
Dev:
  rg-org-ragbot-dev-cin-compute-01
  aks-org-ragbot-dev-cin-01

UAT:
  rg-org-ragbot-uat-cin-compute-01
  aks-org-ragbot-uat-cin-01

Prod:
  rg-org-ragbot-prod-cin-compute-01
  aks-org-ragbot-prod-cin-01
```

## Common Validation Errors

### ❌ Incorrect

```
# Wrong case
RG-ORG-HUB-CIN-DATA-01

# Wrong separator
rg_org_hub_cin_data_01

# Missing org
rg-hub-cin-data-01

# Wrong abbreviation
resourcegroup-org-hub-cin-data-01

# Storage with hyphens
st-org-hub-cin-data-01

# Environment in Hub name
rg-org-hub-prod-cin-data-01
```

### ✅ Correct

```
rg-org-hub-cin-data-01
storaghubcindata01
kv-org-ragbot-dev-cin-data-01
aks-org-custbot-prod-cin-01
```
