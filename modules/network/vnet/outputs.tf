output "id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.main.id
}

output "name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.main.name
}

output "address_space" {
  description = "Virtual network address space"
  value       = azurerm_virtual_network.main.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value       = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes[0] }
}
