---
title: Organization roles and responsabilities requirements
description: >
  **Dev Box Landing Zone Accelerator –** Organization roles and responsabilities for: Platform engineers, development team leads, and developers. 
categories: 
  - getting-started
  - prerequisites
tags:
  - roles
  - responsabilities
  - requirements
  - platform engineering
  - development team
  - developers
  - rbac
weight: 5
---

{{% pageinfo %}}  
**Learn more** about Microsoft Dev Box Organizational roles and responsibilities for the deployment, access the [official documentation site](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide#organizational-roles-and-responsibilities).
{{% /pageinfo %}} 

## Overview

The **Dev Box landing zone accelerator** aligns with the **requirements and responsibilities** for each organizational role involved in deploying and using Microsoft Dev Box, with a focus on **RBAC permissions** and **configuration prerequisites**.

The roles covered include:

- Platform Engineers
- Development Team Leads
- Developers

Each role has distinct requirements to ensure a secure, scalable, and successful Dev Box deployment.

---

## Platform Engineer Requirements

Platform Engineers are responsible for deploying and governing the core infrastructure that powers Microsoft Dev Box, including Dev Centers, network connections, and governance policies.

### Responsibilities

- Create and configure Dev Centers and Projects
- Set up network connections (Microsoft-hosted or custom VNETs)
- Define Dev Box definitions (SKUs, base images)
- Apply RBAC roles and enforce policies
- Enable monitoring and diagnostics

### Required Azure Roles

| Role Name                | Purpose                                                                                             | Documentation                                                                                      |
|--------------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Owner / Contributor      | Grants full control of resource deployment and access management                                    | [Owner Role](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) |
| DevCenter Administrator  | Allows managing Dev Centers, Projects, Dev Box Definitions, and network connections                 | [Dev Box RBAC Roles](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |
| Network Contributor      | Required to manage virtual networks and DNS for custom connectivity                                | [Network Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#network-contributor) |

### Additional Requirements

| Component                  | Description                                                                                          | Documentation                                                                                      |
|---------------------------|------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Azure Subscription         | Must have access to a valid Azure subscription                                                       | [Manage subscriptions](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription) |
| Microsoft Entra ID         | Configured for managing access and identity                                                          | [What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)         |
| Custom Network (Optional)  | Required if using private VNETs, DNS, or domain join                                                 | [Network connection overview](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview) |
| Azure Monitor              | Recommended for collecting diagnostics and telemetry                                                 | [Monitor Dev Box usage](https://learn.microsoft.com/en-us/azure/dev-box/monitor-dev-box-usage)    |

---

## Development Team Lead Requirements

Development Team Leads manage the Dev Box experience for their teams by defining image configurations, Dev Box pools, and assigning users to environments.

### Responsibilities

- Define Dev Box pools per team or project
- Customize and manage Dev Box definitions
- Assign users to Dev Box environments via Microsoft Entra ID groups
- Validate Dev Box readiness and configurations

### Required Azure Roles

| Role Name                | Purpose                                                                                             | Documentation                                                                                      |
|--------------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| DevCenter Project Admin  | Allows creation and management of projects, Dev Box pools, and user assignments                    | [Dev Box RBAC Roles](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |
| Contributor (Optional)   | Required for managing custom images or shared galleries                                             | [Contributor Role](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) |

### Additional Requirements

| Component                       | Description                                                                                      | Documentation                                                                                      |
|----------------------------------|--------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Dev Box Definitions              | Templates that specify the image and SKU (compute size)                                          | [Dev Box Definitions](https://learn.microsoft.com/en-us/azure/dev-box/dev-box-definitions)         |
| Dev Box Pools                    | Logical grouping of Dev Boxes for users                                                          | [Dev Box Pools](https://learn.microsoft.com/en-us/azure/dev-box/dev-box-pools)                     |
| Azure Compute Gallery (Optional) | Required if using custom images across environments                                              | [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) |
| Azure Image Builder (Optional)   | Used to automate creation of custom Dev Box images                                               | [Image Builder](https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview)   |

---

## Developer Requirements

Developers are end users of Microsoft Dev Box and require access to preconfigured environments that match their team's development stack.

### Responsibilities

- Access and manage assigned Dev Boxes via the portal
- Use the Dev Box to develop, build, and test code
- Customize environment (if permitted) within constraints

### Required Azure Roles

| Role Name         | Purpose                                                                                     | Documentation                                                                                      |
|-------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Dev Box User      | Grants the ability to view, start, and use Dev Boxes assigned through Dev Box pools        | [Dev Box RBAC Roles](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |

### Additional Requirements

| Component              | Description                                                                 | Documentation                                                                                      |
|------------------------|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Microsoft Entra ID     | Developers must be part of an Entra ID group assigned to a Dev Box pool     | [Access Dev Box portal](https://learn.microsoft.com/en-us/azure/dev-box/end-user-dev-box-portal)   |
| Dev Box Portal Access  | Access the Dev Box portal to start, stop, and connect to the Dev Box        | [Using Dev Box Portal](https://learn.microsoft.com/en-us/azure/dev-box/end-user-dev-box-portal)    |
| Remote Desktop (Optional) | Used if connecting via RDP instead of the browser-based interface       | [Connect to Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/end-user-connect-dev-box)     |

---

## Summary

Before deploying or using the Dev Box Landing Zone Accelerator, ensure each role has the following:

- **Platform Engineers**: Subscription access, network configuration, Dev Center ownership, and monitoring setup  
- **Team Leads**: RBAC permissions, Dev Box definitions and pools, image strategy, and group assignments  
- **Developers**: Assigned Entra ID group, portal access, and an understanding of the configured environment  

For RBAC setup instructions, see:  
[Assign roles using Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)