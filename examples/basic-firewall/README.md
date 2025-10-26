# Basic Azure Firewall Example

This example demonstrates how to create a basic Azure Firewall with essential security rules and monitoring.

## Overview

This example creates:
- A resource group
- A virtual network with a firewall subnet
- A public IP address for the firewall
- A Log Analytics workspace for monitoring
- An Azure Firewall with basic application and network rules
- Diagnostic settings for monitoring

## Architecture

```
Internet -> Public IP -> Azure Firewall -> Virtual Network
                              |
                              v
                       Log Analytics Workspace
```

## Usage

1. Navigate to this directory:
   ```bash
   cd examples/basic-firewall
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Clean up when done:
   ```bash
   terraform destroy
   ```

## Configuration

The firewall is configured with:
- **SKU**: AZFW_VNet (Standard tier)
- **Threat Intelligence**: Alert mode
- **Application Rules**: Allow HTTPS traffic to Azure services
- **Network Rules**: Allow DNS queries to Google DNS
- **Monitoring**: Full diagnostic logging to Log Analytics

## Security Features

- Threat intelligence enabled (Alert mode)
- Application and network rule collections
- Diagnostic logging for security monitoring
- Resource tagging for governance

## Outputs

- `firewall_id`: The resource ID of the Azure Firewall
- `firewall_name`: The name of the Azure Firewall
- `firewall_private_ip`: Private IP address of the firewall
- `firewall_public_ip_address_id`: Public IP address ID
- `firewall_policy_id`: ID of the associated firewall policy

## Next Steps

- Explore the [advanced security example](../advanced-security/) for more sophisticated configurations
- Review the [virtual hub example](../virtual-hub/) for hub-and-spoke architectures
- Check the main module [README](../../README.md) for all available options