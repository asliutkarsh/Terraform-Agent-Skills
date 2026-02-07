# ---------------------------------------------------------------------------------------------------------------------
# HUB DATA RESOURCES CONFIGURATION
# Generates: rg-ajfc-hub-cin-data-01, stajfchubcindata01, log-ajfc-hub-cin-01, kv-ajfc-hub-cin-data-01
# ---------------------------------------------------------------------------------------------------------------------

# Required
azure_subscription_id = "YOUR_SUBSCRIPTION_ID"

# Naming convention (defaults generate correct names)
# org           = "ajfc"
# scope         = "hub"
# location      = "centralindia"
# location_code = "cin"
# component     = "data"
# instance      = "01"
# owner         = "Platform Team"

# Storage Account (optional overrides)
# storage_account_tier     = "Standard"
# storage_replication_type = "LRS"

# Log Analytics (optional overrides)
# log_analytics_sku            = "PerGB2018"
# log_analytics_retention_days = 30

# Key Vault (optional overrides)
# key_vault_sku              = "standard"
# key_vault_soft_delete_days = 90
# key_vault_purge_protection = true
