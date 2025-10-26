output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.this.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall"
  value       = azurerm_firewall.this.name
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = azurerm_firewall.this.virtual_hub != null ? null : azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_public_ip_address_id" {
  description = "The public IP address ID associated with the Azure Firewall"
  value       = var.public_ip_address_id
}

output "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.this[0].id : var.firewall_policy_id
}

output "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.this[0].name : null
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "location" {
  description = "The location of the Azure Firewall"
  value       = var.location
}