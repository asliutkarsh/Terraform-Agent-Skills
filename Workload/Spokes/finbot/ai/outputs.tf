output "resource_group_id" {
  description = "Resource group ID"
  value       = module.ai_rg.id
}

output "openai_id" {
  description = "Azure OpenAI ID"
  value       = module.openai.id
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = module.openai.endpoint
}

output "openai_deployment_ids" {
  description = "Model deployment IDs"
  value       = module.openai.deployment_ids
}
