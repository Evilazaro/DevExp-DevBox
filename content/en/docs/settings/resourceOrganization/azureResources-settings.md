---
title: Resources Organization Documentation
tags: 
 - devbox
 - resources
 - subnet
description: Resources Organization Documentation
---

# Microsoft Dev Box Accelerator: Resources Organization Documentation

## Overview

This documentation details the resource organization structure for the Microsoft Dev Box Accelerator. The configuration defines a comprehensive resource group strategy aligned with Azure Landing Zone principles, segregating resources based on their functional purpose to improve manageability, security, and governance.

## Table of Contents

- [Configuration Purpose](#configuration-purpose)
- [Resource Group Structure](#resource-group-structure)
  - [Workload Resource Group](#workload-resource-group)
  - [Security Resource Group](#security-resource-group)
  - [Monitoring Resource Group](#monitoring-resource-group)
  - [Connectivity Resource Group](#connectivity-resource-group)
- [Common Configuration Properties](#common-configuration-properties)
- [Tagging Strategy](#tagging-strategy)
- [Best Practices](#best-practices)
- [References](#references)

## Configuration Purpose

The resource organization configuration (`azureResources.yaml`) establishes the foundational resource group structure for Microsoft Dev Box Accelerator environments. It implements the following design principles:

- **Separation of concerns**: Resources are grouped by their functional purpose
- **Least privilege access**: Resource groups can have different RBAC assignments
- **Cost management**: Resource organization enables granular cost tracking
- **Operational efficiency**: Maintenance and troubleshooting are simplified through logical grouping

This approach aligns with the Azure Landing Zone methodology, which recommends organizing resources into management groups and resource groups based on their purpose, lifecycle, and access requirements.

## Resource Group Structure

### Workload Resource Group

```yaml
workload:
  create: true
  name: devexp-workload
  description: prodExp
  tags:
    # Tags detailed in the tagging section
```

**Purpose**: Contains the primary Dev Box workload resources including:
- Dev Center resources
- Dev Box definitions
- Dev Box pools
- Project resources

**Key Considerations**:
- This resource group will host the core Microsoft Dev Box Accelerator resources
- It should be managed by the team responsible for Dev Box operations
- Resource lifecycle is tied to the Dev Box service lifecycle
- Suitable for workload-specific RBAC assignments

**Best Practice**: Separating application workloads from infrastructure components enables independent scaling, access control, and lifecycle management.

### Security Resource Group

```yaml
security:
  create: true
  name: devexp-security
  description: prodExp
  tags:
    # Tags detailed in the tagging section
```

**Purpose**: Contains security-related resources including:
- Key Vaults for secret management
- Microsoft Defender for Cloud configurations
- Network Security Groups
- Private endpoints

**Key Considerations**:
- Typically has stricter access controls than other resource groups
- May be managed by security operations team
- Often subject to additional compliance monitoring
- Consolidates security resources for streamlined audit and management

**Best Practice**: Isolating security resources allows for stricter access controls and separate monitoring/auditing of security components.

### Monitoring Resource Group

```yaml
monitoring:
  create: true
  name: devexp-monitoring
  description: prodExp
  tags:
    # Tags detailed in the tagging section
```

**Purpose**: Contains monitoring and observability resources including:
- Log Analytics workspaces
- Application Insights components
- Azure Monitor alerts and action groups
- Dashboard and reporting resources

**Key Considerations**:
- Provides centralized visibility across all Dev Box environments
- Often has organization-wide access for operational teams
- May integrate with existing enterprise monitoring solutions
- Typically has longer retention periods for diagnostic data

**Best Practice**: Centralizing monitoring resources provides a unified view of operational health and simplifies diagnostic activities across the environment.

### Connectivity Resource Group

```yaml
connectivity:
  create: true
  name: devexp-connectivity
  description: prodExp
  tags:
    # Tags detailed in the tagging section
```

**Purpose**: Contains networking and connectivity resources including:
- Virtual Networks and Subnets
- Network Security Groups
- Virtual Network Peerings
- Private DNS Zones
- Azure Bastion (if applicable)

**Key Considerations**:
- Often managed by networking or infrastructure teams
- Changes typically require change management processes
- May connect to enterprise network environments
- Critical for secure and reliable Dev Box connectivity

**Best Practice**: Segregating network infrastructure enables specialized management by networking teams and facilitates network-wide security policies.

## Common Configuration Properties

Each resource group configuration includes the following common properties:

| Property | Description | Example |
|----------|-------------|---------|
| `create` | Boolean flag to determine whether to create the resource group or use an existing one | `true` |
| `name` | Name of the resource group | `devexp-workload` |
| `description` | Brief description of the resource group's purpose | `prodExp` |
| `tags` | Resource tags for governance and organization | See tagging section |

## Tagging Strategy

The configuration implements a comprehensive tagging strategy aligned with Azure best practices:

```yaml
tags:
  environment: dev           # Deployment environment (dev, test, prod)
  division: Platforms        # Business division responsible for the resource
  team: DevExP              # Team owning the resource
  project: Contoso-DevExp-DevBox  # Project name
  costCenter: IT            # Financial allocation center
  owner: Contoso            # Resource owner
  landingZone: Workload     # Landing zone classification
  resources: ResourceGroup  # Resource type
```

**Tagging Benefits**:
- **Cost management**: Allocate costs to appropriate teams/departments
- **Operational ownership**: Clearly identify resource owners
- **Environment tracking**: Distinguish between dev, test, and production resources
- **Resource governance**: Apply Azure Policy based on tags
- **Automation**: Enable tag-based automation workflows

## Best Practices

### Resource Group Organization

- **Consistent naming**: Follow a consistent naming convention across all environments
- **Regional deployment**: Co-locate resource groups with their resources when possible
- **Lifecycle alignment**: Group resources with similar lifecycles together
- **Access control**: Define RBAC at resource group level for appropriate segregation of duties

### Naming Conventions

Follow the recommended pattern: `[project]-[purpose]-[environment]-rg`

Examples:
- `devexp-workload-dev-rg`
- `devexp-security-prod-rg`

### Tagging Implementation

- **Tag consistently**: Apply the same tags across all resource groups
- **Enforce tags**: Use Azure Policy to enforce mandatory tags
- **Automate tagging**: Implement automated tagging in deployment pipelines
- **Review regularly**: Audit and update tags as organizational structures change

### Deployment Considerations

- **Use Infrastructure as Code**: Deploy resource structure using Bicep, ARM templates, or Terraform
- **CI/CD integration**: Include resource group creation in CI/CD pipelines
- **Environment isolation**: Create separate resource groups for each environment (dev/test/prod)
- **Documentation**: Maintain documentation on resource group purpose and ownership

## References

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Cloud Adoption Framework - Naming and Tagging Strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft Dev Box Accelerator GitHub](https://github.com/Evilazaro/DevExp-DevBox/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)

---

*This documentation is part of the Microsoft Dev Box Accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*