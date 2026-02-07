# Azure Resource Abbreviations

Standard abbreviations for Azure resources in AJFC organization.

## Compute

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Virtual Machine | `vm` | `vm-ajfc-ragbot-dev-cin-01` |
| VM Scale Set | `vmss` | `vmss-ajfc-ragbot-dev-cin-01` |
| AKS Cluster | `aks` | `aks-ajfc-ragbot-dev-cin-01` |
| App Service | `app` | `app-ajfc-ragbot-dev-cin-fe-01` |
| App Service Plan | `asp` | `asp-ajfc-ragbot-dev-cin-01` |
| Function App | `func` | `func-ajfc-ragbot-dev-cin-01` |
| Container Instance | `aci` | `aci-ajfc-ragbot-dev-cin-01` |
| Container App | `ca` | `ca-ajfc-ragbot-dev-cin-01` |
| Container Registry | `acr` | `acrajfcragbotdevcin01` (no hyphens) |

## Networking

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Resource Group | `rg` | `rg-ajfc-hub-cin-network-01` |
| Virtual Network | `vnet` | `vnet-ajfc-hub-cin-01` |
| Subnet | `snet` | `snet-private-endpoint` |
| Network Security Group | `nsg` | `nsg-ajfc-ragbot-dev-cin-web-01` |
| Route Table | `rt` | `rt-ajfc-hub-cin-01` |
| Public IP | `pip` | `pip-ajfc-hub-cin-fw-01` |
| Load Balancer | `lb` | `lb-ajfc-ragbot-dev-cin-01` |
| Application Gateway | `agw` | `agw-ajfc-hub-cin-01` |
| VPN Gateway | `vpn` | `vpn-ajfc-hub-cin-01` |
| ExpressRoute Circuit | `erc` | `erc-ajfc-hub-cin-01` |
| Private Endpoint | `pe` | `pe-ajfc-ragbot-dev-cin-kv-01` |
| DNS Zone | `dns` | `dns-ajfc-hub-cin-01` |

## Data & Storage

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Storage Account | `st` | `stajfchubcindata01` (no hyphens) |
| SQL Database | `sqldb` | `sqldb-ajfc-ragbot-dev-cin-01` |
| SQL Server | `sql` | `sql-ajfc-ragbot-dev-cin-01` |
| Cosmos DB | `cosmos` | `cosmos-ajfc-ragbot-dev-cin-01` |
| Event Hub | `evh` | `evh-ajfc-ragbot-dev-cin-01` |
| Event Hub Namespace | `evhns` | `evhns-ajfc-ragbot-dev-cin-01` |
| Service Bus | `sb` | `sb-ajfc-ragbot-dev-cin-01` |
| Data Factory | `adf` | `adf-ajfc-ragbot-dev-cin-01` |
| Synapse Workspace | `syn` | `syn-ajfc-ragbot-dev-cin-01` |
| Databricks Workspace | `dbw` | `dbw-ajfc-ragbot-dev-cin-01` |

## Security & Identity

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Key Vault | `kv` | `kv-ajfc-hub-cin-data-01` |
| Managed Identity | `id` | `id-ajfc-hub-cin-github-01` |

## Monitoring & Management

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Log Analytics Workspace | `log` | `log-ajfc-hub-cin-01` |
| Application Insights | `appi` | `appi-ajfc-ragbot-dev-cin-01` |
| Recovery Services Vault | `rsv` | `rsv-ajfc-hub-cin-01` |

## AI & Cognitive Services

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Cognitive Services | `cog` | `cog-ajfc-ragbot-dev-cin-01` |
| Azure OpenAI | `oai` | `oai-ajfc-hub-cin-01` |
| Machine Learning | `ml` | `ml-ajfc-ragbot-dev-cin-01` |
| AI Search | `srch` | `srch-ajfc-ragbot-dev-cin-01` |

## Special Cases

### Resources Without Hyphens

These resources do NOT support hyphens in their names:
- Storage Accounts (`st`)
- Container Registries (`acr`)

**Format for these resources:** Remove all hyphens and concatenate segments.

Example: `stajfcragbotdevcindata01` instead of `st-ajfc-ragbot-dev-cin-data-01`