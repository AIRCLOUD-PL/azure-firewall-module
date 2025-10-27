# Azure Firewall Terraform Module

This Terraform module creates an enterprise-grade Azure Firewall with advanced security, monitoring, and compliance features.

## Features

- **Advanced Security**: Threat intelligence, intrusion detection, and comprehensive rule management
- **High Availability**: Zone redundancy and forced tunneling support
- **Monitoring & Compliance**: Built-in diagnostic settings and Azure Policy integration
- **Scalability**: Support for both VNet and Virtual Hub deployments
- **Enterprise Ready**: Resource locks, managed identity, and comprehensive tagging

## Usage

```hcl
module "azure_firewall" {
  source = "./modules/network/azure-firewall"

  resource_group_name = "my-resource-group"
  location           = "East US 2"
  environment        = "prod"

  # Firewall Configuration
  sku_name = "AZFW_VNet"
  sku_tier = "Premium"

  # Network Configuration
  subnet_id           = azurerm_subnet.firewall.id
  public_ip_address_id = azurerm_public_ip.firewall.id

  # Firewall Policy
  create_firewall_policy = true
  firewall_policy_sku    = "Premium"

  # Security Rules
  application_rule_collections = [
    {
      name     = "app-rules"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name             = "allow-http"
          source_addresses = ["10.0.0.0/8"]
          target_fqdns     = ["*.microsoft.com"]
          protocols = [
            {
              type = "Http"
              port = 80
            }
          ]
        }
      ]
    }
  ]

  network_rule_collections = [
    {
      name     = "net-rules"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name                  = "allow-ssh"
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = ["192.168.1.0/24"]
          destination_ports     = ["22"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Security
  threat_intel_mode = "Deny"
  enable_resource_lock = true

  tags = {
    Environment = "production"
    Project     = "network-security"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_application_rule_collection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_application_rule_collection) | resource |
| [azurerm_firewall_network_rule_collection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_network_rule_collection) | resource |
| [azurerm_firewall_nat_rule_collection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_nat_rule_collection) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_policy_definition.firewall_threat_intel_mode](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.firewall_sku_tier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.firewall_policy_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.firewall_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom name for the firewall | `string` | `""` | no |
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | Name of the Azure Firewall. If empty, will be auto-generated. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `{}` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Create resource group if it doesn't exist | `bool` | `false` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the firewall | `string` | `"AZFW_VNet"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the firewall | `string` | `"Standard"` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | ID of the firewall policy to associate | `string` | `null` | no |
| <a name="input_create_firewall_policy"></a> [create\_firewall\_policy](#input\_create\_firewall\_policy) | Create a firewall policy if not provided | `bool` | `false` | no |
| <a name="input_firewall_policy_sku"></a> [firewall\_policy\_sku](#input\_firewall\_policy\_sku) | SKU for the firewall policy | `string` | `"Standard"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers | `list(string)` | `null` | no |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | List of private IP ranges | `list(string)` | `null` | no |
| <a name="input_threat_intel_mode"></a> [threat\_intel\_mode](#input\_threat\_intel\_mode) | Threat intelligence mode | `string` | `"Alert"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones | `list(string)` | `null` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | IP configuration for the firewall | <pre>object({<br>    name                 = optional(string, "firewall-ip-config")<br>    subnet_id           = optional(string)<br>    public_ip_address_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the firewall | `string` | `null` | no |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | Public IP address ID for the firewall | `string` | `null` | no |
| <a name="input_enable_forced_tunneling"></a> [enable\_forced\_tunneling](#input\_enable\_forced\_tunneling) | Enable forced tunneling | `bool` | `false` | no |
| <a name="input_management_subnet_id"></a> [management\_subnet\_id](#input\_management\_subnet\_id) | Management subnet ID for forced tunneling | `string` | `null` | no |
| <a name="input_management_public_ip_address_id"></a> [management\_public\_ip\_address\_id](#input\_management\_public\_ip\_address\_id) | Management public IP address ID for forced tunneling | `string` | `null` | no |
| <a name="input_application_rules"></a> [application\_rules](#input\_application\_rules) | List of application rules (deprecated - use application\_rule\_collections) | <pre>list(object({<br>    name             = string<br>    description      = optional(string)<br>    source_addresses = optional(list(string), [])<br>    source_ip_groups = optional(list(string), [])<br>    fqdn_tags        = optional(list(string), [])<br>    target_fqdns     = optional(list(string), [])<br>    protocols        = optional(list(object({<br>      type = string<br>      port = number<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | List of network rules (deprecated - use network\_rule\_collections) | <pre>list(object({<br>    name                  = string<br>    description           = optional(string)<br>    source_addresses      = optional(list(string), [])<br>    source_ip_groups      = optional(list(string), [])<br>    destination_addresses = optional(list(string), [])<br>    destination_ip_groups = optional(list(string), [])<br>    destination_fqdns     = optional(list(string), [])<br>    destination_ports     = list(string)<br>    protocols             = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_nat_rules"></a> [nat\_rules](#input\_nat\_rules) | List of NAT rules (deprecated - use nat\_rule\_collections) | <pre>list(object({<br>    name                  = string<br>    description           = optional(string)<br>    source_addresses      = optional(list(string), [])<br>    source_ip_groups      = optional(list(string), [])<br>    destination_addresses = list(string)<br>    destination_ports     = list(string)<br>    protocols             = list(string)<br>    translated_address    = string<br>    translated_port       = string<br>  }))</pre> | `[]` | no |
| <a name="input_application_rule_collections"></a> [application\_rule\_collections](#input\_application\_rule\_collections) | List of application rule collections | <pre>list(object({<br>    name     = string<br>    priority = number<br>    action   = string<br>    rules    = list(object({<br>      name             = string<br>      description      = optional(string)<br>      source_addresses = optional(list(string), [])<br>      source_ip_groups = optional(list(string), [])<br>      fqdn_tags        = optional(list(string), [])<br>      target_fqdns     = optional(list(string), [])<br>      protocols        = optional(list(object({<br>        type = string<br>        port = number<br>      })), [])<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_network_rule_collections"></a> [network\_rule\_collections](#input\_network\_rule\_collections) | List of network rule collections | <pre>list(object({<br>    name     = string<br>    priority = number<br>    action   = string<br>    rules    = list(object({<br>      name                  = string<br>      description           = optional(string)<br>      source_addresses      = optional(list(string), [])<br>      source_ip_groups      = optional(list(string), [])<br>      destination_addresses = optional(list(string), [])<br>      destination_ip_groups = optional(list(string), [])<br>      destination_fqdns     = optional(list(string), [])<br>      destination_ports     = list(string)<br>      protocols             = list(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_nat_rule_collections"></a> [nat\_rule\_collections](#input\_nat\_rule\_collections) | List of NAT rule collections | <pre>list(object({<br>    name     = string<br>    priority = number<br>    action   = string<br>    rules    = list(object({<br>      name                  = string<br>      description           = optional(string)<br>      source_addresses      = optional(list(string), [])<br>      source_ip_groups      = optional(list(string), [])<br>      destination_addresses = list(string)<br>      destination_ports     = list(string)<br>      protocols             = list(string)<br>      translated_address    = string<br>      translated_port       = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_dns_settings"></a> [dns\_settings](#input\_dns\_settings) | DNS settings for firewall policy | <pre>object({<br>    servers       = optional(list(string), [])<br>    proxy_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | Threat intelligence allowlist | <pre>object({<br>    ip_addresses = optional(list(string), [])<br>    fqdns        = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | Intrusion detection settings | <pre>object({<br>    mode = optional(string, "Off")<br>    signature_overrides = optional(list(object({<br>      id    = string<br>      state = string<br>    })), [])<br>    traffic_bypass = optional(list(object({<br>      name                  = string<br>      protocol              = string<br>      description           = optional(string)<br>      destination_addresses = optional(list(string), [])<br>      destination_ip_groups = optional(list(string), [])<br>      destination_ports     = optional(list(string), [])<br>      source_addresses      = optional(list(string), [])<br>      source_ip_groups      = optional(list(string), [])<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings for Azure Firewall | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration | <pre>object({<br>    logs = list(object({<br>      category = string<br>    }))<br>    metrics = list(object({<br>      category = string<br>      enabled  = bool<br>    }))<br>  })</pre> | <pre>{<br>  "logs": [<br>    {<br>      "category": "AzureFirewallApplicationRule"<br>    },<br>    {<br>      "category": "AzureFirewallNetworkRule"<br>    },<br>    {<br>      "category": "AzureFirewallNatRule"<br>    }<br>  ],<br>  "metrics": [<br>    {<br>      "category": "AllMetrics",<br>      "enabled": true<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_enable_resource_lock"></a> [enable\_resource\_lock](#input\_enable\_resource\_lock) | Enable resource lock for Azure Firewall | `bool` | `false` | no |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Resource lock level: CanNotDelete or ReadOnly | `string` | `"CanNotDelete"` | no |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | Enable public IP address for the firewall | `bool` | `true` | no |
| <a name="input_enable_firewall_policy"></a> [enable\_firewall\_policy](#input\_enable\_firewall\_policy) | Enable firewall policy creation | `bool` | `true` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments for the firewall | `bool` | `false` | no |
| <a name="input_create_custom_policies"></a> [create\_custom\_policies](#input\_create\_custom\_policies) | Create custom Azure Policy definitions | `bool` | `false` | no |
| <a name="input_policy_scope"></a> [policy\_scope](#input\_policy\_scope) | Scope for Azure Policy assignments (subscription or resource group) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | The ID of the Azure Firewall |
| <a name="output_firewall_name"></a> [firewall\_name](#output\_firewall\_name) | The name of the Azure Firewall |
| <a name="output_firewall_private_ip"></a> [firewall\_private\_ip](#output\_firewall\_private\_ip) | The private IP address of the Azure Firewall |
| <a name="output_firewall_public_ip_address_id"></a> [firewall\_public\_ip\_address\_id](#output\_firewall\_public\_ip\_address\_id) | The public IP address ID associated with the Azure Firewall |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | The ID of the Azure Firewall Policy |
| <a name="output_firewall_policy_name"></a> [firewall\_policy\_name](#output\_firewall\_policy\_name) | The name of the Azure Firewall Policy |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_location"></a> [location](#output\_location) | The location of the Azure Firewall |

## Security Features

- **Threat Intelligence**: Configurable threat intelligence mode (Off/Alert/Deny)
- **Intrusion Detection**: Advanced signature-based detection with custom overrides
- **Traffic Bypass**: Allow specific traffic to bypass inspection
- **DNS Security**: Secure DNS proxy and custom DNS servers
- **Resource Locks**: Prevent accidental deletion or modification

## Monitoring & Compliance

- **Diagnostic Settings**: Comprehensive logging to Log Analytics
- **Azure Policy**: Built-in and custom policy definitions
- **Resource Locks**: Infrastructure protection
- **Tagging**: Consistent resource tagging for governance

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic Firewall](./examples/basic-firewall/)
- [Advanced Security](./examples/advanced-security/)
- [Virtual Hub Integration](./examples/virtual-hub/)

## Contributing

Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting pull requests.

## License

This module is licensed under the MIT License. See [LICENSE](../../LICENSE) for details.
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
