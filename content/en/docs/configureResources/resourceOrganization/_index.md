---
title: 'Resource Groups'
tags:
  - azure
  - microsoft-dev-box
  - resource-groups
  - governance
  - cloud-adoption-framework
  - resource-tagging


description: >
  How to either create new or connect to existent Azure Resource Groups to organize your Dev Box Landing Zone
weight: 6
---

# Overview

This document provides comprehensive guidance on the azureResources.yaml configuration file, a core component of the Microsoft Dev Box Accelerator. It explains the file's structure, purpose, and best practices, enabling teams to implement modular, scalable, and secure Azure environments aligned with Azure Landing Zone principles.

The azureResources.yaml file defines the organization and configuration of Azure Resource Groups for Microsoft Dev Box deployments. It enables teams to:

- **Modularize** resource management by separating workloads, security, monitoring, and connectivity.
- **Align with Azure Landing Zone best practices** for governance, security, and scalability.
- **Automate** resource group creation and tagging for consistent, repeatable deployments.

This file is intended to be used as part of the Microsoft Dev Box Accelerator, which streamlines the setup and management of Dev Box environments for development teams.

---

## Configuration Sections

The YAML file is organized into four main sections, each representing a logical grouping of Azure resources:

### Workload Resource Group (`workload`)

**Purpose:**  
Holds the primary Dev Box resources such as Dev Centers, Dev Box definitions, pools, and project-specific assets.

**Keys:**
- `create`: *(bool)* Whether to create this resource group (`true` or `false`).
- `name`: *(string)* Resource group name (e.g., `devexp-workload`).
- `description`: *(string)* Brief description of the group’s purpose.
- `tags`: *(object)* Key-value pairs for governance, cost allocation, and organization.

**Best Practices:**
- Use a consistent naming convention: `[project]-[purpose]-[environment]-rg`.
- Separate application workloads from infrastructure for independent scaling and management.

---

### Security Resource Group (`security`)

**Purpose:**  
Isolates security-related resources, such as Key Vaults, Defender for Cloud, NSGs, and private endpoints.

**Keys:**
- Same as `workload` (see above).

**Best Practices:**
- Isolate security resources for stricter access controls and dedicated monitoring.
- Apply consistent tagging for traceability and compliance.

---

### Monitoring Resource Group (`monitoring`)

**Purpose:**  
Centralizes monitoring and observability resources, including Log Analytics, Application Insights, alerts, and dashboards.

**Keys:**
- Same as `workload` (see above).

**Best Practices:**
- Centralize monitoring to provide a unified operational view and simplify diagnostics.

---

### Connectivity Resource Group (`connectivity`)

**Purpose:**  
Contains networking infrastructure such as VNets, subnets, NSGs, peerings, DNS zones, and Azure Bastion.

**Keys:**
- Same as `workload` (see above).

**Best Practices:**
- Segregate networking for specialized management and enhanced security.

---

### Example Tag Structure

```yaml
tags:
  environment: dev
  division: Platforms
  team: DevExP
  project: Contoso-DevExp-DevBox
  costCenter: IT
  owner: Contoso
  landingZone: Workload
  resources: ResourceGroup
```

---

## Examples and Use Cases

### Example 1: Creating All Resource Groups for a New Dev Box Project

A new project, `Contoso-DevExp-DevBox`, requires isolated environments for development. The YAML configuration ensures that all necessary resource groups are created with consistent naming and tagging, enabling clear separation of duties and cost tracking.

### Example 2: Customizing for Production

To deploy to production, update the `environment` tag and resource group names:

```yaml
workload:
  create: true
  name: contoso-workload-prod
  tags:
    environment: prod
    # ...other tags...
```

### Example 3: Selective Resource Group Creation

If only monitoring needs to be added to an existing environment:

```yaml
monitoring:
  create: true
  name: contoso-monitoring
  # ...other keys...
```
Set `create: false` for other sections to skip their creation.

---

## Tips and Best Practices

- **Consistent Tagging:** Apply the same tags across all resource groups for effective governance, cost management, and automation.
- **Naming Conventions:** Adopt a clear naming convention for resource groups to simplify identification and management.
- **Separation of Concerns:** Use dedicated resource groups for workload, security, monitoring, and connectivity to align with Azure Landing Zone recommendations.
- **Lifecycle Management:** Isolated resource groups enable independent scaling, access control, and lifecycle operations (e.g., deletion, updates).
- **Documentation:** Keep the YAML file well-commented to aid future maintainers and auditors.
- **Version Control:** Store the YAML file in source control to track changes and enable collaboration.

---

## References

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
