variable "name" {
  description = "Name of the AKS cluster"
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

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes in the default pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "subnet_id" {
  description = "Subnet ID for the node pool"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 128
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 5
}

variable "network_plugin" {
  description = "Network plugin (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
