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

# Remote state config
variable "state_storage_account" {
  description = "State storage account name"
  type        = string
}

variable "state_container" {
  description = "State container name"
  type        = string
}

variable "state_resource_group" {
  description = "State storage resource group"
  type        = string
}

# AKS config
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "aks_node_count" {
  description = "Number of nodes"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_enable_autoscaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = false
}

variable "aks_min_count" {
  description = "Min node count"
  type        = number
  default     = 1
}

variable "aks_max_count" {
  description = "Max node count"
  type        = number
  default     = 5
}
