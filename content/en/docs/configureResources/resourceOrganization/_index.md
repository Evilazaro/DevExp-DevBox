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

# Azure Dev Box Accelerator: Resource Groups Configuration (azureResources.yaml)

## Overview

The **azureResources.yaml** file is a core configuration asset for the **Microsoft Dev Box Accelerator**. It defines the organizational structure of Azure Resource Groups for Dev Box environments, aligning with [Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) principles. This file enables teams to segregate resources by functional purpose—such as workload, security, monitoring, and connectivity—ensuring scalable, secure, and manageable Azure environments. By centralizing resource group definitions, it supports consistent governance, cost allocation, and lifecycle management across projects.

---

## Table of Contents

- Workload Resource Group
- Security Resource Group
- Monitoring Resource Group
- Connectivity Resource Group

---

## Workload Resource Group

| Key         | Type    | Default Value        | Description                                      |
|-------------|---------|---------------------|--------------------------------------------------|
| create      | bool    | `true`              | Whether to create the resource group             |
| name        | string  | `devexp-workload`   | Resource group name                              |
| description | string  | `prodExp`           | Description of the resource group                |
| tags        | object  | See below           | Key-value pairs for resource tagging             |

### Purpose

Defines the primary resource group for Dev Box workloads, including Dev Center resources, Dev Box definitions, pools, and project-specific resources.

### Default Configuration

```yaml
workload:
  create: true
  name: devexp-workload
  description: prodExp
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

### Detailed Configuration

- **create**: Controls whether the resource group is provisioned by automation.
- **name**: Follows a naming convention for clarity and consistency.
- **description**: Briefly describes the resource group's purpose.
- **tags**: Metadata for governance, cost management, and resource classification.

### Use Cases

- Hosting Dev Box pools and definitions for a development project.
- Segregating application workloads from infrastructure for independent management.

### Best Practices

- Use a consistent naming convention: `[project]-[purpose]-[environment]-rg`.
- Apply standardized tags for all resources to enable effective cost tracking and governance.
- Separate workloads from infrastructure for better scalability and access control.

### Considerations

- Ensure the naming convention aligns with organizational policies.
- Tags should be updated to reflect changes in ownership or project scope.

---

## Security Resource Group

| Key         | Type    | Default Value        | Description                                      |
|-------------|---------|---------------------|--------------------------------------------------|
| create      | bool    | `true`              | Whether to create the resource group             |
| name        | string  | `devexp-security`   | Resource group name                              |
| description | string  | `prodExp`           | Description of the resource group                |
| tags        | object  | See below           | Key-value pairs for resource tagging             |

### Purpose

Contains security-related resources such as Key Vaults, Microsoft Defender for Cloud, Network Security Groups, and private endpoints.

### Default Configuration

```yaml
security:
  create: true
  name: devexp-security
  description: prodExp
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

### Detailed Configuration

- **create**: Indicates if the security resource group should be created.
- **name**: Should reflect its security purpose.
- **description**: Short description of the group.
- **tags**: Inherits the same tagging structure for consistency.

### Use Cases

- Isolating Key Vaults and security policies from application workloads.
- Applying stricter access controls and monitoring to sensitive resources.

### Best Practices

- Isolate security resources for enhanced monitoring and auditing.
- Restrict access to security resource groups to only necessary personnel.
- Regularly review and update security configurations.

### Considerations

- Ensure compliance with organizational and regulatory security requirements.
- Monitor for unauthorized changes or access.

---

## Monitoring Resource Group

| Key         | Type    | Default Value        | Description                                      |
|-------------|---------|---------------------|--------------------------------------------------|
| create      | bool    | `true`              | Whether to create the resource group             |
| name        | string  | `devexp-monitoring` | Resource group name                              |
| description | string  | `prodExp`           | Description of the resource group                |
| tags        | object  | See below           | Key-value pairs for resource tagging             |

### Purpose

Centralizes monitoring and observability resources, such as Log Analytics, Application Insights, Azure Monitor alerts, and dashboards.

### Default Configuration

```yaml
monitoring:
  create: true
  name: devexp-monitoring
  description: prodExp
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

### Detailed Configuration

- **create**: Controls creation of the monitoring group.
- **name**: Identifies the group as monitoring-related.
- **description**: Briefly describes the group.
- **tags**: Standardized tags for governance.

### Use Cases

- Aggregating logs and metrics from all Dev Box resources.
- Centralizing alerting and dashboarding for operational health.

### Best Practices

- Centralize monitoring resources for unified visibility.
- Use role-based access control (RBAC) to restrict access to monitoring data.
- Regularly review alert rules and dashboards for relevance.

### Considerations

- Ensure monitoring covers all critical resources.
- Plan for log retention and data export policies.

---

## Connectivity Resource Group

| Key         | Type    | Default Value           | Description                                      |
|-------------|---------|------------------------|--------------------------------------------------|
| create      | bool    | `true`                 | Whether to create the resource group             |
| name        | string  | `devexp-connectivity`  | Resource group name                              |
| description | string  | `prodExp`              | Description of the resource group                |
| tags        | object  | See below              | Key-value pairs for resource tagging             |

### Purpose

Hosts networking and connectivity resources, including Virtual Networks, Subnets, Network Security Groups, Peerings, Private DNS Zones, and Azure Bastion.

### Default Configuration

```yaml
connectivity:
  create: true
  name: devexp-connectivity
  description: prodExp
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

### Detailed Configuration

- **create**: Indicates if the connectivity group should be created.
- **name**: Should reflect its networking focus.
- **description**: Short description.
- **tags**: Consistent tagging for all resources.

### Use Cases

- Managing all networking components for Dev Box environments.
- Enabling specialized management by networking teams.

### Best Practices

- Segregate networking resources for better security and management.
- Apply network-wide security policies and monitoring.
- Use private endpoints and secure connectivity patterns.

### Considerations

- Coordinate with networking teams for changes.
- Monitor for configuration drift or unauthorized changes.

---

## General Best Practices for azureResources.yaml

- **Consistent Naming**: Use clear, descriptive, and consistent naming conventions for all resource groups.
- **Tagging**: Apply a standardized set of tags for governance, cost management, and automation.
- **Separation of Concerns**: Segregate resources by function (workload, security, monitoring, connectivity) to enable specialized management and security.
- **Documentation**: Keep this file updated and document any changes for auditability.
- **Review**: Regularly review resource group configurations to ensure alignment with organizational policies and Azure best practices.

---

## References

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Tagging Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

---

## Example

```yaml
workload:
  create: true
  name: devexp-workload
  description: Dev Box primary workload resources
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

## Considerations

- Ensure all resource group definitions are reviewed and approved by relevant stakeholders.
- Update tags and descriptions as project scopes or ownership change.
- Align resource group structure with Azure subscription and management group hierarchy for optimal governance.
