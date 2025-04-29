---
title: Network Settings Documentation
tags: 
 - devbox
 - network
 - virtual network
 - subnet
description: Network Settings Documentation
---

# Microsoft Dev Box Accelerator: Network Settings Documentation

## Overview

This documentation details the network configuration for Microsoft Dev Box Accelerator. The configuration defines a managed virtual network infrastructure that isolates Dev Box resources while enabling secure connectivity to both Azure services and corporate resources.

## Default Settings 

```yaml
# yaml-language-server: $schema=./network.schema.json
#
# Microsoft Dev Box Accelerator: Network Configuration
# ===============================================
# 
# Purpose: Defines the virtual network infrastructure for Microsoft Dev Box Accelerator environments.
# This configuration creates a managed virtual network that isolates DevBox resources
# while enabling secure connectivity to Azure services and corporate resources.
#
# References:
# - Azure VNet best practices: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/
# - DevBox networking: https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity

# Create flag: Determines whether to create a new virtual network (true) or use existing (false)
# Best practice: Create dedicated VNets per environment to maintain proper isolation
# Setting to true ensures a clean, dedicated network environment for DevBox resources
create: true

# Virtual Network Type: Controls how network connectivity is provisioned
# - Managed: Azure manages the network configuration (simpler, fewer permissions needed)
# - Unmanaged: Customer manages the network (greater control, required for hybrid scenarios)
# Best practice: Use Managed for dev/test; Unmanaged for production or when connecting to on-prem
virtualNetworkType: Managed

# Virtual Network Name: Identifier for the VNet resource
# Best practice naming: Use lowercase, include environment and purpose
# Format: [company]-[purpose]-[env]-vnet
name: contoso-vnet

# Address Prefixes: CIDR blocks that define the IP address range for the VNet
# Best practices:
# - Use private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
# - Ensure no overlap with on-premises or other Azure VNet ranges
# - Allocate sufficient address space for future growth (default provides 65,536 IPs)
addressPrefixes:
  - 10.0.0.0/16

# Subnets: Network segments within the VNet to organize and secure resources
# Best practices:
# - Create separate subnets based on workload type and security requirements
# - Apply NSGs at the subnet level for traffic filtering
# - Size subnets appropriately for the expected number of resources
subnets:
  - name: contoso-subnet
    properties:
      # Address Prefix: CIDR block for this subnet within the VNet's address space
      # A /24 subnet provides 251 usable IP addresses (Azure reserves 5 IPs)
      # Best practice: Size according to expected resource count plus room for growth
      addressPrefix: 10.0.1.0/24

# Tags: Metadata attached to resources for organization, governance, and cost management
# Best practices:
# - Apply consistent tags across all resources
# - Automate tagging with naming and tagging conventions
# - Include ownership, environment, and cost allocation information
tags:
  # Environment tag: Identifies the deployment environment
  # Values typically include: dev, test, staging, prod
  # Used for filtering resources and applying policies appropriately
  environment: dev
  
  # Division tag: Identifies the organizational division responsible for the resource
  # Helps with cost allocation and resource ownership at division level
  division: Platforms
  
  # Team tag: Identifies the team responsible for the resource
  # Used for operational ownership and access management
  team: DevExP
  
  # Project tag: Associates the resource with a specific project
  # Used for cost allocation and resource lifecycle management
  project: DevExP-DevBox
  
  # Cost Center tag: Links resource costs to specific cost centers
  # Essential for charge-back and show-back accounting models
  costCenter: IT
  
  # Owner tag: Identifies the resource owner (individual or team)
  # Critical for operational contacts and responsibility assignment
  owner: Contoso
  
  # Resources tag: Describes the resource type or purpose
  # Helps with resource categorization and filtering
  resources: Network
```
## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
- [Microsoft Dev Box Accelerator Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure Cloud Adoption Framework - Naming and Tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft Dev Box Accelerator GitHub](https://github.com/Evilazaro/DevExp-DevBox/)

---

*This documentation is part of the Microsoft Dev Box Accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*