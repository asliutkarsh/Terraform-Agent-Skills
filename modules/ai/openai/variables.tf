variable "name" {
  description = "Name of the Azure OpenAI resource"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku_name" {
  description = "SKU for the cognitive account"
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain for the endpoint"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "deployments" {
  description = "List of model deployments"
  type = list(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = optional(string, "Standard")
    capacity      = optional(number, 1)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
