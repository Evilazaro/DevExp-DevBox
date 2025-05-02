---
title: Organization roles and responsabilities requirements
description: >
  Organization roles and responsabilities requirements for: Platform engineers, development team leads, and developers. 
tags: [test, sample, docs]
weight: 5
---

{{% pageinfo %}}  
**Learn more** about Microsoft Dev Box Organizational roles and responsibilities for the deployment, access the [official documentation site](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide#organizational-roles-and-responsibilities).
{{% /pageinfo %}} 

# Overview

To deploy and manage the Microsoft Dev Box effectively, organizations should align responsibilities across three key roles:

- **Platform Engineers**
- **Development Team Leads**
- **Developers**

Depending on the size and maturity of the organization, these roles might overlap or be combined. This document outlines each role's responsibilities, requirements, and configuration steps to help ensure a successful Dev Box deployment.

---

## Platform Engineers

### Responsibilities

Platform engineers are responsible for setting up, securing, and maintaining the foundational infrastructure for Dev Box. They ensure the platform is scalable, secure, and aligned with enterprise governance.

### Key Responsibilities

- Set up **Dev Center**, **projects**, **networks**, and **Dev Box definitions**
- Integrate **identity and RBAC** with Azure AD
- Apply governance and compliance policies
- Manage **networking**, **monitoring**, and **storage**

### Requirements

| Requirement                     | Description                                                                                              | Documentation Link                                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Azure Subscription & Permissions | Required to create and manage Dev Center, projects, and networking resources                            | [Assign Azure roles using the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal) |
| Network Infrastructure          | Set up custom virtual networks (VNETs), DNS, and optionally join devices to a domain                     | [Configure a custom network](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview) |
| Azure RBAC                      | Assign roles at the Dev Center, project, and resource group levels to manage access                      | [What is Azure RBAC?](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) |
| Dev Box Architecture            | Understand concepts such as Dev Center, Dev Box definitions, and projects                               | [Dev Box Concepts](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-concepts) |
| Monitoring                      | Enable diagnostics and integrate with Azure Monitor for logging and metrics                             | [Monitor Dev Box usage](https://learn.microsoft.com/en-us/azure/dev-box/monitor-dev-box-usage) |

### Configuration Steps

1. **Create Dev Center**
2. **Create Projects**
3. **Configure Dev Box Definitions**
4. **Configure Network Connections**
5. **Assign RBAC Roles**
6. **Set Up Monitoring**

---

## Development Team Leads

### Responsibilities

Development team leads curate and configure Dev Boxes for their team. They define the tools, environments, and policies developers need to build and test code effectively.

### Key Responsibilities

- Create and manage **Dev Box pools**
- Define **images** and **software stack**
- Assign **users** to Dev Box pools
- Align environments with development lifecycle and team needs

### Requirements

| Requirement                     | Description                                                                                              | Documentation Link                                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Contributor Role                | Needed to manage Dev Box resources like projects and pools                                               | [Built-in roles for Azure Dev Center](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control) |
| Developer Tool Knowledge        | Understand required SDKs, frameworks, and tools for the team                                             | [Customize Dev Box images](https://learn.microsoft.com/en-us/azure/dev-box/customize-dev-box) |
| Azure Image Builder (Optional)  | Create and manage custom images with automation                                                          | [Use Azure Image Builder](https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview) |
| Azure Compute Gallery (Optional)| Host and share custom images across the organization                                                     | [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) |

### Configuration Steps

1. **Define Dev Box Pools**
2. **Select or Customize Images**
3. **Assign Users to Pools**
4. **Configure Project Settings**
5. **Review and Validate**

---

## Developers

### Responsibilities

Developers use Dev Boxes as ready-to-code environments. They focus on productivity, keeping their environments aligned with project needs, and reporting any issues to the team lead or platform engineer.

### Key Responsibilities

- Access and use Dev Box to build, debug, and test code
- Customize their Dev Box within defined constraints
- Report issues with performance or software to team leads

### Requirements

| Requirement                     | Description                                                                                              | Documentation Link                                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Azure AD Access                 | User must be assigned to a Dev Box pool and authenticated via Azure Active Directory                    | [Access Dev Box portal](https://learn.microsoft.com/en-us/azure/dev-box/end-user-dev-box-portal) |
| Developer Tools                 | Basic knowledge of development tools provided in the Dev Box image                                       | [Preconfigured Dev Box images](https://learn.microsoft.com/en-us/azure/dev-box/available-dev-box-images) |
| Dev Box Portal Usage            | Ability to start, stop, and connect to a Dev Box                                                          | [Use the Dev Box portal](https://learn.microsoft.com/en-us/azure/dev-box/end-user-dev-box-portal) |

### Usage Steps

1. **Sign in to Dev Box Portal**
2. **Start and Connect**
3. **Develop and Customize**
4. **Manage Dev Box**

---