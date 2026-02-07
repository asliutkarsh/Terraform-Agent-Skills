# ---------------------------------------------------------------------------------------------------------------------
# FINBOT COMPUTE - DEV ENVIRONMENT
# Generates: rg-ajfc-finbot-dev-cin-compute-01, aks-ajfc-finbot-dev-cin-01
# ---------------------------------------------------------------------------------------------------------------------

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"

# Remote state for network dependency
state_storage_account = "YOUR_STATE_STORAGE_ACCOUNT"
state_container       = "tfstate"
state_resource_group  = "YOUR_STATE_RG"

# AKS Configuration
aks_node_count         = 2
aks_vm_size            = "Standard_D2s_v3"
aks_enable_autoscaling = false
# aks_min_count        = 1
# aks_max_count        = 5
