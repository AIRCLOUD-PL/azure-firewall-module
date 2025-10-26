variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "location_short" {
  description = "Short name for the location (e.g., 'eus' for East US)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = string
}

variable "custom_name" {
  description = "Custom name for the firewall"
  type        = string
  default     = ""
}

variable "firewall_name" {
  description = "Name of the Azure Firewall. If empty, will be auto-generated."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "create_resource_group" {
  description = "Create resource group if it doesn't exist"
  type        = bool
  default     = false
}

variable "sku_name" {
  description = "SKU name for the firewall"
  type        = string
  default     = "AZFW_VNet"
  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "SKU name must be AZFW_VNet or AZFW_Hub."
  }
}

variable "sku_tier" {
  description = "SKU tier for the firewall"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be Standard or Premium."
  }
}

variable "firewall_policy_id" {
  description = "ID of the firewall policy to associate"
  type        = string
  default     = null
}

variable "create_firewall_policy" {
  description = "Create a firewall policy if not provided"
  type        = bool
  default     = false
}

variable "firewall_policy_sku" {
  description = "SKU for the firewall policy"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_policy_sku)
    error_message = "Firewall policy SKU must be Standard or Premium."
  }
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = null
}

variable "private_ip_ranges" {
  description = "List of private IP ranges"
  type        = list(string)
  default     = null
}

variable "threat_intel_mode" {
  description = "Threat intelligence mode"
  type        = string
  default     = "Alert"
  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "Threat intel mode must be Off, Alert, or Deny."
  }
}

variable "zones" {
  description = "Availability zones"
  type        = list(string)
  default     = null
}

variable "ip_configuration" {
  description = "IP configuration for the firewall"
  type = object({
    name                 = optional(string, "firewall-ip-config")
    subnet_id            = optional(string)
    public_ip_address_id = optional(string)
  })
  default = null
}

variable "subnet_id" {
  description = "Subnet ID for the firewall"
  type        = string
  default     = null
}

variable "public_ip_address_id" {
  description = "Public IP address ID for the firewall"
  type        = string
  default     = null
}

variable "enable_forced_tunneling" {
  description = "Enable forced tunneling"
  type        = bool
  default     = false
}

variable "management_subnet_id" {
  description = "Management subnet ID for forced tunneling"
  type        = string
  default     = null
}

variable "management_public_ip_address_id" {
  description = "Management public IP address ID for forced tunneling"
  type        = string
  default     = null
}

variable "application_rules" {
  description = "List of application rules (deprecated - use application_rule_collections)"
  type = list(object({
    name             = string
    description      = optional(string)
    source_addresses = optional(list(string), [])
    source_ip_groups = optional(list(string), [])
    fqdn_tags        = optional(list(string), [])
    target_fqdns     = optional(list(string), [])
    protocols = optional(list(object({
      type = string
      port = number
    })), [])
  }))
  default = []
}

variable "network_rules" {
  description = "List of network rules (deprecated - use network_rule_collections)"
  type = list(object({
    name                  = string
    description           = optional(string)
    source_addresses      = optional(list(string), [])
    source_ip_groups      = optional(list(string), [])
    destination_addresses = optional(list(string), [])
    destination_ip_groups = optional(list(string), [])
    destination_fqdns     = optional(list(string), [])
    destination_ports     = list(string)
    protocols             = list(string)
  }))
  default = []
}

variable "nat_rules" {
  description = "List of NAT rules (deprecated - use nat_rule_collections)"
  type = list(object({
    name                  = string
    description           = optional(string)
    source_addresses      = optional(list(string), [])
    source_ip_groups      = optional(list(string), [])
    destination_addresses = list(string)
    destination_ports     = list(string)
    protocols             = list(string)
    translated_address    = string
    translated_port       = string
  }))
  default = []
}

variable "application_rule_collections" {
  description = "List of application rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name             = string
      description      = optional(string)
      source_addresses = optional(list(string), [])
      source_ip_groups = optional(list(string), [])
      fqdn_tags        = optional(list(string), [])
      target_fqdns     = optional(list(string), [])
      protocols = optional(list(object({
        type = string
        port = number
      })), [])
    }))
  }))
  default = []
}

variable "network_rule_collections" {
  description = "List of network rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      description           = optional(string)
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
      destination_fqdns     = optional(list(string), [])
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))
  default = []
}

variable "nat_rule_collections" {
  description = "List of NAT rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      description           = optional(string)
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
      translated_address    = string
      translated_port       = string
    }))
  }))
  default = []
}

variable "dns_settings" {
  description = "DNS settings for firewall policy"
  type = object({
    servers       = optional(list(string), [])
    proxy_enabled = optional(bool, false)
  })
  default = null
}

variable "threat_intelligence_allowlist" {
  description = "Threat intelligence allowlist"
  type = object({
    ip_addresses = optional(list(string), [])
    fqdns        = optional(list(string), [])
  })
  default = null
}

variable "intrusion_detection" {
  description = "Intrusion detection settings"
  type = object({
    mode = optional(string, "Off")
    signature_overrides = optional(list(object({
      id    = string
      state = string
    })), [])
    traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      destination_addresses = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
      destination_ports     = optional(list(string), [])
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
    })), [])
  })
  default = null
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Azure Firewall"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_settings" {
  description = "Diagnostic settings configuration"
  type = object({
    logs = list(object({
      category = string
    }))
    metrics = list(object({
      category = string
      enabled  = bool
    }))
  })
  default = {
    logs = [
      { category = "AzureFirewallApplicationRule" },
      { category = "AzureFirewallNetworkRule" },
      { category = "AzureFirewallNatRule" }
    ]
    metrics = [
      { category = "AllMetrics", enabled = true }
    ]
  }
}

variable "enable_resource_lock" {
  description = "Enable resource lock for Azure Firewall"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "Resource lock level: CanNotDelete or ReadOnly"
  type        = string
  default     = "CanNotDelete"
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level must be CanNotDelete or ReadOnly."
  }
}

variable "enable_public_ip" {
  description = "Enable public IP address for the firewall"
  type        = bool
  default     = true
}

variable "enable_firewall_policy" {
  description = "Enable firewall policy creation"
  type        = bool
  default     = true
}

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for the firewall"
  type        = bool
  default     = false
}

variable "create_custom_policies" {
  description = "Create custom Azure Policy definitions"
  type        = bool
  default     = false
}

variable "policy_scope" {
  description = "Scope for Azure Policy assignments (subscription or resource group)"
  type        = string
  default     = null
}