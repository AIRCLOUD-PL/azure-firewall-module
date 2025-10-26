package test

import (
	"testing"
	"fmt"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAzureFirewallBasic(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-test-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-test-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":       firewallName,
			"resource_group_name": resourceGroupName,
			"location":            location,
			"environment":         "test",
			"sku_name":            "AZFW_VNet",
			"sku_tier":            "Standard",
			"threat_intel_mode":   "Alert",
			"application_rule_collections": []map[string]interface{}{
				{
					"name":     "app-rules",
					"priority": 100,
					"action":   "Allow",
					"rules": []map[string]interface{}{
						{
							"name":         "allow-web",
							"source_addresses": []string{"10.0.0.0/8"},
							"target_fqdns": []string{"*.microsoft.com"},
							"protocols": []map[string]interface{}{
								{
									"type": "Http",
									"port": 80,
								},
								{
									"type": "Https",
									"port": 443,
								},
							},
						},
					},
				},
			},
			"network_rule_collections": []map[string]interface{}{
				{
					"name":     "net-rules",
					"priority": 200,
					"action":   "Allow",
					"rules": []map[string]interface{}{
						{
							"name":                  "allow-dns",
							"source_addresses":      []string{"10.0.0.0/8"},
							"destination_addresses": []string{"8.8.8.8", "8.8.4.4"},
							"destination_ports":     []string{"53"},
							"protocols":             []string{"UDP"},
						},
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")

	// Verify firewall properties
	firewall := azure.GetFirewall(t, firewallName, resourceGroupName, "")
	assert.Equal(t, "AZFW_VNet", firewall.Sku.Name)
	assert.Equal(t, "Standard", firewall.Sku.Tier)
	assert.Equal(t, "Alert", firewall.ThreatIntelMode)
}

func TestAzureFirewallWithPolicy(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-policy-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-policy-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":         firewallName,
			"resource_group_name":   resourceGroupName,
			"location":              location,
			"environment":           "test",
			"create_firewall_policy": true,
			"firewall_policy_sku":   "Standard",
			"threat_intelligence_allowlist": map[string]interface{}{
				"ip_addresses": []string{"192.168.1.0/24"},
				"fqdns":        []string{"example.com"},
			},
			"intrusion_detection": map[string]interface{}{
				"mode": "Alert",
				"signature_overrides": []map[string]interface{}{
					{
						"id":    "12345",
						"state": "Off",
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")

	// Verify firewall policy exists
	policyName := fmt.Sprintf("%s-policy", firewallName)
	policyExists := azure.FirewallPolicyExists(t, policyName, resourceGroupName, "")
	require.True(t, policyExists, "Firewall Policy should exist")
}

func TestAzureFirewallWithNATRules(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-nat-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-nat-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":       firewallName,
			"resource_group_name": resourceGroupName,
			"location":            location,
			"environment":         "test",
			"nat_rule_collections": []map[string]interface{}{
				{
					"name":     "nat-rules",
					"priority": 300,
					"action":   "Dnat",
					"rules": []map[string]interface{}{
						{
							"name":                  "rdp-nat",
							"source_addresses":      []string{"*"},
							"destination_addresses": []string{"firewall-public-ip"},
							"destination_ports":     []string{"3389"},
							"protocols":             []string{"TCP"},
							"translated_address":    "10.0.0.4",
							"translated_port":       "3389",
						},
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")
}

func TestAzureFirewallPremium(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-premium-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-premium-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":       firewallName,
			"resource_group_name": resourceGroupName,
			"location":            location,
			"environment":         "test",
			"sku_tier":            "Premium",
			"create_firewall_policy": true,
			"firewall_policy_sku": "Premium",
			"dns_settings": map[string]interface{}{
				"servers":       []string{"8.8.8.8", "8.8.4.4"},
				"proxy_enabled": true,
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")

	// Verify firewall is Premium tier
	firewall := azure.GetFirewall(t, firewallName, resourceGroupName, "")
	assert.Equal(t, "Premium", firewall.Sku.Tier)
}

func TestAzureFirewallForcedTunneling(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-ft-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-ft-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":           firewallName,
			"resource_group_name":     resourceGroupName,
			"location":                location,
			"environment":             "test",
			"enable_forced_tunneling": true,
			// Note: In a real test, you would need to provide actual subnet and public IP IDs
			// "management_subnet_id": "subnet-id",
			// "management_public_ip_address_id": "pip-id",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")
}

func TestAzureFirewallInputValidation(t *testing.T) {
	t.Parallel()

	// Test invalid SKU name
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":       "test-invalid-sku",
			"resource_group_name": "rg-test",
			"location":            "East US",
			"environment":         "test",
			"sku_name":            "InvalidSKU",
		},
		ExpectFailure: true,
	}

	terraform.Init(t, terraformOptions)
	_, err := terraform.PlanE(t, terraformOptions)
	require.Error(t, err, "Should fail with invalid SKU name")
	assert.Contains(t, err.Error(), "sku_name", "Error should mention sku_name validation")
}

func TestAzureFirewallResourceLock(t *testing.T) {
	t.Parallel()

	// Generate unique names
	uniqueId := random.UniqueId()
	location := "East US"
	resourceGroupName := fmt.Sprintf("rg-afw-lock-%s", uniqueId)
	firewallName := fmt.Sprintf("afw-lock-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"firewall_name":         firewallName,
			"resource_group_name":   resourceGroupName,
			"location":              location,
			"environment":           "test",
			"enable_resource_lock":  true,
			"lock_level":            "CanNotDelete",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify Azure Firewall exists
	firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
	require.True(t, firewallExists, "Azure Firewall should exist")

	// Verify resource lock exists
	locks := azure.ListManagementLocks(t, resourceGroupName)
	lockExists := false
	for _, lock := range locks {
		if lock.Level == "CanNotDelete" {
			lockExists = true
			break
		}
	}
	assert.True(t, lockExists, "Resource lock should exist")
}

func TestAzureFirewallThreatIntelModes(t *testing.T) {
	t.Parallel()

	// Test different threat intel modes
	modes := []string{"Off", "Alert", "Deny"}

	for _, mode := range modes {
		t.Run(fmt.Sprintf("ThreatIntel_%s", mode), func(t *testing.T) {
			// Generate unique names
			uniqueId := random.UniqueId()
			location := "East US"
			resourceGroupName := fmt.Sprintf("rg-afw-ti-%s-%s", mode, uniqueId)
			firewallName := fmt.Sprintf("afw-ti-%s-%s", mode, uniqueId)

			terraformOptions := &terraform.Options{
				TerraformDir: "../",
				Vars: map[string]interface{}{
					"firewall_name":       firewallName,
					"resource_group_name": resourceGroupName,
					"location":            location,
					"environment":         "test",
					"threat_intel_mode":   mode,
				},
			}

			defer terraform.Destroy(t, terraformOptions)
			terraform.InitAndApply(t, terraformOptions)

			// Verify Azure Firewall exists
			firewallExists := azure.FirewallExists(t, firewallName, resourceGroupName, "")
			require.True(t, firewallExists, "Azure Firewall should exist")

			// Verify threat intel mode
			firewall := azure.GetFirewall(t, firewallName, resourceGroupName, "")
			assert.Equal(t, mode, firewall.ThreatIntelMode)
		})
	}
}