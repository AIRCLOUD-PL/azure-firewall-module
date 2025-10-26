# Azure Firewall Module
# Creates enterprise-grade Azure Firewall with advanced security, monitoring, and compliance features

# Data sources
data "azurerm_client_config" "current" {}

# Local values
locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  location_short      = var.location_short
  environment         = var.environment
  custom_name         = var.custom_name

  # Naming convention
  name_prefix = "afw${local.custom_name}${local.location_short}${local.environment}"

  # Azure Firewall name
  firewall_name = var.firewall_name != "" ? var.firewall_name : local.name_prefix

  # Resource tags
  tags = merge(
    {
      Environment = local.environment
      Location    = local.location
      Service     = "Azure Firewall"
      Module      = "network/azure-firewall"
      CreatedBy   = "Terraform"
      CreatedOn   = timestamp()
    },
    var.tags
  )

  # IP Configuration
  ip_configuration = var.ip_configuration != null ? var.ip_configuration : {
    name                 = "firewall-ip-config"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }

  # Management IP Configuration
  management_ip_configuration = var.enable_forced_tunneling ? {
    name                 = "firewall-mgmt-ip-config"
    subnet_id            = var.management_subnet_id
    public_ip_address_id = var.management_public_ip_address_id
  } : null

  # Application Rules
  application_rules = {
    for rule in var.application_rules : rule.name => {
      name             = rule.name
      description      = lookup(rule, "description", null)
      source_addresses = lookup(rule, "source_addresses", [])
      source_ip_groups = lookup(rule, "source_ip_groups", [])
      fqdn_tags        = lookup(rule, "fqdn_tags", [])
      target_fqdns     = lookup(rule, "target_fqdns", [])
      protocols        = lookup(rule, "protocols", [])
    }
  }

  # Network Rules
  network_rules = {
    for rule in var.network_rules : rule.name => {
      name                  = rule.name
      description           = lookup(rule, "description", null)
      source_addresses      = lookup(rule, "source_addresses", [])
      source_ip_groups      = lookup(rule, "source_ip_groups", [])
      destination_addresses = lookup(rule, "destination_addresses", [])
      destination_ip_groups = lookup(rule, "destination_ip_groups", [])
      destination_fqdns     = lookup(rule, "destination_fqdns", [])
      destination_ports     = rule.destination_ports
      protocols             = rule.protocols
    }
  }

  # NAT Rules
  nat_rules = {
    for rule in var.nat_rules : rule.name => {
      name                  = rule.name
      description           = lookup(rule, "description", null)
      source_addresses      = lookup(rule, "source_addresses", [])
      source_ip_groups      = lookup(rule, "source_ip_groups", [])
      destination_addresses = rule.destination_addresses
      destination_ports     = rule.destination_ports
      protocols             = rule.protocols
      translated_address    = rule.translated_address
      translated_port       = rule.translated_port
    }
  }
}

# Resource Group (if not provided externally)
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

# Azure Firewall
resource "azurerm_firewall" "this" {
  name                = local.firewall_name
  location            = local.location
  resource_group_name = local.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  dns_servers         = var.dns_servers
  private_ip_ranges   = var.private_ip_ranges
  threat_intel_mode   = var.threat_intel_mode
  zones               = var.zones

  dynamic "ip_configuration" {
    for_each = [local.ip_configuration]
    content {
      name                 = ip_configuration.value.name
      subnet_id            = lookup(ip_configuration.value, "subnet_id", null)
      public_ip_address_id = lookup(ip_configuration.value, "public_ip_address_id", null)
    }
  }

  dynamic "management_ip_configuration" {
    for_each = local.management_ip_configuration != null ? [local.management_ip_configuration] : []
    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_resource_group.this
  ]
}

# Application Rule Collection
resource "azurerm_firewall_application_rule_collection" "this" {
  for_each = { for collection in var.application_rule_collections : collection.name => collection }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = local.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name             = rule.value.name
      description      = lookup(rule.value, "description", null)
      source_addresses = lookup(rule.value, "source_addresses", [])
      source_ip_groups = lookup(rule.value, "source_ip_groups", [])
      fqdn_tags        = lookup(rule.value, "fqdn_tags", [])
      target_fqdns     = lookup(rule.value, "target_fqdns", [])

      dynamic "protocol" {
        for_each = lookup(rule.value, "protocols", [])
        content {
          type = protocol.value.type
          port = protocol.value.port
        }
      }
    }
  }

  depends_on = [
    azurerm_firewall.this
  ]
}

# Network Rule Collection
resource "azurerm_firewall_network_rule_collection" "this" {
  for_each = { for collection in var.network_rule_collections : collection.name => collection }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = local.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name                  = rule.value.name
      description           = lookup(rule.value, "description", null)
      source_addresses      = lookup(rule.value, "source_addresses", [])
      source_ip_groups      = lookup(rule.value, "source_ip_groups", [])
      destination_addresses = lookup(rule.value, "destination_addresses", [])
      destination_ip_groups = lookup(rule.value, "destination_ip_groups", [])
      destination_fqdns     = lookup(rule.value, "destination_fqdns", [])
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
    }
  }

  depends_on = [
    azurerm_firewall.this
  ]
}

# NAT Rule Collection
resource "azurerm_firewall_nat_rule_collection" "this" {
  for_each = { for collection in var.nat_rule_collections : collection.name => collection }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = local.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = each.value.rules
    content {
      name                  = rule.value.name
      description           = lookup(rule.value, "description", null)
      source_addresses      = lookup(rule.value, "source_addresses", [])
      source_ip_groups      = lookup(rule.value, "source_ip_groups", [])
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
      translated_address    = rule.value.translated_address
      translated_port       = rule.value.translated_port
    }
  }

  depends_on = [
    azurerm_firewall.this
  ]
}

# Firewall Policy (if not provided externally)
resource "azurerm_firewall_policy" "this" {
  count = var.create_firewall_policy ? 1 : 0

  name                = "${local.firewall_name}-policy"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = var.firewall_policy_sku

  dynamic "dns" {
    for_each = var.dns_settings != null ? [var.dns_settings] : []
    content {
      servers       = lookup(dns.value, "servers", [])
      proxy_enabled = lookup(dns.value, "proxy_enabled", false)
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist != null ? [var.threat_intelligence_allowlist] : []
    content {
      ip_addresses = lookup(threat_intelligence_allowlist.value, "ip_addresses", [])
      fqdns        = lookup(threat_intelligence_allowlist.value, "fqdns", [])
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? [var.intrusion_detection] : []
    content {
      mode = lookup(intrusion_detection.value, "mode", "Off")

      dynamic "signature_overrides" {
        for_each = lookup(intrusion_detection.value, "signature_overrides", [])
        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = lookup(intrusion_detection.value, "traffic_bypass", [])
        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = lookup(traffic_bypass.value, "description", null)
          destination_addresses = lookup(traffic_bypass.value, "destination_addresses", [])
          destination_ports     = lookup(traffic_bypass.value, "destination_ports", [])
          source_addresses      = lookup(traffic_bypass.value, "source_addresses", [])
        }
      }
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_resource_group.this
  ]
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${local.firewall_name}-diagnostics"
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_settings.logs
    content {
      category = enabled_log.value.category
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_settings.metrics
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }
}

# Resource Lock
resource "azurerm_management_lock" "this" {
  count = var.enable_resource_lock ? 1 : 0

  name       = "${local.firewall_name}-lock"
  scope      = azurerm_firewall.this.id
  lock_level = var.lock_level
  notes      = "Resource lock for Azure Firewall"
}