# Azure Resource Abbreviations

Standard abbreviations for Azure resources.

## Compute

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Virtual Machine | `vm` | `vm-org-ragbot-dev-cin-01` |
| VM Scale Set | `vmss` | `vmss-org-ragbot-dev-cin-01` |
| AKS Cluster | `aks` | `aks-org-ragbot-dev-cin-01` |
| App Service | `app` | `app-org-ragbot-dev-cin-fe-01` |
| App Service Plan | `asp` | `asp-org-ragbot-dev-cin-01` |
| Function App | `func` | `func-org-ragbot-dev-cin-01` |
| Container Instance | `aci` | `aci-org-ragbot-dev-cin-01` |
| Container App | `ca` | `ca-org-ragbot-dev-cin-01` |
| Container Registry | `acr` | `acrragbotdevcin01` (no hyphens) |

## Networking

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Resource Group | `rg` | `rg-org-hub-cin-network-01` |
| Virtual Network | `vnet` | `vnet-org-hub-cin-01` |
| Subnet | `snet` | `snet-private-endpoint` |
| Network Security Group | `nsg` | `nsg-org-ragbot-dev-cin-web-01` |
| Route Table | `rt` | `rt-org-hub-cin-01` |
| Public IP | `pip` | `pip-org-hub-cin-fw-01` |
| Load Balancer | `lb` | `lb-org-ragbot-dev-cin-01` |
| Application Gateway | `agw` | `agw-org-hub-cin-01` |
| VPN Gateway | `vpn` | `vpn-org-hub-cin-01` |
| ExpressRoute Circuit | `erc` | `erc-org-hub-cin-01` |
| Private Endpoint | `pe` | `pe-org-ragbot-dev-cin-kv-01` |
| DNS Zone | `dns` | `dns-org-hub-cin-01` |

## Data & Storage

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Storage Account | `st` | `storghubcindata01` (no hyphens) |
| SQL Database | `sqldb` | `sqldb-org-ragbot-dev-cin-01` |
| SQL Server | `sql` | `sql-org-ragbot-dev-cin-01` |
| Cosmos DB | `cosmos` | `cosmos-org-ragbot-dev-cin-01` |
| Event Hub | `evh` | `evh-org-ragbot-dev-cin-01` |
| Event Hub Namespace | `evhns` | `evhns-org-ragbot-dev-cin-01` |
| Service Bus | `sb` | `sb-org-ragbot-dev-cin-01` |
| Data Factory | `adf` | `adf-org-ragbot-dev-cin-01` |
| Synapse Workspace | `syn` | `syn-org-ragbot-dev-cin-01` |
| Databricks Workspace | `dbw` | `dbw-org-ragbot-dev-cin-01` |

## Security & Identity

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Key Vault | `kv` | `kv-org-hub-cin-data-01` |
| Managed Identity | `id` | `id-org-hub-cin-github-01` |

## Monitoring & Management

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Log Analytics Workspace | `log` | `log-org-hub-cin-01` |
| Application Insights | `appi` | `appi-org-ragbot-dev-cin-01` |
| Recovery Services Vault | `rsv` | `rsv-org-hub-cin-01` |

## AI & Cognitive Services

| Resource Type | Abbreviation | Example |
|--------------|--------------|---------|
| Cognitive Services | `cog` | `cog-org-ragbot-dev-cin-01` |
| Azure OpenAI | `oai` | `oai-org-hub-cin-01` |
| Machine Learning | `ml` | `ml-org-ragbot-dev-cin-01` |
| AI Search | `srch` | `srch-org-ragbot-dev-cin-01` |

## Special Cases

### Resources Without Hyphens

These resources do NOT support hyphens in their names:
- Storage Accounts (`st`)
- Container Registries (`acr`)

**Format for these resources:** Remove all hyphens and concatenate segments.

Example: `storgragbotdevcindata01` instead of `st-org-ragbot-dev-cin-data-01`
