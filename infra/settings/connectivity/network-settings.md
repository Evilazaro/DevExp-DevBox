---
title: Network Settings Documentation
tags: 
 - devbox
 - network
 - virtual network
 - subnet
description: Network Settings Documentation
---

# Microsoft Dev Box landing zone accelerator: Network Settings Documentation

## Overview

This documentation details the network configuration for Microsoft Dev Box landing zone accelerator. The configuration defines a managed virtual network infrastructure that isolates Dev Box resources while enabling secure connectivity to both Azure services and corporate resources.

## Table of Contents

- [Configuration Purpose](#configuration-purpose)
- [Parameters](#parameters)
  - [Network Creation](#netwrk-creation)
  - [Virtual Network Type](#virtual-network-type)
  - [Virtual Network Name](#virtual-network-name)
  - [Address Space](#address-space)
  - [Subnet Configuration](#subnet-configuration)
  - [Resource Tagging](#resource-tagging)
  - [Best Practices](#best-practices)
  - [References](#references)

## Configuration Purpose

The network configuration (`network.yaml`) establishes the networking foundation for Microsoft Dev Box landing zone accelerator environments. It defines a virtual network that:

- Creates isolated network boundaries for Dev Box workstations
- Enables controlled access to Azure services
- Provides connectivity options to corporate networks
- Follows Azure networking best practices

## Network Creation

```yaml
create: true
```

**Description**: Determines whether to create a new virtual network or use an existing one.

**Options**:
- `true`: Creates a new dedicated virtual network (recommended for isolation)
- `false`: Uses an existing virtual network (use when integrating with established networks)

**Best practice**: Create dedicated VNets per environment to maintain proper isolation between development, testing, and production workloads.

## Virtual Network Type

```yaml
virtualNetworkType: Managed
```

**Description**: Controls how network connectivity is provisioned and managed.

**Options**:
- `Managed`: Azure manages the network configuration
  - Simpler setup
  - Fewer permissions needed
  - Handles DNS resolution automatically
  - Azure handles connectivity management
  
- `Unmanaged`: Customer manages the network configuration
  - Provides greater control
  - Required for hybrid connectivity scenarios
  - Allows custom DNS configuration
  - Enables integration with on-premises networks

**Best practice**: Use Managed for dev/test environments; switch to Unmanaged for production or when connecting to on-premises networks.

## Virtual Network Name

```yaml
name: contoso-vnet
```

**Description**: Identifier for the VNet resource in Azure.

**Naming convention best practices**:
- Use lowercase letters, numbers, and hyphens
- Include company name, purpose, and environment
- Follow format: `[company]-[purpose]-[env]-vnet`
- Keep names consistent across environments

**Examples**:
- `contoso-devbox-dev-vnet`
- `contoso-devbox-prod-vnet`

## Address Space

```yaml
addressPrefixes:
  - 10.0.0.0/16
```

**Description**: CIDR blocks that define the IP address range for the virtual network.

**Configuration details**:
- Uses private IP range (10.0.0.0/16) providing 65,536 IP addresses
- Can include multiple address prefixes if needed
- Follows RFC 1918 private address standards

**Best practices**:
- Use private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Ensure no overlap with on-premises networks or other Azure VNets
- Allocate sufficient address space for future growth
- Document your IP addressing scheme

## Subnet Configuration

```yaml
subnets:
  - name: contoso-subnet
    properties:
      addressPrefix: 10.0.1.0/24
```

**Description**: Network segments within the VNet to organize and secure resources.

**Configuration details**:
- `name`: Identifies the subnet (should follow naming conventions)
- `addressPrefix`: CIDR block for the subnet within the VNet's address space
  - A /24 subnet provides 251 usable IP addresses (Azure reserves 5 IPs)

**Best practices**:
- Create separate subnets based on workload type and security requirements
- Apply Network Security Groups (NSGs) at the subnet level for traffic filtering
- Size subnets appropriately for the expected number of resources plus growth
- Consider adding service endpoints to secure access to Azure services

## Resource Tagging

```yaml
tags:
  environment: dev
  division: Platforms
  team: DevExP
  project: DevExP-DevBox
  costCenter: IT
  owner: Contoso
  resources: Network
```

**Description**: Metadata attached to resources for organization, governance, and cost management.

**Tag details**:
- `environment`: Identifies the deployment environment (dev, test, staging, prod)
- `division`: Organizational division responsible for the resource
- `team`: Team responsible for operational ownership
- `project`: Associates the resource with a specific project
- `costCenter`: Links resource costs to specific cost centers
- `owner`: Identifies the resource owner (individual or team)
- `resources`: Describes the resource type or purpose

**Best practices**:
- Apply consistent tags across all resources
- Automate tagging with naming and tagging conventions
- Include ownership, environment, and cost allocation information
- Use Azure Policy to enforce mandatory tags
- Regularly audit and update tags

## Best Practices

### Network Design
- Implement network segmentation to isolate workloads
- Use NSGs to control traffic between subnets
- Plan IP addressing across environments to avoid overlaps
- Enable Azure DDoS Protection Standard for production workloads

### Connectivity
- For hybrid scenarios, consider ExpressRoute or Site-to-Site VPN
- Use Azure Private Link for secure access to Azure PaaS services
- Implement Azure Bastion for secure VM access
- Use service endpoints to secure traffic to Azure services

### Management
- Document your network architecture and IP addressing scheme
- Implement Azure Monitor for network insights
- Use Network Watcher for troubleshooting
- Apply consistent naming and tagging strategies

### Security
- Follow Zero Trust principles for network design
- Implement defense in depth with multiple security controls
- Regularly review and audit network security group rules
- Use Just-In-Time VM access for administrative connections

## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
- [Microsoft Dev Box landing zone accelerator Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure Cloud Adoption Framework - Naming and Tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft Dev Box landing zone accelerator GitHub](https://github.com/Evilazaro/DevExp-DevBox/)

---

*This documentation is part of the Microsoft Dev Box landing zone accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*