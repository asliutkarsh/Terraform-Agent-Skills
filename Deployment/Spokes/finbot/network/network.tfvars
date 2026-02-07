# ---------------------------------------------------------------------------------------------------------------------
# FINBOT NETWORK - DEV ENVIRONMENT
# Generates: rg-ajfc-finbot-dev-cin-network-01, vnet-ajfc-finbot-dev-cin-01
# ---------------------------------------------------------------------------------------------------------------------

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"

# Naming (defaults are correct for finbot dev)
# project      = "finbot"
# environment  = "dev"
# location     = "centralindia"
# location_code = "cin"
# owner        = "FinTech Team"

# Network Configuration
vnet_address_space = ["10.10.0.0/16"]

subnets = [
  {
    name           = "snet-app"
    address_prefix = "10.10.1.0/24"
    delegation     = null
  },
  {
    name           = "snet-data"
    address_prefix = "10.10.2.0/24"
    delegation     = null
  },
  {
    name           = "snet-private-endpoint"
    address_prefix = "10.10.3.0/24"
    delegation     = null
  }
]
