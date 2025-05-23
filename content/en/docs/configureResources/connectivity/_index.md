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

The **newtork.yaml** file defines the virtual network infrastructure for Microsoft Dev Box environments. It specifies how Azure Virtual Networks (VNets) and subnets are created and configured, ensuring secure, isolated, and scalable connectivity for Dev Box resources. This configuration is essential for managing network boundaries, applying security controls, and supporting connectivity to Azure services and corporate resources.

This file is intended for use with infrastructure-as-code deployments, enabling repeatable, auditable, and automated network provisioning in Azure.

---

## Table of Contents

- [Overview](#overview)
- [Configuration Items](#configuration-items)
  - [`create`](#create)
  - [`virtualNetworkType`](#virtualnetworktype)
  - [`name`](#name)
  - [`addressPrefixes`](#addressprefixes)
  - [`subnets`](#subnets)
  - [`tags`](#tags)
- [Best Practices](#best-practices)
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

---

## Configuration Items

### `create`

- **Description:** Determines whether to create a new virtual network (`true`) or use an existing one (`false`).
- **Type:** Boolean
- **Example:**
  ```yaml
  create: true
  ```
- **Use Case:**  
  Set to `true` to provision a dedicated VNet for each environment, ensuring isolation and reducing the risk of cross-environment interference.

---

### `virtualNetworkType`

- **Description:** Specifies how the network is managed.
- **Options:**
  - `Managed`: Azure manages the network configuration (recommended for dev/test).
  - `Unmanaged`: The customer manages the network (required for hybrid or production scenarios).
- **Example:**
  ```yaml
  virtualNetworkType: Managed
  ```
- **Use Case:**  
  Use `Managed` for simplicity and reduced permissions in dev/test. Use `Unmanaged` for greater control, especially when integrating with on-premises networks.

---

### `name`

- **Description:** The name of the virtual network resource.
- **Type:** String
- **Naming Convention:** Lowercase, includes company, purpose, environment, and `vnet` suffix.
- **Example:**
  ```yaml
  name: contoso-vnet
  ```
- **Use Case:**  
  Ensures consistent and descriptive naming for easier management and identification.

---

### `addressPrefixes`

- **Description:** List of CIDR blocks defining the VNet's IP address space.
- **Type:** Array of strings
- **Example:**
  ```yaml
  addressPrefixes:
    - 10.0.0.0/16
  ```
- **Use Case:**  
  Use private address ranges. Avoid overlaps with on-premises or other Azure VNets. Allocate enough space for current and future resources.

---

### `subnets`

- **Description:** Defines subnets within the VNet, each with its own address prefix and properties.
- **Type:** Array of objects
- **Example:**
  ```yaml
  subnets:
    - name: contoso-subnet
      properties:
        addressPrefix: 10.0.1.0/24
  ```
- **Use Case:**  
  Segment resources by workload or security requirements. Apply Network Security Groups (NSGs) at the subnet level for traffic filtering.

---

### `tags`

- **Description:** Key-value pairs for resource metadata, organization, governance, and cost management.
- **Type:** Object
- **Example:**
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
- **Use Case:**  
  Enables filtering, cost allocation, and policy enforcement. Tags should be consistent and automated where possible.

---

## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
- [Dev Box Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure Resource Tagging Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)