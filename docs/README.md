---
title: "DevExp-DevBox Documentation"
description: "Complete documentation for the DevExp-DevBox Landing Zone Accelerator"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - documentation
  - dev-box
  - azure
  - landing-zone
---

# 📚 DevExp-DevBox Documentation

> **Complete documentation for the DevExp-DevBox Landing Zone Accelerator**

> [!NOTE]
> **Welcome!** This documentation hub provides comprehensive guides for deploying and managing Azure Dev Box environments using the DevExp-DevBox Landing Zone Accelerator.

---

## 📑 Table of Contents

- [🎯 Overview](#-overview)
- [🏗️ Architecture Documentation](#️-architecture-documentation)
- [🔄 DevOps Documentation](#-devops-documentation)
- [📜 Scripts Documentation](#-scripts-documentation)
- [🚀 Quick Start](#-quick-start)
- [📖 Additional Resources](#-additional-resources)

---

## 🎯 Overview

The **DevExp-DevBox Landing Zone Accelerator** is an enterprise-grade Infrastructure-as-Code (IaC) solution that enables organizations to rapidly deploy and manage Microsoft Dev Box environments at scale.

### Key Features

| Feature | Description |
|:--------|:------------|
| 🏢 **Enterprise Ready** | Built on Azure Landing Zone principles with security and governance |
| ⚡ **Rapid Deployment** | Automated provisioning with Azure Developer CLI (azd) |
| 🔒 **Security First** | RBAC, Key Vault integration, and OIDC authentication |
| 📊 **Observability** | Integrated monitoring with Log Analytics |
| 🔄 **CI/CD Ready** | GitHub Actions workflows for automated deployments |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🏗️ Architecture Documentation

Comprehensive TOGAF-aligned architecture documentation covering business, data, application, technology, security, and deployment aspects.

| Document | Description |
|:---------|:------------|
| 📋 [Business Architecture](architecture/01-business-architecture.md) | Business context, stakeholders, and value propositions |
| 🗄️ [Data Architecture](architecture/02-data-architecture.md) | Configuration data models, secrets management, and telemetry |
| 📦 [Application Architecture](architecture/03-application-architecture.md) | Bicep module catalog, dependencies, and deployment orchestration |
| ☁️ [Technology Architecture](architecture/04-technology-architecture.md) | Azure services, infrastructure design, and technology standards |
| 🔒 [Security Architecture](architecture/05-security-architecture.md) | Identity management, RBAC, and compliance framework |
| 🚀 [Deployment Architecture](architecture/07-deployment-architecture.md) | CI/CD pipeline design and deployment patterns |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔄 DevOps Documentation

Detailed documentation for GitHub Actions workflows and CI/CD processes.

| Document | Description |
|:---------|:------------|
| 📖 [DevOps Overview](devops/README.md) | Master pipeline architecture and workflow relationships |
| 🔄 [CI Workflow](devops/ci.md) | Continuous Integration workflow for Bicep validation and build |
| 🚀 [Deploy Workflow](devops/deploy.md) | Azure deployment workflow with OIDC authentication |
| 🏷️ [Release Workflow](devops/release.md) | Branch-based release strategy and semantic versioning |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📜 Scripts Documentation

PowerShell automation scripts for environment setup, Azure configuration, and GitHub integration.

### 📁 Root Scripts

| Document | Description |
|:---------|:------------|
| 📖 [Scripts Overview](scripts/README.md) | Complete scripts architecture and quick reference |
| ⚙️ [setUp.ps1](scripts/setup.md) | Azure Dev Box environment setup with source control integration |
| 🧹 [cleanSetUp.ps1](scripts/clean-setup.md) | Complete infrastructure cleanup orchestrator |

### ☁️ Azure Scripts

| Document | Description |
|:---------|:------------|
| 🔑 [createCustomRole.ps1](scripts/azure/create-custom-role.md) | Creates custom Azure RBAC role for role assignment management |
| 👥 [createUsersAndAssignRole.ps1](scripts/azure/create-users-and-assign-role.md) | Assigns DevCenter roles to the current user |
| 🗑️ [deleteDeploymentCredentials.ps1](scripts/azure/delete-deployment-credentials.md) | Removes Azure AD service principal and app registration |
| 👥 [deleteUsersAndAssignedRoles.ps1](scripts/azure/delete-users-and-assigned-roles.md) | Removes DevCenter role assignments |
| 🔑 [generateDeploymentCredentials.ps1](scripts/azure/generate-deployment-credentials.md) | Creates service principal and GitHub secret for CI/CD |

### ⚙️ Configuration Scripts

| Document | Description |
|:---------|:------------|
| 🧹 [cleanUp.ps1](scripts/configuration/clean-up.md) | Removes Azure resource groups |
| 📦 [winget-update.ps1](scripts/configuration/winget-update.md) | Updates Microsoft Store applications via winget |

### 🐙 GitHub Scripts

| Document | Description |
|:---------|:------------|
| 🔐 [createGitHubSecretAzureCredentials.ps1](scripts/github/create-github-secret-azure-credentials.md) | Creates GitHub repository secret for Azure credentials |
| 🗑️ [deleteGitHubSecretAzureCredentials.ps1](scripts/github/delete-github-secret-azure-credentials.md) | Removes GitHub repository secret |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🚀 Quick Start

### Prerequisites

| Tool | Purpose | Installation |
|:-----|:--------|:-------------|
| Azure CLI (`az`) | Azure resource management | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| Azure Developer CLI (`azd`) | Deployment orchestration | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) |
| GitHub CLI (`gh`) | GitHub integration | [Install GitHub CLI](https://cli.github.com/) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Setup Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/Evilazaro/DevExp-DevBox.git
   cd DevExp-DevBox
   ```

2. **Authenticate with Azure**

   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

3. **Run the setup script**

   ```powershell
   .\setUp.ps1 -EnvName "demo" -SourceControl "github"
   ```

4. **Deploy to Azure**

   ```bash
   azd provision
   ```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📖 Additional Resources

### External Links

| Resource | Description |
|:---------|:------------|
| [Microsoft Dev Box Documentation](https://learn.microsoft.com/azure/dev-box/) | Official Azure Dev Box documentation |
| [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) | Cloud Adoption Framework Landing Zones |
| [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/) | Bicep language reference |
| [GitHub Actions Documentation](https://docs.github.com/actions) | GitHub Actions workflows |

### Repository Links

| Resource | Description |
|:---------|:------------|
| [📁 Infrastructure Code](../infra/) | Bicep templates and configuration |
| [📁 Source Modules](../src/) | Reusable Bicep modules |
| [📄 azure.yaml](../azure.yaml) | Azure Developer CLI configuration |

---

[⬆️ Back to Top](#-table-of-contents)

---

<div align="center">

**[⬆️ Back to Repository Root](../README.md)**

</div>
