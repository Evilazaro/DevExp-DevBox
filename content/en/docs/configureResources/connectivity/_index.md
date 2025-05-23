---
title: 'Network and Connectivity'
description: >
  How to configure the Azure Virtual Network, Subnets and Virtual Network type for Dev Center
tags:
  - azure
  - microsoft-dev-box
  - azure-networking
  - virtual-network
  - subnet
  - infrastructure-as-code
  - network-security


weight: 8
---

## Overview

The **newtork.yaml** file is a core configuration file for the Microsoft Dev Box Accelerator, specifically designed to define and manage the virtual network infrastructure for Dev Box environments. This YAML file enables teams to declaratively specify how Dev Box resources are isolated, connected, and governed within Azure. By leveraging this configuration, organizations can ensure secure, scalable, and well-organized network topologies that align with both Azure best practices and internal governance requirements.

This file is part of the broader Dev Box Accelerator feature set, which streamlines the provisioning, management, and security of developer environments in Azure. The network configuration defined here plays a crucial role in enabling secure connectivity to Azure services, corporate resources, and the internet, while maintaining proper isolation between environments.

## Table of Contents

- [Overview](#overview)
- [Table of Contents](#table-of-contents)
- [Configuration Items](#configuration-items)
  - [create](#create)
  - [virtualNetworkType](#virtualnetworktype)
  - [name](#name)
  - [addressPrefixes](#addressprefixes)
  - [subnets](#subnets)
  - [tags](#tags)
- [Best Practices](#best-practices)
- [Considerations](#considerations)
- [References](#references)

---
## Default Configuration

```yaml
# yaml-language-server: $schema=./network.schema.json
#
# Microsoft Dev Box accelerator: Network Configuration
# ===============================================
# 
# Purpose: Defines the virtual network infrastructure for environments.
# This configuration creates a managed virtual network that isolates DevBox resources
# while enabling secure connectivity to Azure services and corporate resources.
#
# References:
# - Azure VNet best practices: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/
# - DevBox networking: https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity

create: true
virtualNetworkType: Managed
name: contoso-vnet
addressPrefixes:
  - 10.0.0.0/16
subnets:
  - name: contoso-subnet
    properties:
      addressPrefix: 10.0.1.0/24

tags:
  environment: dev
  division: Platforms
  team: DevExP
  project: DevExP-DevBox
  costCenter: IT
  owner: Contoso
  resources: Network
```

## Configuration Items

### create

- **Configuration Purpose**:  
  Determines whether a new virtual network should be created or an existing one should be used.
- **Default Configuration**:  
  ```yaml
  create: true
  ```
- **Configuration Structure**:  
  Boolean (`true` or `false`)
- **Detailed Configuration**:  
  - `true`: A new VNet will be created as defined in this file.
  - `false`: An existing VNet will be used; other VNet parameters should reference the existing resource.
- **Use Cases**:  
  - Set to `true` for greenfield deployments where isolation and a clean environment are required.
  - Set to `false` when integrating with pre-existing network infrastructure.
- **Best Practices**:  
  - Use `true` to ensure proper isolation for each environment.
  - For production or hybrid scenarios, consider using existing, well-managed VNets.
- **Considerations**:  
  - Creating new VNets may require additional configuration for connectivity with on-premises or other Azure resources.

---

### virtualNetworkType

- **Configuration Purpose**:  
  Specifies whether the VNet is managed by Azure or by the customer.
- **Default Configuration**:  
  ```yaml
  virtualNetworkType: Managed
  ```
- **Configuration Structure**:  
  String (`Managed` or `Unmanaged`)
- **Detailed Configuration**:  
  - `Managed`: Azure automates network configuration, simplifying setup and reducing required permissions.
  - `Unmanaged`: The customer is responsible for network configuration, providing greater control and flexibility.
- **Use Cases**:  
  - Use `Managed` for dev/test environments or when simplicity is preferred.
  - Use `Unmanaged` for production or hybrid scenarios requiring custom routing, security, or on-premises connectivity.
- **Best Practices**:  
  - Default to `Managed` unless advanced networking features are required.
- **Considerations**:  
  - `Unmanaged` networks require more expertise and maintenance.

---

### name

- **Configuration Purpose**:  
  Sets the name of the virtual network resource.
- **Default Configuration**:  
  ```yaml
  name: contoso-vnet
  ```
- **Configuration Structure**:  
  String (resource name)
- **Detailed Configuration**:  
  - Should follow naming conventions for clarity and manageability.
  - Format: `[company]-[purpose]-[env]-vnet`
- **Use Cases**:  
  - Naming for easy identification in the Azure portal and automation scripts.
- **Best Practices**:  
  - Use lowercase, include company, purpose, environment, and resource type.
- **Considerations**:  
  - Avoid special characters; ensure uniqueness within the resource group.

---

### addressPrefixes

- **Configuration Purpose**:  
  Defines the IP address range(s) for the VNet using CIDR notation.
- **Default Configuration**:  
  ```yaml
  addressPrefixes:
    - 10.0.0.0/16
  ```
- **Configuration Structure**:  
  List of strings (CIDR blocks)
- **Detailed Configuration**:  
  - Use private IP ranges (e.g., 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16).
  - Ensure no overlap with on-premises or other Azure VNets.
- **Use Cases**:  
  - Allocating sufficient address space for current and future workloads.
- **Best Practices**:  
  - Plan for growth; avoid overlapping with other networks.
- **Considerations**:  
  - Changing address space after deployment is complex.

---

### subnets

- **Configuration Purpose**:  
  Defines subnets within the VNet for segmenting resources.
- **Default Configuration**:  
  ```yaml
  subnets:
    - name: contoso-subnet
      properties:
        addressPrefix: 10.0.1.0/24
  ```
- **Configuration Structure**:  
  List of objects, each with:
  - `name`: String (subnet name)
  - `properties.addressPrefix`: String (CIDR block)
- **Detailed Configuration**:  
  - Each subnet should be sized for expected resource count plus growth.
  - Subnets can be used to apply network security groups (NSGs) and route tables.
- **Use Cases**:  
  - Isolating workloads, applying security policies, or segmenting environments.
- **Best Practices**:  
  - Create separate subnets for different workloads or security zones.
  - Apply NSGs at the subnet level.
- **Considerations**:  
  - Azure reserves 5 IPs per subnet; plan accordingly.

---

### tags

- **Configuration Purpose**:  
  Attaches metadata to resources for organization, governance, and cost management.
- **Default Configuration**:  
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
- **Configuration Structure**:  
  Key-value pairs (strings)
- **Detailed Configuration**:  
  - `environment`: Deployment environment (dev, test, staging, prod)
  - `division`: Organizational division responsible for the resource
  - `team`: Team responsible for the resource
  - `project`: Associated project
  - `costCenter`: Cost center for charge-back/show-back
  - `owner`: Resource owner (individual or team)
  - `resources`: Resource type or purpose
- **Use Cases**:  
  - Filtering resources, applying policies, cost allocation, and lifecycle management.
- **Best Practices**:  
  - Apply consistent tags across all resources.
  - Automate tagging where possible.
- **Considerations**:  
  - Inconsistent tagging can hinder resource management and reporting.

---

## Best Practices

- Use dedicated VNets per environment for isolation.
- Prefer managed VNets for simplicity unless advanced features are needed.
- Follow naming conventions for all resources.
- Allocate sufficient address space for future growth.
- Segment workloads using subnets and apply NSGs at the subnet level.
- Apply consistent and comprehensive tags for all resources.
- Regularly review and update network configurations to align with organizational and security requirements.

## Considerations

- Ensure address spaces do not overlap with on-premises or other Azure VNets.
- Changing network configuration post-deployment can be disruptive.
- Unmanaged networks require more expertise and maintenance.
- Proper tagging is essential for governance and cost management.

## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
- [Dev Box Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure Resource Naming](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Tagging](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)

---
```
