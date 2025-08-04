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

## Overview

This YAML configuration file [**azureResources.yaml**](https://github.com/Evilazaro/DevExp-DevBox/blob/main/infra/settings/resourceOrganization/azureResources.yaml) defines the organizational structure for Azure resource groups as part of the **Microsoft Dev Box Accelerator**. It follows Azure Landing Zone best practices, enabling modular, decoupled, and scalable management of cloud resources. By segmenting resources into functional groups—**workload**, **security**, **monitoring**, and **connectivity**—the configuration supports clear governance, access control, and lifecycle management for enterprise-scale Dev Box deployments.

**Role in Dev Box Accelerator:**  
This file is a foundational component, ensuring that all resources deployed for Microsoft Dev Box environments are organized, tagged, and governed according to enterprise standards. It enables teams to manage infrastructure and workloads independently, supporting both operational efficiency and compliance.

---

## Table of Contents

- [Overview](#overview)
- [Configurations](#configurations)
  - [Workload Resource Group](#workload-resource-group)
  - [Security Resource Group](#security-resource-group)
  - [Monitoring Resource Group](#monitoring-resource-group)  
- [Examples and Use Cases](#examples-and-use-cases)
- [Best Practices](#best-practices)
- [References](#references)

---


## Configurations

Each top-level section in the YAML file represents a distinct Azure resource group category, following Azure Landing Zone principles for segregation by function. Below is a breakdown of each section, its keys, and their purposes.

### Workload Resource Group

**Purpose:**
Hosts the main application resources for Dev Box environments, including Dev Center resources, Dev Box definitions, pools, and project assets.

**Best Practices:**
- Separate application workloads from infrastructure and security components for independent scaling, access control, and lifecycle management.
- Use clear, consistent naming and tagging for governance and automation.

**YAML Example:**
```yaml
workload:
  create: true
  name: devexp-workload
  description: prodExp
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

**Key Explanations:**
- `create`: Whether to create this resource group (`true`/`false`).
- `name`: Resource group name, following a consistent naming convention.
- `description`: Brief summary of the group's purpose.
- `tags`: Metadata for governance, cost allocation, and management.

---

### Security Resource Group

**Purpose:**
Contains security-related resources such as Azure Key Vaults, Network Security Groups (NSGs), Microsoft Defender for Cloud, and private endpoints.

**Best Practices:**
- Isolate security resources to apply stricter access controls and enable separate monitoring/auditing of security components.
- Use dedicated resource groups for security to support compliance and operational excellence.

**YAML Example:**
```yaml
security:
  create: true
  name: devexp-security
  description: prodExp
  tags:
    environment: dev           # Deployment environment
    division: Platforms        # Business division
    team: DevExP              # Team
    project: Contoso-DevExp-DevBox  # Project name
    costCenter: IT            # Cost center
    owner: Contoso            # Owner
    landingZone: Workload     # Landing zone
    resources: ResourceGroup  # Resource type
```

**Key Explanations:**
- Same structure as `workload`, but dedicated to security assets for stricter access and monitoring.

---

### Monitoring Resource Group

**Purpose:**
Contains monitoring and observability resources such as Log Analytics workspaces, Application Insights, Azure Monitor alerts, action groups, and dashboards.

**Best Practices:**
- Centralize monitoring resources to provide a unified view of operational health and simplify diagnostics.
- Use consistent tagging for cost management and reporting.

**YAML Example:**
```yaml
monitoring:
  create: true
  name: devexp-monitoring
  description: prodExp
  tags:
    environment: dev           # Deployment environment
    division: Platforms        # Business division
    team: DevExP              # Team
    project: Contoso-DevExp-DevBox  # Project name
    costCenter: IT            # Cost center
    owner: Contoso            # Owner
    landingZone: Workload     # Landing zone
    resources: ResourceGroup  # Resource type
```

**Key Explanations:**
- Enables unified operational health monitoring and diagnostics.


## Best Practices

- **Consistent Naming:** Use a standard naming convention for resource groups (e.g., `[project]-[purpose]-[environment]-rg`) to simplify management and automation.
- **Tagging:** Apply consistent tags across all resource groups for effective cost tracking, ownership, and compliance.
- **Separation of Concerns:** Segregate resources by function (workload, security, monitoring) to enable independent scaling, access control, and lifecycle management.
- **Workload Group:** Separate application workloads from infrastructure and security components for flexibility and easier management.
- **Security Group:** Isolate security resources for stricter access controls and enable separate monitoring/auditing.
- **Monitoring Group:** Centralize monitoring resources to provide a unified view of operational health and simplify diagnostics.
- **Adapt for Environments:** Duplicate or adjust sections for different environments (dev, test, prod) by changing the `environment` tag and resource group names.
- **Documentation:** Keep descriptions up to date to reflect the actual purpose of each group, aiding onboarding and audits.
- **Automation:** Integrate this YAML into your Infrastructure as Code (IaC) pipelines to automate resource group creation and tagging.

---


## References

- [Microsoft Dev Box Accelerator Resource Organization Docs](https://evilazaro.github.io/DevExp-DevBox/docs/configureresources/resourceorganization/)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

