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
  description = "Component name for resource naming"
  type        = string
  default     = "data"
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

# ---------------------------------------------------------------------------------------------------------------------
# STORAGE ACCOUNT VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium"
  }
}

variable "storage_replication_type" {
  description = "Storage replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Invalid storage replication type"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOG ANALYTICS VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "log_analytics_sku" {
  description = "Log Analytics workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics data retention in days (30-730)"
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Retention days must be between 30 and 730"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY VAULT VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium"
  }
}

variable "key_vault_soft_delete_days" {
  description = "Key Vault soft delete retention days (7-90)"
  type        = number
  default     = 90

  validation {
    condition     = var.key_vault_soft_delete_days >= 7 && var.key_vault_soft_delete_days <= 90
    error_message = "Soft delete days must be between 7 and 90"
  }
}

variable "key_vault_purge_protection" {
  description = "Enable Key Vault purge protection (recommended for production)"
  type        = bool
  default     = true
}
