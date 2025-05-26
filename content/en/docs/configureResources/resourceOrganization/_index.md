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

# Dev Box Accelerator: Azure Resource Groups Configuration

## Overview

This documentation describes the azureResources.yaml configuration file, which is a core part of the Microsoft Dev Box Accelerator. The file defines the organization and structure of Azure Resource Groups for a Dev Box environment, following Azure Landing Zone principles. It enables teams to segregate resources by functional purpose—such as workload, security, monitoring, and connectivity—ensuring scalable, secure, and manageable cloud infrastructure.

The configuration supports best practices for resource management, access control, cost allocation, and operational monitoring, making it easier to deploy, govern, and maintain Dev Box environments in Azure.

---

## Table of Contents

- Workload Resource Group
- Security Resource Group
- Monitoring Resource Group
- Connectivity Resource Group

---

## Workload Resource Group

| Key         | Type    | Default Value         | Description                                                      |
|-------------|---------|----------------------|------------------------------------------------------------------|
| create      | bool    | true                 | Whether to create the resource group or use an existing one      |
| name        | string  | devexp-workload      | Name of the resource group                                       |
| description | string  | prodExp              | Brief description of the resource group purpose                  |
| tags        | object  | See below            | Key-value pairs for resource governance and organization         |

### Purpose

The **Workload Resource Group** contains the primary Dev Box workload resources, such as Dev Center resources, Dev Box definitions, Dev Box pools, and project-specific resources. It separates application workloads from infrastructure components for independent scaling, access control, and lifecycle management.

### Default Configuration

````yaml
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
````

### Detailed Configuration

- **create**: Set to `true` to create a new resource group; set to `false` to use an existing one.
- **name**: Follows a naming convention for clarity and consistency (e.g., `[project]-[purpose]-[environment]-rg`).
- **description**: Describes the purpose of the resource group.
- **tags**: Metadata for governance, cost allocation, and resource management.

### Use Cases

- Deploying Dev Box resources for a new project.
- Segregating workloads for different environments (dev, test, prod).
- Applying role-based access control (RBAC) at the workload level.

### Best Practices

- Use consistent naming conventions.
- Apply standardized tags for all resources.
- Separate workloads from infrastructure for better management.

### Considerations

- Ensure naming conventions align with organizational policies.
- Review tag values for compliance and cost tracking.
- Confirm that resource group location matches workload requirements.

---

## Security Resource Group

| Key         | Type    | Default Value         | Description                                                      |
|-------------|---------|----------------------|------------------------------------------------------------------|
| create      | bool    | true                 | Whether to create the resource group or use an existing one      |
| name        | string  | devexp-security      | Name of the resource group                                       |
| description | string  | prodExp              | Brief description of the resource group purpose                  |
| tags        | object  | See below            | Key-value pairs for resource governance and organization         |

### Purpose

The **Security Resource Group** contains security-related resources, such as Key Vaults, Microsoft Defender for Cloud configurations, Network Security Groups, and private endpoints. It isolates security resources to enable stricter access controls and separate monitoring/auditing.

### Default Configuration

````yaml
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
````

### Detailed Configuration

- **create**: Determines if the group should be created.
- **name**: Follows security naming conventions.
- **description**: Describes the security focus.
- **tags**: Ensures traceability and compliance.

### Use Cases

- Storing secrets in Azure Key Vault.
- Managing security policies and monitoring.
- Isolating security resources for audit and compliance.

### Best Practices

- Restrict access to security resource groups.
- Enable logging and monitoring for all security resources.
- Regularly review access policies.

### Considerations

- Security resources may require stricter compliance.
- Ensure only authorized users have access.
- Monitor for changes and anomalies.

---

## Monitoring Resource Group

| Key         | Type    | Default Value         | Description                                                      |
|-------------|---------|----------------------|------------------------------------------------------------------|
| create      | bool    | true                 | Whether to create the resource group or use an existing one      |
| name        | string  | devexp-monitoring    | Name of the resource group                                       |
| description | string  | prodExp              | Brief description of the resource group purpose                  |
| tags        | object  | See below            | Key-value pairs for resource governance and organization         |

### Purpose

The **Monitoring Resource Group** centralizes monitoring and observability resources, including Log Analytics workspaces, Application Insights, Azure Monitor alerts, and dashboards. This provides a unified view of operational health and simplifies diagnostics.

### Default Configuration

````yaml
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
````

### Detailed Configuration

- **create**: Indicates if the group should be created.
- **name**: Follows monitoring naming conventions.
- **description**: Describes the monitoring focus.
- **tags**: Supports operational and financial tracking.

### Use Cases

- Centralizing logs and metrics for all workloads.
- Setting up alerts and dashboards for Dev Box environments.
- Enabling unified monitoring across environments.

### Best Practices

- Centralize monitoring resources for all environments.
- Use consistent tagging for traceability.
- Regularly review and update monitoring configurations.

### Considerations

- Ensure monitoring resources have access to all relevant workloads.
- Plan for data retention and storage costs.
- Secure monitoring data appropriately.

---

## Connectivity Resource Group

| Key         | Type    | Default Value         | Description                                                      |
|-------------|---------|----------------------|------------------------------------------------------------------|
| create      | bool    | true                 | Whether to create the resource group or use an existing one      |
| name        | string  | devexp-connectivity  | Name of the resource group                                       |
| description | string  | prodExp              | Brief description of the resource group purpose                  |
| tags        | object  | See below            | Key-value pairs for resource governance and organization         |

### Purpose

The **Connectivity Resource Group** contains networking and connectivity resources, such as Virtual Networks, Subnets, Network Security Groups, Virtual Network Peerings, Private DNS Zones, and Azure Bastion. It enables specialized management by networking teams and facilitates network-wide security policies.

### Default Configuration

````yaml
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
````

### Detailed Configuration

- **create**: Indicates if the group should be created.
- **name**: Follows connectivity naming conventions.
- **description**: Describes the connectivity focus.
- **tags**: Supports governance and cost allocation.

### Use Cases

- Managing virtual networks and subnets for Dev Box environments.
- Isolating network infrastructure for security and compliance.
- Facilitating network peering and secure connectivity.

### Best Practices

- Segregate networking resources from workloads.
- Apply network security policies at the resource group level.
- Document network topology and dependencies.

### Considerations

- Coordinate with networking teams for changes.
- Monitor network resource usage and costs.
- Ensure compliance with organizational network policies.

---

## Best Practices

- **Consistent Naming**: Use clear, descriptive, and consistent naming conventions for all resource groups.
- **Tagging**: Apply standardized tags for governance, cost management, and operational tracking.
- **Separation of Concerns**: Isolate resources by function (workload, security, monitoring, connectivity) for better management and security.
- **Access Control**: Apply RBAC and least privilege principles at the resource group level.
- **Documentation**: Keep configuration files and documentation up to date and accessible.

---

## References

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Tagging Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

---

## Considerations

- Review and update configurations regularly to align with evolving organizational and security requirements.
- Ensure all stakeholders understand the purpose and structure of each resource group.
- Monitor resource usage and costs to optimize cloud spend.
