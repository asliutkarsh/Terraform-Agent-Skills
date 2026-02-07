# ---------------------------------------------------------------------------------------------------------------------
# FINBOT AI - DEV ENVIRONMENT
# Generates: rg-ajfc-finbot-dev-cin-ai-01, oai-ajfc-finbot-dev-cin-01
# ---------------------------------------------------------------------------------------------------------------------

azure_subscription_id = "YOUR_SUBSCRIPTION_ID"

# OpenAI Configuration
openai_sku           = "S0"
openai_public_access = true

# Model Deployments
openai_deployments = [
  {
    name          = "gpt-4"
    model_name    = "gpt-4"
    model_version = "0613"
    sku_name      = "Standard"
    capacity      = 1
  },
  {
    name          = "text-embedding"
    model_name    = "text-embedding-ada-002"
    model_version = "2"
    sku_name      = "Standard"
    capacity      = 1
  }
]
