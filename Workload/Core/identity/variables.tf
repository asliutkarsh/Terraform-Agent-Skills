# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "azure_subscription_id" {
  description = "Azure subscription ID for provider configuration"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# NAMING CONVENTION VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "org" {
  description = "Organization identifier (e.g., ajfc)"
  type        = string
  default     = "ajfc"
}

variable "scope" {
  description = "Scope identifier (hub for core resources)"
  type        = string
  default     = "hub"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"
}

variable "location_code" {
  description = "Short location code for naming (e.g., cin for Central India)"
  type        = string
  default     = "cin"
}

variable "component" {
  description = "Component name for resource group naming"
  type        = string
  default     = "identity"
}

variable "identity_purpose" {
  description = "Purpose of the managed identity for naming (e.g., github, cicd)"
  type        = string
  default     = "github"
}

variable "instance" {
  description = "Instance number for resource naming (two digits)"
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance))
    error_message = "Instance must be a two-digit number (e.g., 01, 02)"
  }
}

variable "owner" {
  description = "Owner team name for tagging"
  type        = string
  default     = "Platform Team"
}
