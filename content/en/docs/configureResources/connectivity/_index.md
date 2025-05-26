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

The newtork.yaml file defines the virtual network infrastructure for Microsoft Dev Box environments. As part of the Dev Box Accelerator, this configuration enables secure, isolated, and scalable networking for developer resources in Azure. It specifies how virtual networks (VNets), subnets, and resource tags are provisioned and managed, ensuring alignment with Azure best practices for security, governance, and operational efficiency.

This file is essential for automating and standardizing network setup, supporting both managed and unmanaged network scenarios, and providing metadata for resource management and cost allocation.

---

## Table of Contents

- Create Flag (`create`)
- Virtual Network Type (`virtualNetworkType`)
- Virtual Network Name (`name`)
- Address Prefixes (`addressPrefixes`)
- Subnets (`subnets`)
- Tags (`tags`)

---

## Create Flag (`create`)

| Key    | Type    | Default | Description                                      |
|--------|---------|---------|--------------------------------------------------|
| create | boolean | true    | Whether to create a new VNet or use an existing one |

### Purpose

Determines if a new virtual network should be created or if an existing network will be used for the Dev Box environment.

### Default Configuration

```yaml
create: true
```

### Detailed Configuration

- `true`: A new, dedicated VNet is created for the environment.
- `false`: An existing VNet is used, which may be shared with other resources.

### Use Cases

- **true**: For isolated dev/test environments where network separation is required.
- **false**: When integrating with existing corporate networks or hybrid scenarios.

### Best Practices

- Use `true` for each environment to maintain isolation and reduce risk of cross-environment impact.
- Use `false` only when you have strict requirements to integrate with existing VNets.

### Considerations

- Creating new VNets increases isolation but may add management overhead.
- Using existing VNets requires careful IP planning to avoid conflicts.

---

## Virtual Network Type (`virtualNetworkType`)

| Key                | Type   | Default   | Description                                 |
|--------------------|--------|-----------|---------------------------------------------|
| virtualNetworkType | string | Managed   | How the VNet is provisioned and managed     |

### Purpose

Specifies whether Azure manages the VNet configuration or if the customer does.

### Default Configuration

```yaml
virtualNetworkType: Managed
```

### Detailed Configuration

- `Managed`: Azure automates network setup, ideal for dev/test.
- `Unmanaged`: Customer is responsible for network configuration, required for advanced or hybrid scenarios.

### Use Cases

- **Managed**: Quick setup, fewer permissions, less complexity.
- **Unmanaged**: Needed for production, custom routing, or on-premises connectivity.

### Best Practices

- Use `Managed` for most dev/test workloads.
- Use `Unmanaged` for production or when integrating with on-premises networks.

### Considerations

- `Managed` networks may not support all advanced features.
- `Unmanaged` requires more Azure networking expertise.

---

## Virtual Network Name (`name`)

| Key  | Type   | Default         | Description                      |
|------|--------|-----------------|----------------------------------|
| name | string | contoso-vnet    | Name of the virtual network      |

### Purpose

Defines the unique name for the VNet resource.

### Default Configuration

```yaml
name: contoso-vnet
```

### Detailed Configuration

- Should follow naming conventions: lowercase, include company, purpose, environment, and resource type.

### Use Cases

- `contoso-dev-devbox-vnet` for a development environment.
- `contoso-prod-app-vnet` for a production application.

### Best Practices

- Use clear, descriptive names for easier management and automation.
- Example: `[company]-[purpose]-[env]-vnet`

### Considerations

- Name must be unique within the resource group.
- Changing the name after deployment may require resource recreation.

---

## Address Prefixes (`addressPrefixes`)

| Key             | Type   | Default         | Description                        |
|-----------------|--------|-----------------|------------------------------------|
| addressPrefixes | array  | 10.0.0.0/16     | CIDR blocks for the VNet address space |

### Purpose

Defines the IP address range(s) for the VNet.

### Default Configuration

```yaml
addressPrefixes:
  - 10.0.0.0/16
```

### Detailed Configuration

- Use private IP ranges (RFC 1918).
- Ensure no overlap with on-premises or other Azure VNets.

### Use Cases

- `10.0.0.0/16` for large environments.
- `192.168.100.0/24` for smaller, isolated environments.

### Best Practices

- Allocate sufficient space for future growth.
- Avoid overlapping with existing networks.

### Considerations

- Changing address space after deployment can be complex.
- Plan for peering and hybrid connectivity.

---

## Subnets (`subnets`)

| Key     | Type   | Default Example                | Description                       |
|---------|--------|-------------------------------|-----------------------------------|
| subnets | array  | See below                     | Defines subnets within the VNet   |

### Purpose

Organizes resources into logical segments for security and management.

### Default Configuration

```yaml
subnets:
  - name: contoso-subnet
    properties:
      addressPrefix: 10.0.1.0/24
```

### Detailed Configuration

- Each subnet has a name and an address prefix within the VNet's address space.
- Subnets can be sized according to workload requirements.

### Use Cases

- Separate subnets for application, database, and management workloads.
- Apply Network Security Groups (NSGs) at the subnet level.

### Best Practices

- Create subnets based on workload type and security needs.
- Size subnets to allow for growth.
- Apply NSGs for traffic filtering.

### Considerations

- Azure reserves 5 IPs per subnet.
- Subnet address ranges must not overlap.

---

## Tags (`tags`)

| Key         | Type   | Example Value      | Description                                    |
|-------------|--------|-------------------|------------------------------------------------|
| environment | string | dev               | Deployment environment (dev, test, prod, etc.) |
| division    | string | Platforms         | Organizational division                        |
| team        | string | DevExP            | Responsible team                               |
| project     | string | DevExP-DevBox     | Project name                                   |
| costCenter  | string | IT                | Cost center for billing                        |
| owner       | string | Contoso           | Resource owner                                 |
| resources   | string | Network           | Resource type or purpose                       |

### Purpose

Attaches metadata to resources for organization, governance, and cost management.

### Default Configuration

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

### Detailed Configuration

- Tags are key-value pairs.
- Used for filtering, automation, and cost allocation.

### Use Cases

- Automate resource cleanup by environment.
- Track costs by project or division.

### Best Practices

- Apply consistent tags across all resources.
- Automate tagging via deployment pipelines.

### Considerations

- Tags are case-sensitive.
- Some Azure policies may require specific tags.

---

## References

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure Dev Box Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)
- [Azure Resource Naming and Tagging](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)

