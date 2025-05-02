---
title: Organization roles and responsabilities requirements
description: >
  Dev Box Landing Zone Accelerator – Organization roles and responsabilities for: Platform engineers, development team leads, and developers. 
tags: [test, sample, docs]
weight: 5
---

{{% pageinfo %}}  
**Learn more** about Microsoft Dev Box Organizational roles and responsibilities for the deployment, access the [official documentation site](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide#organizational-roles-and-responsibilities).
{{% /pageinfo %}} 

# Dev Box Landing Zone Accelerator – Prerequisites Checklist

## Purpose

This document provides a comprehensive list of prerequisites to help you validate and prepare your environment before deploying the **Microsoft Dev Box Landing Zone Accelerator**. It ensures that all required tools, permissions, resources, and configurations are in place to streamline a successful deployment.

---

## General Requirements

| Requirement                     | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Azure Subscription              | A valid Azure subscription with Owner or Contributor access                                             | [Create and manage subscriptions](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription) |
| Microsoft Entra ID              | A configured Microsoft Entra tenant for identity and access control                                     | [What is Microsoft Entra ID?](https://learn.microsoft.com/en-us/entra/fundamentals/whatis)         |
| Azure CLI                       | Required to execute Bicep templates from local environments                                              | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)                 |
| Git                             | Required to clone the landing zone accelerator repository                                                | [Install Git](https://git-scm.com/downloads)                                                       |
| Bicep CLI (or native support)   | Required for deploying `.bicep` infrastructure templates                                                 | [Bicep Installation Guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) |

---

## Role-Based RBAC Permissions

### Platform Engineer

| Permission / Role               | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Owner / Contributor             | Full access to deploy infrastructure and assign permissions                                             | [Owner Role](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) |
| DevCenter Administrator         | Manage Dev Centers, projects, definitions, and network connections                                      | [Dev Box RBAC Roles](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |
| Network Contributor             | Required to manage VNETs and DNS integrations                                                           | [Network Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#network-contributor) |

### Development Team Lead

| Permission / Role               | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| DevCenter Project Admin         | Assign users, manage Dev Box pools and configurations                                                   | [Dev Box RBAC Roles](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |
| Contributor (Optional)          | Needed to manage custom images or compute gallery resources                                             | [Contributor Role](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) |

### Developer

| Permission / Role               | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Dev Box User                    | Grants access to view, start, and stop assigned Dev Boxes                                               | [Dev Box User Role](https://learn.microsoft.com/en-us/azure/dev-box/role-based-access-control#roles) |

To learn how to assign RBAC roles in Azure, refer to:  
[Assign roles using Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

---

## Networking Requirements

| Requirement                     | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Microsoft-hosted Network        | Quick start network managed by Microsoft                                                                | [Networking Overview](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview) |
| Custom VNET (Optional)          | Required for domain join, hybrid networking, or custom DNS                                              | [Custom network configuration](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview) |
| DNS Resolution                  | Necessary when using custom VNETs or domain join scenarios                                              | [DNS requirements](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview#dns-requirements) |
| Hybrid Join or AD DS (Optional) | Supports domain-joined Dev Boxes via Azure AD DS or hybrid join                                         | [AD integration](https://learn.microsoft.com/en-us/azure/dev-box/network-connection-overview#active-directory-integration) |

---

## Dev Box Configuration Prerequisites

| Component                       | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Dev Center                      | Central management plane for all Dev Box resources                                                      | [Create a Dev Center](https://learn.microsoft.com/en-us/azure/dev-box/quick-create-dev-center-portal) |
| Project                         | Used to group dev box pools, images, and user permissions                                               | [Set up projects](https://learn.microsoft.com/en-us/azure/dev-box/projects)                        |
| Dev Box Definitions             | Templates defining SKUs, base images, and settings                                                      | [Define dev box configurations](https://learn.microsoft.com/en-us/azure/dev-box/dev-box-definitions) |
| Dev Box Pools                   | Logical groupings of dev boxes assigned to specific users or groups                                     | [Create dev box pools](https://learn.microsoft.com/en-us/azure/dev-box/dev-box-pools)              |

---

## Optional (Advanced) Components

| Component                       | Description                                                                                             | Documentation                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Azure Image Builder             | Automates creation of golden images                                                                    | [Azure Image Builder](https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview) |
| Azure Compute Gallery           | Hosts and shares custom images across regions or environments                                           | [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries) |
| Azure Monitor                   | Enables diagnostics and telemetry collection from Dev Boxes                                             | [Monitor Dev Box usage](https://learn.microsoft.com/en-us/azure/dev-box/monitor-dev-box-usage)    |
| Azure Policy                    | Enforce organizational rules and compliance (e.g., allowed locations or SKUs)                          | [Azure Policy Overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)       |

---

## Summary

Before deploying the Dev Box Landing Zone Accelerator, ensure:

- All necessary **roles and permissions** are assigned
- **Network and DNS infrastructure** is in place (if using custom VNET)
- All required **Azure resources and configurations** are pre-created or defined
- Your team is equipped with the **Azure CLI**, **Git**, and optional **Bicep** tooling

With this checklist completed, your organization will be ready to deploy scalable, compliant, and developer-ready Microsoft Dev Box environments using the landing zone accelerator.
