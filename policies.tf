# Azure Policy Definitions for Azure Firewall
# This file contains Azure Policy definitions to enforce security and compliance for Azure Firewall

# Custom Policy Definition for Firewall Threat Intelligence Mode
resource "azurerm_policy_definition" "firewall_threat_intel_mode" {
  count = var.create_custom_policies ? 1 : 0

  name         = "${local.firewall_name}-threat-intel-policy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Azure Firewall should have threat intelligence mode set to Deny"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/azureFirewalls"
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Network/azureFirewalls"
        existenceCondition = {
          field  = "Microsoft.Network/azureFirewalls/threatIntelMode"
          equals = "Deny"
        }
      }
    }
  })

  metadata = jsonencode({
    category = "Network"
  })
}

# Custom Policy Definition for Firewall SKU Tier
resource "azurerm_policy_definition" "firewall_sku_tier" {
  count = var.create_custom_policies ? 1 : 0

  name         = "${local.firewall_name}-sku-tier-policy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Azure Firewall should use Premium tier for advanced security features"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/azureFirewalls"
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Network/azureFirewalls"
        existenceCondition = {
          field  = "Microsoft.Network/azureFirewalls/sku.tier"
          equals = "Premium"
        }
      }
    }
  })

  metadata = jsonencode({
    category = "Network"
  })
}

# Custom Policy Definition for Firewall Policy Association
resource "azurerm_policy_definition" "firewall_policy_association" {
  count = var.create_custom_policies ? 1 : 0

  name         = "${local.firewall_name}-policy-association"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Azure Firewall should be associated with a Firewall Policy"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/azureFirewalls"
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Network/azureFirewalls"
        existenceCondition = {
          field  = "Microsoft.Network/azureFirewalls/firewallPolicy"
          exists = true
        }
      }
    }
  })

  metadata = jsonencode({
    category = "Network"
  })
}

# Custom Policy Definition for Firewall Diagnostic Settings
resource "azurerm_policy_definition" "firewall_diagnostic_settings" {
  count = var.create_custom_policies ? 1 : 0

  name         = "${local.firewall_name}-diagnostic-settings"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Azure Firewall should have diagnostic settings enabled"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/azureFirewalls"
    }
    then = {
      effect = "AuditIfNotExists"
      details = {
        type = "Microsoft.Insights/diagnosticSettings"
        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.Insights/diagnosticSettings/logs.enabled"
              equals = true
            },
            {
              field  = "Microsoft.Insights/diagnosticSettings/metrics.enabled"
              equals = true
            }
          ]
        }
      }
    }
  })

  metadata = jsonencode({
    category = "Monitoring"
  })
}