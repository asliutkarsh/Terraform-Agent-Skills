variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "org" {
  description = "Organization identifier"
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

variable "storage_account_tier" {
  description = "Storage tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication"
  type        = string
  default     = "LRS"
}

variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "key_vault_soft_delete_days" {
  description = "Soft delete retention"
  type        = number
  default     = 90
}

variable "key_vault_purge_protection" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}
