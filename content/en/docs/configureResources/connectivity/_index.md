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

This document provides a comprehensive analysis of the [**newtork.yaml**](https://github.com/Evilazaro/DevExp-DevBox/blob/main/infra/settings/connectivity/newtork.yaml) configuration file, a core component of the **Microsoft Dev Box Accelerator**. This YAML file defines the virtual network (VNet) infrastructure for Dev Box environments, enabling secure, isolated, and scalable connectivity for development resources in Azure. The modular and decoupled design of this configuration allows organizations to tailor network settings to their specific needs, ensuring best practices for security, governance, and operational efficiency.

---

## Table of Contents

- [Overview](#overview)
- [Configurations](#configurations)
  - [Create Flag](#create-flag)
  - [Virtual Network Type](#virtual-network-type)
  - [Virtual Network Name](#virtual-network-name)
  - [Address Prefixes](#address-prefixes)
  - [Subnets](#subnets)
  - [Tags](#tags)
- [Examples and Use Cases](#examples-and-use-cases)
  - [Example 1: Isolated Dev Environment](#example-1-isolated-dev-environment)
  - [Example 2: Hybrid Production Scenario](#example-2-hybrid-production-scenario)
- [Best Practices](#best-practices)

## Configurations

Below, each section and key of the YAML file is explained in detail, with the corresponding YAML representation.

### Create Flag

```yaml
create: true
```
- **Purpose:** Determines whether to create a new VNet (`true`) or use an existing one (`false`).
- **Best Practice:** Use `true` to ensure a dedicated, isolated network for each environment.

---

### Virtual Network Type

```yaml
virtualNetworkType: Managed
```
- **Options:**
  - `Managed`: Azure manages the network configuration (recommended for dev/test).
  - `Unmanaged`: Customer manages the network (required for hybrid or production scenarios).
- **Best Practice:** Use `Managed` for simplicity and security in dev/test; use `Unmanaged` for advanced scenarios.

---

### Virtual Network Name

```yaml
name: contoso-vnet
```
- **Purpose:** Unique identifier for the VNet resource.
- **Naming Convention:** `[company]-[purpose]-[env]-vnet` (e.g., `contoso-dev-dev-vnet`).

---

### Address Prefixes

```yaml
addressPrefixes:
  - 10.0.0.0/16
```
- **Purpose:** Defines the IP address range for the VNet using CIDR notation.
- **Best Practices:**
  - Use private ranges (e.g., `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`).
  - Avoid overlaps with on-premises or other Azure VNets.
  - Allocate enough space for current and future needs.

---

### Subnets

```yaml
subnets:
  - name: contoso-subnet
    properties:
      addressPrefix: 10.0.1.0/24
```
- **Purpose:** Defines network segments within the VNet.
- **Best Practices:**
  - Create separate subnets for different workloads or security zones.
  - Apply Network Security Groups (NSGs) at the subnet level.
  - Size subnets appropriately (e.g., `/24` provides 251 usable IPs).

---

### Tags

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
- **Purpose:** Metadata for resource organization, governance, and cost management.
- **Common Tags:**
  - `environment`: Deployment environment (dev, test, staging, prod).
  - `division`: Organizational division responsible.
  - `team`: Team responsible for the resource.
  - `project`: Associated project.
  - `costCenter`: For charge-back/accounting.
  - `owner`: Individual or team owner.
  - `resources`: Resource type or purpose.
- **Best Practices:**
  - Apply consistent tags across all resources.
  - Automate tagging where possible.

---

## Examples and Use Cases

### Example 1: Isolated Dev Environment

A development team needs a secure, isolated network for testing new features. They set `create: true` and use a dedicated address space and subnet:

```yaml
create: true
virtualNetworkType: Managed
name: contoso-dev-dev-vnet
addressPrefixes:
  - 10.1.0.0/16
subnets:
  - name: dev-subnet
    properties:
      addressPrefix: 10.1.1.0/24
tags:
  environment: dev
  team: DevTeamA
  project: FeatureX
  costCenter: RnD
  owner: Alice
  resources: Network
```

### Example 2: Hybrid Production Scenario

For production, the organization uses `virtualNetworkType: Unmanaged` to connect with on-premises resources and applies stricter subnetting and tagging.

---

## Best Practices

- **Avoid IP Overlaps:** Always check that your address space does not overlap with existing Azure or on-premises networks.
- **Subnet Sizing:** Plan for future growth; resizing subnets later can be complex.
- **Tag Consistently:** Use automation to enforce tagging policies for governance and cost tracking.
- **Security:** Apply NSGs and consider Azure Firewall for enhanced security.
- **Documentation:** Keep your YAML files under version control and document changes for auditing and troubleshooting.
- **Reference Azure Best Practices:** Regularly review [Azure VNet best practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/) for updates.

