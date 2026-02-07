variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "org" {
  description = "Organization"
  type        = string
  default     = "ajfc"
}

variable "project" {
  description = "Project code"
  type        = string
  default     = "finbot"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "location_code" {
  description = "Location code"
  type        = string
  default     = "cin"
}

variable "instance" {
  description = "Instance number"
  type        = string
  default     = "01"
}

variable "owner" {
  description = "Owner team"
  type        = string
  default     = "FinTech Team"
}

variable "openai_sku" {
  description = "OpenAI SKU"
  type        = string
  default     = "S0"
}

variable "openai_public_access" {
  description = "Public network access"
  type        = bool
  default     = true
}

variable "openai_deployments" {
  description = "Model deployments"
  type = list(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = optional(string, "Standard")
    capacity      = optional(number, 1)
  }))
  default = []
}
