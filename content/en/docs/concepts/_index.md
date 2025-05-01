---
title: Concepts
date: 2017-01-05
description: >
  Concepts
tags: [test, sample, docs]
weight: 4
---

## 🧩 Key Components

### 1. Dev Center

A **Dev Center** acts as a central hub for managing projects and resources. It allows platform engineers to:

- Manage available images and SKUs via dev box definitions.
- Configure networks that development teams use through network connections.

Dev Centers are shared across Microsoft Dev Box and Azure Deployment Environments, promoting resource consistency.

### 2. Projects

A **Project** represents a team or business function within an organization. Each project:

- Contains one or more dev box pools.
- Inherits settings from its associated Dev Center.
- Can be configured with specific dev box definitions suitable for its workloads.

Developers are granted access to projects by assigning them the **Dev Box User** role.

### 3. Dev Box Definitions

A **Dev Box Definition** specifies the configuration for dev boxes, including:

- Source image (from Azure Marketplace or a custom image in Azure Compute Gallery).
- Compute size (CPU and memory).
- Storage size.

These definitions ensure that dev boxes meet the specific requirements of different development teams.

### 4. Network Connections

**Network Connections** define how dev boxes connect to resources. There are two types:

- **Microsoft-hosted network connection**: Managed by Microsoft, suitable for cloud-only scenarios.
- **Azure network connection**: Managed by your organization, allowing integration with on-premises resources and custom configurations.

The choice depends on your organization's networking and security requirements.

### 5. Catalogs

**Catalogs** contain tasks and scripts used to configure dev boxes during creation. Microsoft provides a quick start catalog with sample tasks, and organizations can create custom catalogs to suit their needs.

---

## 🛠️ Customizations

Customizations allow for tailoring dev boxes to specific needs:

- **Team Customizations**: Applied at the dev box pool level, ensuring consistency across a team's dev boxes.
- **Individual Customizations**: Applied by individual developers during dev box creation for personal configurations.

These customizations are defined using YAML files and can include installing tools, setting environment variables, and more.

---

## 🔐 Security and Management

- **Identity Services**: Dev Box integrates with Microsoft Entra ID (formerly Azure Active Directory) for authentication and device management.
- **Device Management**: Dev boxes are managed using Microsoft Intune, allowing for policy enforcement and compliance.
- **Access Control**: Role-based access control (RBAC) ensures users have appropriate permissions based on their roles (e.g., Platform Engineer, Dev Manager, Developer).


## 📚 Additional Resources

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Quickstart: Create a Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box)
- [Manage Dev Box Definitions](https://learn.microsoft.com/en-us/azure/dev-box/how-to-manage-dev-box-definitions)
- [Dev Box Customizations](https://learn.microsoft.com/en-us/azure/dev-box/concept-what-are-team-customizations)

---

This document provides a foundational understanding of Microsoft Dev Box for beginners in software and cloud engineering. For more detailed information, refer to the official Microsoft documentation linked above.
