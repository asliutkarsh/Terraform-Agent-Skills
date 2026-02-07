# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# NAMING CONVENTION VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "org" {
  description = "Organization identifier"
  type        = string
  default     = "ajfc"
}

variable "project" {
  description = "Project code (max 6 chars)"
  type        = string
  default     = "finbot"

  validation {
    condition     = length(var.project) <= 6
    error_message = "Project code must be 6 characters or less"
  }
}

variable "environment" {
  description = "Environment (dev, uat, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod"
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "location_code" {
  description = "Short location code"
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

# ---------------------------------------------------------------------------------------------------------------------
# NETWORK VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnets" {
  description = "Subnet configurations"
  type = list(object({
    name           = string
    address_prefix = string
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
  default = []
}
