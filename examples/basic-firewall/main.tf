# Basic Azure Firewall Example
# This example demonstrates how to create a basic Azure Firewall with essential security rules

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-firewall-example"
  location = "East US 2"

  tags = {
    Environment = "example"
    Module      = "azure-firewall"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-firewall-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "example"
    Module      = "azure-firewall"
  }
}

# Firewall Subnet
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "example"
    Module      = "azure-firewall"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-firewall-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "example"
    Module      = "azure-firewall"
  }
}

# Azure Firewall Module
module "azure_firewall" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "example"

  # Firewall Configuration
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  # Network Configuration
  subnet_id            = azurerm_subnet.firewall.id
  public_ip_address_id = azurerm_public_ip.firewall.id

  # Firewall Policy
  create_firewall_policy = true
  firewall_policy_sku    = "Standard"

  # Basic Application Rules
  application_rule_collections = [
    {
      name     = "app-rules"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name             = "allow-azure-services"
          source_addresses = ["10.0.0.0/8"]
          target_fqdns     = ["*.azure.com", "*.microsoft.com"]
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
        }
      ]
    }
  ]

  # Basic Network Rules
  network_rule_collections = [
    {
      name     = "net-rules"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name                  = "allow-dns"
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = ["8.8.8.8", "8.8.4.4"]
          destination_ports     = ["53"]
          protocols             = ["UDP"]
        }
      ]
    }
  ]

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Security
  threat_intel_mode = "Alert"

  tags = {
    Environment = "example"
    Module      = "azure-firewall"
  }
}

# Outputs
output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = module.azure_firewall.firewall_id
}

output "firewall_name" {
  description = "The name of the Azure Firewall"
  value       = module.azure_firewall.firewall_name
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = module.azure_firewall.firewall_private_ip
}

output "firewall_public_ip_address_id" {
  description = "The public IP address ID associated with the Azure Firewall"
  value       = module.azure_firewall.firewall_public_ip_address_id
}

output "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy"
  value       = module.azure_firewall.firewall_policy_id
}