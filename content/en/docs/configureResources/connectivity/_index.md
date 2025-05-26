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

This YAML file (newtork.yaml) defines the virtual network infrastructure for environments provisioned by the **Microsoft Dev Box Accelerator**. It provides a modular, decoupled configuration for setting up and managing Azure Virtual Networks (VNets) and related connectivity for Dev Box resources. The configuration ensures secure, isolated, and scalable networking, aligning with Azure best practices for cloud environments.

The file is designed to be reusable and easily customizable, supporting both managed and unmanaged network scenarios. It enables organizations to automate network provisioning, enforce governance, and maintain consistency across environments.

---

## Configuration Sections

### 1. `create`
- **Purpose:** Determines whether to create a new VNet or use an existing one.
- **Type:** Boolean (`true`/`false`)
- **Best Practice:** Set to `true` for dedicated, isolated environments (recommended for Dev/Test).
- **Example:**  
  ```yaml
  create: true
  ```

### 2. `virtualNetworkType`
- **Purpose:** Specifies whether Azure manages the VNet configuration.
- **Options:**
  - `Managed`: Azure handles setup (simpler, fewer permissions).
  - `Unmanaged`: Customer manages setup (more control, required for hybrid/on-prem scenarios).
- **Best Practice:** Use `Managed` for dev/test; `Unmanaged` for production or hybrid.
- **Example:**  
  ```yaml
  virtualNetworkType: Managed
  ```

### 3. `name`
- **Purpose:** The name of the VNet resource.
- **Naming Convention:** Lowercase, includes company, purpose, environment, and `-vnet` suffix.
- **Example:**  
  ```yaml
  name: contoso-vnet
  ```

### 4. `addressPrefixes`
- **Purpose:** Defines the VNet’s IP address space using CIDR notation.
- **Best Practices:**
  - Use private ranges (e.g., `10.0.0.0/8`).
  - Avoid overlaps with on-premises or other VNets.
  - Allocate enough space for growth.
- **Example:**  
  ```yaml
  addressPrefixes:
    - 10.0.0.0/16
  ```

### 5. `subnets`
- **Purpose:** Defines subnets within the VNet for resource segmentation and security.
- **Best Practices:**
  - Separate subnets by workload/security needs.
  - Apply Network Security Groups (NSGs) at subnet level.
  - Size subnets for current and future needs.
- **Example:**  
  ```yaml
  subnets:
    - name: contoso-subnet
      properties:
        addressPrefix: 10.0.1.0/24
  ```

### 6. `tags`
- **Purpose:** Metadata for resource organization, governance, and cost management.
- **Recommended Tags:**
  - `environment`: Deployment environment (e.g., dev, test, prod).
  - `division`: Organizational division (e.g., Platforms).
  - `team`: Responsible team (e.g., DevExP).
  - `project`: Associated project (e.g., DevExP-DevBox).
  - `costCenter`: Cost allocation (e.g., IT).
  - `owner`: Resource owner (e.g., Contoso).
  - `resources`: Resource type/purpose (e.g., Network).
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

---

## Examples and Use Cases

### Example 1: Dev/Test Environment with Managed VNet

```yaml
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
**Use Case:** Quickly provision an isolated, managed network for development teams using Dev Box.

### Example 2: Production/Hybrid Scenario with Unmanaged VNet

```yaml
create: true
virtualNetworkType: Unmanaged
name: contoso-prod-vnet
addressPrefixes:
  - 10.1.0.0/16
subnets:
  - name: prod-subnet
    properties:
      addressPrefix: 10.1.1.0/24
tags:
  environment: prod
  division: IT
  team: PlatformOps
  project: CoreInfra
  costCenter: 12345
  owner: InfraTeam
  resources: Network
```
**Use Case:** Integrate with on-premises networks or apply custom security controls.

---

## Tips and Best Practices

- **Isolation:** Always use dedicated VNets per environment to prevent cross-environment access.
- **Address Planning:** Plan address spaces to avoid overlaps and allow for future scaling.
- **Tag Consistently:** Automate tagging to ensure all resources are discoverable and manageable.
- **Security:** Use NSGs and subnet segmentation to enforce least-privilege access.
- **Documentation:** Keep configuration files under version control and document changes for auditability.
- **Automation:** Integrate with CI/CD pipelines for repeatable, reliable network provisioning.
- **Azure References:**  
  - [Azure VNet Best Practices](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/)
  - [Dev Box Networking](https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-network-connectivity)

