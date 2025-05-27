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
  - [Connectivity Resource Group](#connectivity-resource-group)
- [Examples and Use Cases](#examples-and-use-cases)
- [Best Practices](#best-practices)
- [References](#references)

---

## Configurations

Each top-level section in the YAML file represents a distinct Azure resource group category. Below is a breakdown of each section, its keys, and their purposes.

### Workload Resource Group

**Purpose:**  
Holds primary Dev Box workload resources (Dev Center, Dev Box definitions, pools, and project resources).

**YAML Representation:**
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

**Key Explanations:**
- `create`: Whether to create this resource group (`true`/`false`).
- `name`: Resource group name, following a consistent naming convention.
- `description`: Brief summary of the group's purpose.
- `tags`: Metadata for governance, cost allocation, and management.

---

### Security Resource Group

**Purpose:**  
Isolates security-related resources (Key Vaults, Defender for Cloud, NSGs, private endpoints).

**YAML Representation:**
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

**Key Explanations:**  
Same structure as `workload`, but dedicated to security assets for stricter access and monitoring.

---

### Monitoring Resource Group

**Purpose:**  
Centralizes monitoring and observability resources (Log Analytics, Application Insights, Azure Monitor).

**YAML Representation:**
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

**Key Explanations:**  
Enables unified operational health monitoring and diagnostics.

---

### Connectivity Resource Group

**Purpose:**  
Contains networking and connectivity resources (VNets, NSGs, peerings, DNS zones, Azure Bastion).

**YAML Representation:**
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

**Key Explanations:**  
Segregates network infrastructure for specialized management and security.

---

## Examples and Use Cases

### Example: Deploying Dev Box Resources

Suppose you want to deploy a new Dev Box environment for the "Contoso-DevExp-DevBox" project in a development environment:

- **Workload group** will host Dev Box definitions and pools.
- **Security group** will contain Key Vaults for secrets used by Dev Box VMs.
- **Monitoring group** will centralize logs and metrics for all Dev Box resources.
- **Connectivity group** will manage VNets and NSGs for secure access.

**Sample Usage in a Deployment Pipeline:**
```yaml
# Pseudocode for pipeline step
- task: AzureResourceManagerTemplateDeployment
  inputs:
    resourceGroupName: $(workload.name)
    templateLocation: 'Linked artifact'
    csmFile: 'devboxTemplate.json'
    deploymentMode: 'Incremental'
```
This ensures resources are deployed into the correct, pre-defined groups.

---

## Best Practices

- **Consistent Naming:**  
  Use a standard naming convention for resource groups (e.g., `[project]-[purpose]-[environment]-rg`) to simplify management and automation.

- **Tagging:**  
  Apply consistent tags across all resource groups for effective cost tracking, ownership, and compliance.

- **Separation of Concerns:**  
  Segregate resources by function (workload, security, monitoring, connectivity) to enable independent scaling, access control, and lifecycle management.

- **Adapt for Environments:**  
  Duplicate or adjust sections for different environments (dev, test, prod) by changing the `environment` tag and resource group names.

- **Documentation:**  
  Keep descriptions up to date to reflect the actual purpose of each group, aiding onboarding and audits.

- **Automation:**  
  Integrate this YAML into your Infrastructure as Code (IaC) pipelines to automate resource group creation and tagging.

---

**References:**  
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

