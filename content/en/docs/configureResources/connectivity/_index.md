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

The **newtork.yaml** file defines the virtual network infrastructure for environments managed by the **Microsoft Dev Box Accelerator**. This YAML configuration is a key part of the accelerator’s infrastructure-as-code approach, enabling automated, consistent, and secure provisioning of Azure Virtual Networks (VNets) and related resources. It ensures Dev Box resources are isolated, securely connected to Azure services, and aligned with organizational governance and cost management requirements.

This file is intended to be used as part of a broader set of infrastructure settings, providing a declarative way to manage network topology, address spaces, subnets, and resource tagging for Dev Box environments.

---

## Table of Contents

- [Create](#create)
- [Virtual Network Type](#virtual-network-type)
- [Virtual Network Name](#virtual-network-name)
- [Address Prefixes](#address-prefixes)
- [Subnets](#subnets)
- [Tags](#tags)

---

## Configuration Items

---

### Create

| Key    | Type    | Default | Example |
|--------|---------|---------|---------|
| create | Boolean | `true`  | `true` or `false` |

#### Purpose
Determines whether to create a new virtual network or use an existing one.

#### Default Configuration
```yaml
create: true
```

#### Detailed Configuration
- `true`: A new, dedicated VNet will be created for the environment.
- `false`: An existing VNet will be used.

#### Use Cases
- Set to `true` for isolated, environment-specific VNets (recommended for dev/test).
- Set to `false` when integrating with pre-existing corporate networks.

#### Best Practices
- Use dedicated VNets per environment for isolation and security.
- Automate VNet creation for repeatable deployments.

#### Considerations
- Using existing VNets may require additional permissions and careful address space management.

---

### Virtual Network Type

| Key                | Type   | Default    | Example      |
|--------------------|--------|------------|--------------|
| virtualNetworkType | String | `Managed`  | `Managed` or `Unmanaged` |

#### Purpose
Specifies how network connectivity is provisioned and managed.

#### Default Configuration
```yaml
virtualNetworkType: Managed
```

#### Detailed Configuration
- `Managed`: Azure manages the network configuration (simpler, fewer permissions).
- `Unmanaged`: Customer manages the network (greater control, required for hybrid/on-prem scenarios).

#### Use Cases
- Use `Managed` for dev/test environments.
- Use `Unmanaged` for production or hybrid connectivity.

#### Best Practices
- Prefer `Managed` for simplicity unless advanced scenarios require `Unmanaged`.

#### Considerations
- `Unmanaged` requires more expertise and responsibility for security and routing.

---

### Virtual Network Name

| Key  | Type   | Default         | Example                |
|------|--------|-----------------|------------------------|
| name | String | `contoso-vnet`  | `contoso-dev-devbox-vnet` |

#### Purpose
Defines the name of the VNet resource.

#### Default Configuration
```yaml
name: contoso-vnet
```

#### Detailed Configuration
- Should be lowercase and include company, purpose, environment, and resource type.

#### Use Cases
- Naming conventions help with resource identification and automation.

#### Best Practices
- Use `[company]-[purpose]-[env]-vnet` format for clarity and consistency.

#### Considerations
- Names must be unique within the resource group.

---

### Address Prefixes

| Key             | Type   | Default           | Example           |
|-----------------|--------|-------------------|-------------------|
| addressPrefixes | Array  | `10.0.0.0/16`     | `10.1.0.0/16`     |

#### Purpose
Defines the IP address range(s) for the VNet using CIDR notation.

#### Default Configuration
```yaml
addressPrefixes:
  - 10.0.0.0/16
```

#### Detailed Configuration
- Use private address ranges (e.g., 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16).
- Ensure no overlap with on-premises or other Azure VNets.

#### Use Cases
- Allocate sufficient address space for current and future resources.

#### Best Practices
- Plan for growth and avoid overlapping ranges.
- Document address space allocations.

#### Considerations
- Changing address prefixes after deployment is complex and disruptive.

---

### Subnets

| Key     | Type   | Default Example         | Example Name      |
|---------|--------|------------------------|-------------------|
| subnets | Array  | `contoso-subnet`       | `devbox-subnet`   |

#### Purpose
Defines subnets within the VNet for organizing and securing resources.

#### Default Configuration
```yaml
subnets:
  - name: contoso-subnet
    properties:
      addressPrefix: 10.0.1.0/24
```

#### Detailed Configuration
- Each subnet has a name and an address prefix.
- Subnets segment the VNet for different workloads or security zones.

#### Use Cases
- Separate subnets for Dev Box, databases, and application services.

#### Best Practices
- Apply Network Security Groups (NSGs) at the subnet level.
- Size subnets appropriately for expected resource count.

#### Considerations
- Azure reserves 5 IPs per subnet.
- Subnet size cannot be changed after creation.

---

### Tags

| Key         | Type   | Example Value      | Purpose                                   |
|-------------|--------|-------------------|-------------------------------------------|
| environment | String | `dev`             | Identifies deployment environment         |
| division    | String | `Platforms`       | Organizational division                   |
| team        | String | `DevExP`          | Responsible team                          |
| project     | String | `DevExP-DevBox`   | Associated project                        |
| costCenter  | String | `IT`              | Cost allocation                           |
| owner       | String | `Contoso`         | Resource owner                            |
| resources   | String | `Network`         | Resource type or purpose                  |

#### Purpose
Attaches metadata to resources for organization, governance, and cost management.

#### Default Configuration
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

#### Detailed Configuration
- Tags are key-value pairs applied to all resources created from this configuration.

#### Use Cases
- Filtering resources, applying policies, and cost tracking.

#### Best Practices
- Apply consistent tags across all resources.
- Automate tagging using policies or deployment scripts.

#### Considerations
- Tag values should follow organizational standards.
- Some Azure services have tag limits.

---

## Best Practices

- **Consistency**: Use standardized naming and tagging conventions.
- **Isolation**: Create dedicated VNets per environment for security.
- **Documentation**: Document address spaces and subnet allocations.
- **Automation**: Automate network provisioning and tagging.
- **Security**: Apply NSGs and monitor network traffic.
- **Scalability**: Plan address spaces and subnet sizes for future growth.
- **Governance**: Use tags for cost management and resource ownership.

---

## References

- [Azure Virtual Network documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure Dev Box networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure VNet best practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
- [Azure resource naming and tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)