# ---------------------------------------------------------------------------------------------------------------------
# FINBOT DATA - DEV ENVIRONMENT
# Generates: rg-ajfc-finbot-dev-cin-data-01, stajfcfinbotdevcin01, kv-ajfc-finbot-dev-cin-01
# ---------------------------------------------------------------------------------------------------------------------

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"

# Storage Account
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Key Vault
key_vault_sku              = "standard"
key_vault_soft_delete_days = 90
key_vault_purge_protection = true
