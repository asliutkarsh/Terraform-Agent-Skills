# Azure Naming Convention Complete Reference

Complete naming standards for AJFC organization Azure resources.

## Naming Formulas

### Hub/Core Resources

**Format:**
```
[ResourceType]-[Org]-[Scope]-[Location]-[Component]-[Instance]
```

**Segments:**
- `ResourceType`: Standard abbreviation (e.g., `rg`, `vnet`, `kv`)
- `Org`: Always `ajfc`
- `Scope`: Always `hub` for Core resources
- `Location`: Region code (`cin`, `eus`, `weu`, `sin`)
- `Component`: Architectural layer (`network`, `data`, `compute`, `ai`, `identity`, `governance`)
- `Instance`: Two-digit sequence (`01`, `02`, `03`)

**Examples:**
- `rg-ajfc-hub-cin-network-01`
- `vnet-ajfc-hub-cin-01`
- `kv-ajfc-hub-cin-data-01`
- `log-ajfc-hub-cin-01`

### Spoke Resources

**Format:**
```
[ResourceType]-[Org]-[Project]-[Env]-[Location]-[Component]-[Instance]
```

**Segments:**
- `ResourceType`: Standard abbreviation
- `Org`: Always `ajfc`
- `Project`: Project code (max 6 chars, e.g., `ragbot`, `custbot`, `finbot`)
- `Env`: Environment (`dev`, `uat`, `prod`)
- `Location`: Region code
- `Component`: Architectural layer (`network`, `data`, `compute`, `ai`)
- `Instance`: Two-digit sequence

**Examples:**
- `rg-ajfc-ragbot-dev-cin-data-01`
- `aks-ajfc-ragbot-prod-cin-01`
- `kv-ajfc-custbot-uat-cin-data-01`

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
- Standard: `st-ajfc-hub-cin-data-01`
- Actual: `stajfchubcindata01`

- Standard: `acr-ajfc-ragbot-dev-cin-01`
- Actual: `acrajfcragbotdevcin01`

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
Resource Group:  rg-ajfc-finbot-dev-cin-data-01
Key Vault:       kv-ajfc-finbot-dev-cin-data-01
Storage:         stajfcfinbotdevcindata01
AKS:             aks-ajfc-finbot-dev-cin-01
```

### Scenario 2: Hub Storage for Audit Logs

Adding audit log storage in Hub, Central India:

```
Resource Group:  rg-ajfc-hub-cin-data-01
Storage Account: stajfchubcindata02
```

### Scenario 3: Multi-Environment Spoke

Same project across environments:

```
Dev:
  rg-ajfc-ragbot-dev-cin-compute-01
  aks-ajfc-ragbot-dev-cin-01

UAT:
  rg-ajfc-ragbot-uat-cin-compute-01
  aks-ajfc-ragbot-uat-cin-01

Prod:
  rg-ajfc-ragbot-prod-cin-compute-01
  aks-ajfc-ragbot-prod-cin-01
```

## Common Validation Errors

### ❌ Incorrect

```
# Wrong case
RG-AJFC-HUB-CIN-DATA-01

# Wrong separator
rg_ajfc_hub_cin_data_01

# Missing org
rg-hub-cin-data-01

# Wrong abbreviation
resourcegroup-ajfc-hub-cin-data-01

# Storage with hyphens
st-ajfc-hub-cin-data-01

# Environment in Hub name
rg-ajfc-hub-prod-cin-data-01
```

### ✅ Correct

```
rg-ajfc-hub-cin-data-01
stajfchubcindata01
kv-ajfc-ragbot-dev-cin-data-01
aks-ajfc-custbot-prod-cin-01
```