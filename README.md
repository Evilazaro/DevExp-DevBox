---
title: Dev Box Landing Zone Accelerator
description:
  Enterprise-ready Infrastructure as Code (IaC) solution for deploying Microsoft
  Dev Box environments following Azure Cloud Adoption Framework best practices.
author: DevExp Team
date: 2024-01-01
version: 1.0.0
tags: [azure, devbox, devcenter, bicep, infrastructure-as-code, landing-zone]
---

# 🚀 Dev Box Landing Zone Accelerator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Azure](https://img.shields.io/badge/Azure-DevCenter-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/services/dev-box/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-blue)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

> [!NOTE] **Target Audience:** Platform Engineers, Cloud Architects, and DevOps
> Teams<br> **Reading Time:** ~25 minutes

<details>
<summary>📍 Navigation</summary>

| Previous |   Index    |                                    Next |
| :------- | :--------: | --------------------------------------: |
| —        | **README** | [Release Strategy](RELEASE_STRATEGY.md) |

</details>

---

## 📖 Overview

Organizations adopting Microsoft Dev Box face significant challenges in
establishing secure, scalable, and compliant cloud development environments.
Traditional approaches often result in fragmented deployments, inconsistent
security configurations, and lengthy setup times that hinder developer
productivity. Development teams need standardized, pre-configured environments
that align with enterprise governance policies while maintaining flexibility for
different project requirements.

The Dev Box Landing Zone Accelerator addresses these challenges by providing an
enterprise-ready, Infrastructure as Code (IaC) solution that automates the
deployment of Microsoft Dev Box environments following Azure Cloud Adoption
Framework best practices. This accelerator eliminates the complexity of manual
configuration, ensures consistent security postures across all development
environments, and significantly reduces the time-to-productivity for development
teams.

Built on Azure Bicep and integrated with Azure Developer CLI (azd), this
solution provides a repeatable, testable deployment pattern that scales from
individual projects to enterprise-wide implementations. It incorporates identity
management, network isolation, monitoring, and security controls out-of-the-box,
enabling organizations to focus on building applications rather than managing
infrastructure.

> [!TIP] This accelerator is built on **Azure Bicep** and integrated with
> **Azure Developer CLI (azd)**, providing a repeatable, testable deployment
> pattern that scales from individual projects to enterprise-wide
> implementations.

---

<details>
<summary>📑 <strong>Table of Contents</strong></summary>

- [📖 Overview](#-overview)
- [🏗️ Architecture Overview](#️-architecture-overview)
  - [🏢 Business Architecture](#-business-architecture)
  - [💾 Data Architecture](#-data-architecture)
  - [📐 Application Architecture](#-application-architecture)
  - [☁️ Technology Architecture](#️-technology-architecture)
- [✨ Key Features and Benefits](#-key-features-and-benefits)
- [📋 Prerequisites](#-prerequisites)
- [🔐 Azure RBAC Roles](#-azure-rbac-roles)
- [🚀 Deployment Instructions](#-deployment-instructions)
- [⚙️ Configuration Reference](#️-configuration-reference)
- [📦 Release Strategy](#-release-strategy)
- [🔧 Troubleshooting](#-troubleshooting)
- [🧹 Cleanup](#-cleanup)
- [🤝 Contributing](#-contributing)
- [🔒 Security](#-security)
- [📄 License](#-license)
- [💬 Support](#-support)
- [📚 Additional Resources](#-additional-resources)
- [📎 Related Documents](#-related-documents)

</details>

---

## 🏗️ Architecture Overview

The Dev Box Landing Zone Accelerator implements a layered architecture aligned
with TOGAF principles, organizing resources into four distinct landing zones:
Security, Monitoring, Connectivity, and Workload. This design ensures separation
of concerns, independent scaling, and adherence to enterprise governance
requirements.

### 🏢 Business Architecture

#### Purpose

The business architecture layer defines the organizational capabilities, value
streams, and business processes required to establish and operate
enterprise-scale cloud development environments. It aligns technical
implementation with business objectives including developer productivity,
security compliance, cost optimization, and operational efficiency.

#### 🎯 Key Capabilities

- **Developer Environment Provisioning**: Automated creation and lifecycle
  management of standardized development environments
- **Security and Compliance Management**: Enforcement of enterprise security
  policies, role-based access control, and regulatory compliance
- **Resource Governance**: Centralized control of resource allocation, cost
  management, and policy enforcement
- **Identity and Access Management**: Integration with Azure Active Directory
  for authentication and authorization
- **Monitoring and Observability**: Centralized logging, metrics collection, and
  operational insights
- **Catalog Management**: Version-controlled environment definitions and image
  repositories

#### 🔄 High-Level Process

1. **Environment Request**: Developers or administrators initiate environment
   provisioning
2. **Authentication**: Identity verification through Azure AD integration
3. **Authorization**: RBAC policy evaluation and permission validation
4. **Resource Allocation**: DevCenter assigns resources based on project
   configuration
5. **Network Configuration**: Connectivity establishment (managed or unmanaged
   VNet)
6. **Security Policy Application**: Key Vault integration and secret management
7. **Monitoring Integration**: Log Analytics and diagnostic settings
   configuration
8. **Environment Delivery**: Developer access to provisioned Dev Box

#### 🗺️ Business Capability Map

```mermaid
flowchart TB
    subgraph DevEnv[Developer Environment Management]
        DE1[Environment Provisioning]
        DE2[Catalog Management]
        DE3[Image Definition Management]
        DE4[Pool Management]
    end

    subgraph SecComp[Security & Compliance]
        SC1[Identity Management]
        SC2[Secret Management]
        SC3[Network Isolation]
        SC4[RBAC Enforcement]
    end

    subgraph ResGov[Resource Governance]
        RG1[Resource Group Management]
        RG2[Policy Enforcement]
        RG3[Cost Management]
        RG4[Tag Management]
    end

    subgraph MonObs[Monitoring & Observability]
        MO1[Centralized Logging]
        MO2[Metrics Collection]
        MO3[Diagnostic Settings]
        MO4[Activity Tracking]
    end

    style DevEnv fill:#E6E6FA
    style SecComp fill:#E6E6FA
    style ResGov fill:#E6E6FA
    style MonObs fill:#E6E6FA
    style DE1 fill:#E6E6FA
    style DE2 fill:#E6E6FA
    style DE3 fill:#E6E6FA
    style DE4 fill:#E6E6FA
    style SC1 fill:#E6E6FA
    style SC2 fill:#E6E6FA
    style SC3 fill:#E6E6FA
    style SC4 fill:#E6E6FA
    style RG1 fill:#E6E6FA
    style RG2 fill:#E6E6FA
    style RG3 fill:#E6E6FA
    style RG4 fill:#E6E6FA
    style MO1 fill:#E6E6FA
    style MO2 fill:#E6E6FA
    style MO3 fill:#E6E6FA
    style MO4 fill:#E6E6FA
```

#### 📊 Value Stream Map

```mermaid
flowchart LR
    A[Developer Request] --> B[Identity Verification]
    B --> C[Authorization Check]
    C --> D[Resource Allocation]
    D --> E[Network Configuration]
    E --> F[Security Policy Application]
    F --> G[Monitoring Integration]
    G --> H[Environment Ready]
    H --> I[Developer Access]

    style A fill:#E6E6FA
    style B fill:#E6E6FA
    style C fill:#E6E6FA
    style D fill:#E6E6FA
    style E fill:#E6E6FA
    style F fill:#E6E6FA
    style G fill:#E6E6FA
    style H fill:#E6E6FA
    style I fill:#E6E6FA
```

### 💾 Data Architecture

#### Purpose

The data architecture layer defines how configuration data, secrets, monitoring
data, and operational metadata flow through the system. It ensures data
security, integrity, and accessibility while maintaining compliance with
enterprise data governance policies.

#### 🎯 Key Capabilities

- **Configuration Management**: YAML-based declarative configuration for all
  infrastructure resources
- **Secret Management**: Secure storage and retrieval of sensitive data via
  Azure Key Vault
- **Operational Data Collection**: Centralized logging and metrics via Log
  Analytics Workspace
- **Diagnostic Data**: Resource-level diagnostic settings for all Azure services
- **Environment State Management**: Azure Developer CLI environment
  configuration and state tracking

#### 🔄 High-Level Process

1. **Configuration Ingestion**: YAML files define resource configurations
2. **Secret Storage**: Personal Access Tokens (PAT) stored securely in Key Vault
3. **Bicep Compilation**: Declarative templates compiled to ARM templates
4. **Resource Provisioning**: ARM templates deployed to Azure subscriptions
5. **Diagnostic Configuration**: Log Analytics workspace linked to all resources
6. **Metadata Tracking**: Resource tags and configuration metadata maintained

#### 📊 Master Data Management

```mermaid
flowchart LR
    subgraph Sources[Data Sources]
        S1[YAML Configuration Files]
        S2[Environment Variables]
        S3[Source Control Tokens]
        S4[Azure Subscription Data]
    end

    subgraph Ingestion[Ingestion Layer]
        I1[Setup Scripts]
        I2[Azure CLI]
        I3[AZD CLI]
    end

    subgraph Processing[Processing Layer]
        P1[Bicep Compilation]
        P2[Parameter Validation]
        P3[Secret Encryption]
        P4[Resource Naming]
    end

    subgraph Storage[Storage Layer]
        ST1[Key Vault Secrets]
        ST2[Log Analytics Workspace]
        ST3[Resource Metadata]
        ST4[Environment State]
    end

    subgraph Governance[Governance Layer]
        G1[RBAC Policies]
        G2[Diagnostic Settings]
        G3[Access Policies]
        G4[Tag Policies]
    end

    S1 --> I1
    S2 --> I2
    S3 --> I3
    S4 --> I2

    I1 --> P1
    I2 --> P2
    I3 --> P3
    I2 --> P4

    P1 --> ST3
    P2 --> ST3
    P3 --> ST1
    P4 --> ST4

    ST1 --> G3
    ST2 --> G2
    ST3 --> G1
    ST4 --> G4

    style Sources fill:#ADD8E6
    style Ingestion fill:#ADD8E6
    style Processing fill:#90EE90
    style Storage fill:#FFFACD
    style Governance fill:#D3D3D3
    style S1 fill:#ADD8E6
    style S2 fill:#ADD8E6
    style S3 fill:#ADD8E6
    style S4 fill:#ADD8E6
    style I1 fill:#ADD8E6
    style I2 fill:#ADD8E6
    style I3 fill:#ADD8E6
    style P1 fill:#90EE90
    style P2 fill:#90EE90
    style P3 fill:#90EE90
    style P4 fill:#90EE90
    style ST1 fill:#FFFACD
    style ST2 fill:#FFFACD
    style ST3 fill:#FFFACD
    style ST4 fill:#FFFACD
    style G1 fill:#D3D3D3
    style G2 fill:#D3D3D3
    style G3 fill:#D3D3D3
    style G4 fill:#D3D3D3
```

### 📐 Application Architecture

#### Purpose

The application architecture layer defines the logical organization of
infrastructure components, their relationships, and deployment patterns. It
implements a modular, reusable design that supports enterprise-scale deployments
while maintaining separation of concerns through landing zone isolation.

#### 🎯 Key Capabilities

- **Modular Component Design**: Reusable Bicep modules for each landing zone and
  resource type
- **Identity-Based Security**: System-assigned managed identities for
  service-to-service authentication
- **Catalog Integration**: GitHub and Azure DevOps repository integration for
  environment definitions
- **Network Abstraction**: Support for both Microsoft-hosted (managed) and
  customer-managed (unmanaged) virtual networks
- **Project Isolation**: Independent project configurations with dedicated
  resource groups and RBAC
- **Diagnostic Integration**: Automated Log Analytics workspace linkage for all
  resources

#### 🔄 High-Level Process

1. **Landing Zone Creation**: Resource groups provisioned for Security,
   Monitoring, Connectivity, and Workload
2. **Security Provisioning**: Key Vault deployed with secrets and access
   policies
3. **Monitoring Provisioning**: Log Analytics Workspace and diagnostic settings
   configured
4. **DevCenter Provisioning**: Core DevCenter resource with catalogs and
   environment types
5. **Project Provisioning**: Multiple projects with pools, environment types,
   and network connections
6. **RBAC Configuration**: Role assignments at subscription, resource group, and
   resource scopes
7. **Catalog Synchronization**: Git repositories synced for environment and
   image definitions

#### 🏛️ Solution Architecture

```mermaid
flowchart TB
    subgraph Clients[Client Layer]
        C1[Azure Portal]
        C2[Azure CLI]
        C3[Azure Developer CLI]
        C4[PowerShell/Bash Scripts]
    end

    subgraph Gateway[Management Layer]
        G1[Azure Resource Manager]
    end

    subgraph Services[Service Layer]
        SV1[DevCenter Core]
        SV2[DevCenter Projects]
        SV3[DevCenter Catalogs]
        SV4[Environment Types]
        SV5[DevBox Pools]
    end

    subgraph Security[Security Layer]
        SE1[Key Vault]
        SE2[Managed Identities]
        SE3[RBAC Assignments]
    end

    subgraph Monitoring[Monitoring Layer]
        M1[Log Analytics Workspace]
        M2[Diagnostic Settings]
        M3[Azure Monitor]
    end

    subgraph Connectivity[Connectivity Layer]
        CN1[Virtual Network]
        CN2[Network Connection]
        CN3[Subnets]
    end

    C1 --> G1
    C2 --> G1
    C3 --> G1
    C4 --> G1

    G1 --> SV1

    SV1 --> SV2
    SV1 --> SV3
    SV1 --> SV4
    SV2 --> SV5

    SV1 --> SE2
    SV2 --> SE2
    SV3 --> SE1
    SE2 --> SE3

    SV1 --> M2
    SV2 --> M2
    M2 --> M1
    M1 --> M3

    SV5 --> CN2
    CN2 --> CN1
    CN1 --> CN3

    style Clients fill:#ADD8E6
    style Gateway fill:#E6E6FA
    style Services fill:#90EE90
    style Security fill:#D3D3D3
    style Monitoring fill:#D3D3D3
    style Connectivity fill:#FFFACD
    style C1 fill:#ADD8E6
    style C2 fill:#ADD8E6
    style C3 fill:#ADD8E6
    style C4 fill:#ADD8E6
    style G1 fill:#E6E6FA
    style SV1 fill:#90EE90
    style SV2 fill:#90EE90
    style SV3 fill:#90EE90
    style SV4 fill:#90EE90
    style SV5 fill:#90EE90
    style SE1 fill:#D3D3D3
    style SE2 fill:#D3D3D3
    style SE3 fill:#D3D3D3
    style M1 fill:#D3D3D3
    style M2 fill:#D3D3D3
    style M3 fill:#D3D3D3
    style CN1 fill:#FFFACD
    style CN2 fill:#FFFACD
    style CN3 fill:#FFFACD
```

### ☁️ Technology Architecture

#### Purpose

The technology architecture layer defines the specific Azure services,
deployment tools, integration patterns, and automation workflows used to
implement the solution. It ensures the use of cloud-native services,
infrastructure as code best practices, and platform engineering principles.

#### 🎯 Key Capabilities

- **Infrastructure as Code**: Azure Bicep for declarative infrastructure
  provisioning
- **Deployment Automation**: Azure Developer CLI (azd) for repeatable
  deployments
- **Source Control Integration**: GitHub and Azure DevOps for catalog and
  environment definition management
- **Monitoring Integration**: Azure Monitor and Log Analytics for operational
  insights
- **Identity Integration**: Azure Active Directory for authentication and
  authorization
- **Secret Management**: Azure Key Vault with RBAC authorization model
- **Network Services**: Azure Virtual Network with managed or unmanaged
  connectivity options

#### 🔄 High-Level Process

1. **Tool Validation**: Setup scripts verify Azure CLI, azd CLI, and source
   control tools
2. **Authentication**: Azure and source control platform authentication
   established
3. **Environment Initialization**: azd environment created with configuration
   files
4. **Secret Storage**: PATs stored in Key Vault with encryption
5. **Resource Provisioning**: Bicep templates deployed via azd provision
6. **Diagnostic Configuration**: Log Analytics workspace linked to all resources
7. **RBAC Application**: Role assignments created at appropriate scopes
8. **Catalog Synchronization**: Git repositories synchronized for definitions

#### ☁️ Cloud-Native Architecture

```mermaid
flowchart LR
    subgraph Clients[Client Interfaces]
        CL1[Azure Portal]
        CL2[Azure CLI]
        CL3[PowerShell/Bash]
        CL4[Azure Developer CLI]
    end

    subgraph Gateway[API Gateway]
        GW1[Azure Resource Manager]
    end

    subgraph Services[Azure Services]
        SR1[Microsoft DevCenter]
        SR2[DevCenter Projects]
        SR3[Azure Key Vault]
        SR4[Virtual Network]
    end

    subgraph EventBus[Event Integration]
        EB1[Diagnostic Settings]
    end

    subgraph DataStorage[Data & Storage]
        DS1[Log Analytics Workspace]
        DS2[Key Vault Secrets]
    end

    subgraph Observability[Observability & Security]
        OB1[Azure Monitor]
        OB2[RBAC Policies]
        OB3[Managed Identities]
    end

    CL1 --> GW1
    CL2 --> GW1
    CL3 --> GW1
    CL4 --> GW1

    GW1 --> SR1
    GW1 --> SR2
    GW1 --> SR3
    GW1 --> SR4

    SR1 --> EB1
    SR2 --> EB1
    SR3 --> EB1

    EB1 --> DS1
    SR3 --> DS2

    DS1 --> OB1
    SR1 --> OB3
    SR2 --> OB3
    OB3 --> OB2

    style Clients fill:#ADD8E6
    style Gateway fill:#E6E6FA
    style Services fill:#90EE90
    style EventBus fill:#FFB347
    style DataStorage fill:#FFFACD
    style Observability fill:#D3D3D3
    style CL1 fill:#ADD8E6
    style CL2 fill:#ADD8E6
    style CL3 fill:#ADD8E6
    style CL4 fill:#ADD8E6
    style GW1 fill:#E6E6FA
    style SR1 fill:#90EE90
    style SR2 fill:#90EE90
    style SR3 fill:#90EE90
    style SR4 fill:#90EE90
    style EB1 fill:#FFB347
    style DS1 fill:#FFFACD
    style DS2 fill:#FFFACD
    style OB1 fill:#D3D3D3
    style OB2 fill:#D3D3D3
    style OB3 fill:#D3D3D3
```

#### 🔧 Platform Engineering Architecture

```mermaid
flowchart TB
    subgraph Developers[Developer Experience]
        D1[Setup Scripts - setUp.ps1]
        D2[Setup Scripts - setUp.sh]
        D3[Configuration Files - YAML]
        D4[Azure Developer CLI]
    end

    subgraph IDP[Internal Developer Platform]
        IDP1[Bicep Modules]
        IDP2[YAML Configuration]
        IDP3[Resource Templates]
        IDP4[Landing Zone Patterns]
    end

    subgraph CICD[CI/CD & Policies]
        CI1[GitHub Actions]
        CI2[Azure Pipelines]
        CI3[Deployment Workflows]
    end

    subgraph Runtime[Runtime Platforms]
        RT1[Microsoft DevCenter]
        RT2[DevBox Pools]
        RT3[Environment Types]
        RT4[Project Catalogs]
    end

    subgraph Shared[Shared Services]
        SH1[Azure Key Vault]
        SH2[Log Analytics Workspace]
        SH3[Virtual Networks]
    end

    subgraph Data[Data Services]
        DT1[Configuration Store]
        DT2[Secret Store]
        DT3[Metrics Store]
    end

    D1 --> IDP1
    D2 --> IDP1
    D3 --> IDP2
    D4 --> IDP1

    IDP1 --> CI1
    IDP2 --> CI2
    IDP3 --> CI3
    IDP4 --> CI1

    CI1 --> RT1
    CI2 --> RT1
    CI3 --> RT1

    RT1 --> RT2
    RT1 --> RT3
    RT1 --> RT4

    RT1 --> SH1
    RT2 --> SH2
    RT3 --> SH3

    SH1 --> DT2
    SH2 --> DT3
    IDP2 --> DT1

    style Developers fill:#ADD8E6
    style IDP fill:#90EE90
    style CICD fill:#90EE90
    style Runtime fill:#E6E6FA
    style Shared fill:#D3D3D3
    style Data fill:#FFFACD
    style D1 fill:#ADD8E6
    style D2 fill:#ADD8E6
    style D3 fill:#ADD8E6
    style D4 fill:#ADD8E6
    style IDP1 fill:#90EE90
    style IDP2 fill:#90EE90
    style IDP3 fill:#90EE90
    style IDP4 fill:#90EE90
    style CI1 fill:#90EE90
    style CI2 fill:#90EE90
    style CI3 fill:#90EE90
    style RT1 fill:#E6E6FA
    style RT2 fill:#E6E6FA
    style RT3 fill:#E6E6FA
    style RT4 fill:#E6E6FA
    style SH1 fill:#D3D3D3
    style SH2 fill:#D3D3D3
    style SH3 fill:#D3D3D3
    style DT1 fill:#FFFACD
    style DT2 fill:#FFFACD
    style DT3 fill:#FFFACD
```

---

## ✨ Key Features and Benefits

### 🏢 Enterprise-Scale Deployment

- **Multi-Project Support**: Deploy multiple DevCenter projects with independent
  configurations and resource isolation
- **Landing Zone Organization**: Separate resource groups for Security,
  Monitoring, Connectivity, and Workload components
- **Hierarchical Resource Naming**: Consistent naming conventions using
  environment name and location identifiers
- **Tag-Based Governance**: Automated tagging for cost allocation, compliance
  tracking, and resource organization

### 🔐 Security and Compliance

- **Managed Identity Integration**: System-assigned identities for secure
  service-to-service authentication without credential management
- **Azure Key Vault Integration**: Centralized secret management with purge
  protection and soft delete enabled
- **Role-Based Access Control**: Fine-grained permission management at
  subscription, resource group, and resource levels
- **Network Isolation**: Support for both Azure AD-joined (managed) and
  customer-managed (unmanaged) virtual network scenarios
- **Diagnostic Settings**: Automated configuration for security audit logging
  and compliance reporting

### 📊 Operational Excellence

- **Centralized Logging**: Log Analytics Workspace integration for all DevCenter
  and project resources
- **Diagnostic Settings Automation**: Automated configuration of diagnostic data
  collection for all resources
- **Azure Monitor Integration**: Built-in monitoring and alerting capabilities
  for operational insights
- **Purge Protection**: Soft delete and purge protection for Key Vault to
  prevent accidental data loss

### 👨‍💻 Developer Productivity

- **Automated Environment Provisioning**: One-command deployment of complete
  development environments
- **Catalog Integration**: Support for GitHub and Azure DevOps repository
  catalogs with private and public visibility
- **Image Definition Management**: Centralized management of DevBox images with
  versioning support
- **Environment Templates**: Reusable environment definitions for consistent,
  repeatable deployments
- **Multi-Platform Tooling**: Support for Windows (PowerShell) and Linux/macOS
  (Bash) deployment scripts

### 📜 Infrastructure as Code

- **Declarative Configuration**: YAML-based configuration for all infrastructure
  resources
- **Modular Design**: Reusable Bicep modules for each component with clear
  separation of concerns
- **Parameter Validation**: Built-in validation for deployment parameters to
  prevent misconfigurations
- **Idempotent Deployments**: Safe to run multiple times without unintended side
  effects
- **Type-Safe Templates**: Bicep type definitions ensure configuration
  correctness at compile time

---

## 📋 Prerequisites

> [!IMPORTANT] Ensure all prerequisites are met before proceeding with
> deployment to avoid configuration issues.

### 🛠️ Required Tools

| Tool                | Minimum Version    | Purpose                                          | Installation Link                                                                                          |
| ------------------- | ------------------ | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Azure CLI           | 2.50.0+            | Azure resource management and authentication     | [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)                               |
| Azure Developer CLI | 1.5.0+             | Deployment automation and environment management | [Install Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) |
| PowerShell          | 5.1+ (Windows)     | Setup script execution on Windows                | Built-in on Windows                                                                                        |
| Bash                | 4.0+ (Linux/macOS) | Setup script execution on Linux/macOS            | Built-in on Linux/macOS                                                                                    |
| GitHub CLI          | 2.0+ (optional)    | GitHub authentication and integration            | [Install GitHub CLI](https://cli.github.com/)                                                              |
| Git                 | 2.30.0+            | Version control and repository operations        | [Install Git](https://git-scm.com/downloads)                                                               |

### ☁️ Azure Subscription Requirements

- Active Azure subscription with permissions to create resources
- Sufficient quota for Microsoft DevCenter resources in target region
- No existing DevCenter resources with conflicting names in target subscription
- Service principal creation permissions (if using CI/CD)

### 🌐 Network Requirements

- Virtual network address space available (if using unmanaged networking mode)
- Subnet delegation permissions (if using customer-managed virtual networks)
- Firewall rules configured for outbound connectivity to Azure services
- DNS resolution configured for Azure AD authentication

### 📂 Source Control Requirements

#### GitHub

- GitHub account with repository access
- Personal Access Token (PAT) with `repo` scope for private repositories
- GitHub CLI authenticated (if using interactive setup)

#### Azure DevOps

- Azure DevOps organization and project access
- Personal Access Token (PAT) with `Code (Read)` permissions
- Azure DevOps CLI extension configured with defaults

---

## 🔐 Azure RBAC Roles

The following Azure built-in roles are required or assigned by this solution:

| Role Name                        | Description                                                                                                | Scope          | Documentation Link                                                                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Contributor**                  | Full access to manage all resources but cannot grant access to others. Required for deployment.            | Subscription   | [Contributor](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#contributor)                                   |
| **User Access Administrator**    | Manage user access to Azure resources including role assignments. Required for RBAC configuration.         | Subscription   | [User Access Administrator](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator)       |
| **Managed Identity Contributor** | Create, read, update, and delete managed identities. Assigned to service principals.                       | Subscription   | [Managed Identity Contributor](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#managed-identity-contributor) |
| **Key Vault Secrets User**       | Read secret contents from Azure Key Vault. Assigned to DevCenter managed identities.                       | Resource Group | [Key Vault Secrets User](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-user)             |
| **DevCenter Dev Box User**       | Provides access to create and manage Dev Boxes within projects. Assigned to developer groups.              | Project        | [DevCenter Dev Box User](https://learn.microsoft.com/azure/dev-box/how-to-dev-box-user)                                                 |
| **DevCenter Project Admin**      | Provides full access to manage DevCenter projects including pools and environment types.                   | Project        | [DevCenter Project Admin](https://learn.microsoft.com/azure/dev-box/how-to-project-admin)                                               |
| **Network Contributor**          | Manage networks including virtual networks, subnets, and network connections.                              | Resource Group | [Network Contributor](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#network-contributor)                   |
| **Owner**                        | Full access to all resources and can grant access. Assigned to DevCenter identity for resource management. | Resource Group | [Owner](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner)                                               |

### 🎯 Role Assignment Strategy

The solution implements role assignments at multiple scopes following the
principle of least privilege:

1. **Subscription Level**:
   - Service principal roles for deployment automation
   - DevCenter managed identity roles for cross-resource-group operations

2. **Resource Group Level**:
   - Project managed identity roles for resource creation within security
     resource group
   - DevCenter managed identity roles for Key Vault access

3. **Project Level**:
   - User and Azure AD group roles for developer access to Dev Boxes
   - Administrator roles for project management and configuration

4. **Resource Level**:
   - Specific resource permissions via RBAC (Key Vault, Log Analytics)
   - Diagnostic settings permissions for monitoring integration

---

## 🚀 Deployment Instructions

> [!TIP] For best results, follow each step in order and verify successful
> completion before proceeding to the next step.

### 📌 Step 1: Clone the Repository

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
```

### 🔑 Step 2: Configure Source Control Platform

The solution supports two source control platforms for catalog integration.
Choose one based on your organization's requirements.

#### 🐙 Option A: GitHub

1. **Authenticate GitHub CLI** (if using interactive setup):

   ```bash
   gh auth login
   ```

2. **Create Personal Access Token**:
   - Navigate to GitHub Settings → Developer settings → Personal access tokens →
     Tokens (classic)
   - Click "Generate new token (classic)"
   - Select `repo` scope (Full control of private repositories)
   - Set appropriate expiration date
   - Click "Generate token" and copy the token securely

#### 🔵 Option B: Azure DevOps

1. **Create Personal Access Token**:
   - Navigate to Azure DevOps → User settings → Personal access tokens
   - Click "New Token"
   - Set name and expiration
   - Select `Code (Read)` scope
   - Click "Create" and copy the token securely

2. **Configure Azure DevOps CLI** (if using interactive setup):
   ```bash
   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT
   ```

### ▶️ Step 3: Run the Setup Script

#### 💻 Windows (PowerShell)

```powershell
# Basic deployment with GitHub
.\setUp.ps1 -EnvName "prod" -SourceControl "github"

# Basic deployment with Azure DevOps
.\setUp.ps1 -EnvName "prod" -SourceControl "adogit"

# Interactive mode (prompts for source control selection)
.\setUp.ps1 -EnvName "prod"

# Show help
.\setUp.ps1 -Help
```

#### 🐧 Linux/macOS (Bash)

```bash
# Make script executable
chmod +x setUp.sh

# Basic deployment with GitHub
./setUp.sh -e "prod" -s "github"

# Basic deployment with Azure DevOps
./setUp.sh -e "prod" -s "adogit"

# Interactive mode (prompts for source control selection)
./setUp.sh -e "prod"

# Show help
./setUp.sh -h
```

**📋 Script Parameters:**

| Parameter                      | Aliases | Required | Description                   | Valid Values                         |
| ------------------------------ | ------- | -------- | ----------------------------- | ------------------------------------ |
| EnvName / env-name             | -e      | Yes      | Name of the Azure environment | Any alphanumeric string (2-10 chars) |
| SourceControl / source-control | -s      | No\*     | Source control platform       | `github`, `adogit`                   |
| Help / help                    | -h      | No       | Display help message          | N/A                                  |

\*If not provided, the script will prompt for selection interactively.

> [!NOTE] The setup script performs multiple validations and configurations
> automatically. Review the actions below to understand what happens during
> execution.

**⚙️ Setup Script Actions:**

1. Validates required tools (az, azd, gh/Azure DevOps CLI)
2. Verifies Azure and source control authentication
3. Prompts for Personal Access Token (PAT) securely
4. Initializes Azure Developer CLI environment
5. Stores PAT securely in Key Vault
6. Configures environment variables in `.azure/{ENV_NAME}/.env`
7. Provisions Azure resources using Bicep templates
8. Configures role assignments and diagnostic settings

### ⚙️ Step 4: Configure Environment Settings

The solution uses YAML configuration files located in `settings/`. Customize
these files before deployment to match your organizational requirements.

#### 🏠 Resource Organization Configuration

**File**: `settings/resourceOrganization/azureResources.yaml`

This file defines the landing zone resource groups and their properties.

```yaml
security:
  name: 'security'
  create: true
  tags:
    component: 'security'
    environment: 'production'

monitoring:
  name: 'monitoring'
  create: true
  tags:
    component: 'monitoring'
    environment: 'production'

workload:
  name: 'workload'
  create: true
  tags:
    component: 'workload'
    environment: 'production'
```

**⚙️ Configuration Options:**

- `name`: Base name for the resource group (will be suffixed with environment
  and location)
- `create`: Boolean flag to create new resource group or use existing
- `tags`: Custom tags for cost allocation and governance

#### 🔐 Security Configuration

**File**: `settings/security/security.yaml`

This file configures Azure Key Vault settings and secret management.

```yaml
create: true
keyVault:
  name: 'keyvault'
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 90
  enableRbacAuthorization: true
  secretName: 'GitHubPAT'
```

**⚙️ Configuration Options:**

- `create`: Boolean flag to create new Key Vault or use existing
- `enablePurgeProtection`: Prevents permanent deletion during retention period
- `enableSoftDelete`: Enables soft delete with retention period
- `softDeleteRetentionInDays`: Number of days to retain soft-deleted items
  (7-90)
- `enableRbacAuthorization`: Use Azure RBAC instead of access policies
- `secretName`: Name of the secret to store the PAT

#### 🏭 DevCenter Configuration

**File**: `settings/workload/devcenter.yaml`

This file configures the DevCenter, catalogs, projects, pools, and network
settings.

```yaml
name: 'devcenter'
identity:
  type: 'SystemAssigned'
  roleAssignments:
    devCenter:
      - id: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
        name: 'Owner'
        scope: 'ResourceGroup'
    orgRoleTypes:
      - type: 'Group'
        azureADGroupId: 'YOUR_AZURE_AD_GROUP_OBJECT_ID'
        azureADGroupName: 'DevBox Administrators'
        azureRBACRoles:
          - id: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
            name: 'Owner'

catalogItemSyncEnableStatus: 'Enabled'
microsoftHostedNetworkEnableStatus: 'Enabled'
installAzureMonitorAgentEnableStatus: 'Enabled'

catalogs:
  - name: 'catalog-github'
    type: 'gitHub'
    visibility: 'private'
    uri: 'https://github.com/YOUR_ORG/YOUR_REPO'
    branch: 'main'
    path: '/environments'

environmentTypes:
  - name: 'dev'
  - name: 'test'
  - name: 'prod'

projects:
  - name: 'project-dev'
    description: 'Development Project'
    identity:
      type: 'SystemAssigned'
      roleAssignments:
        - azureADGroupId: 'YOUR_AZURE_AD_GROUP_OBJECT_ID'
          azureADGroupName: 'Developers'
          azureRBACRoles:
            - id: '45d50f46-0b78-4001-a660-4198cbe8cd05'
              name: 'DevCenter Dev Box User'
              scope: 'Project'
    catalogs:
      - name: 'catalog-github'
        type: 'imageDefinition'
        sourceControl: 'gitHub'
        visibility: 'private'
        uri: 'https://github.com/YOUR_ORG/YOUR_REPO'
        branch: 'main'
        path: '/images'
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: '/subscriptions/YOUR_SUBSCRIPTION_ID'
    pools:
      - name: 'pool-dev'
        imageDefinitionName: 'windows-11-enterprise'
        vmSku: 'general_i_8c32gb256ssd_v2'
    network:
      name: 'vnet-devcenter'
      virtualNetworkType: 'Managed'
      microsoftHostedNetworkEnableStatus: 'Enabled'
      create: false
      resourceGroupName: 'connectivity-ENV_NAME-LOCATION-RG'
      addressPrefixes:
        - '10.0.0.0/16'
      subnets:
        - name: 'subnet-devbox'
          addressPrefix: '10.0.0.0/24'
      tags:
        component: 'connectivity'
```

**📝 Key Configuration Sections:**

1. **DevCenter Identity**: Configures system-assigned managed identity and role
   assignments
2. **Catalogs**: Defines Git repositories for environment and image definitions
3. **Environment Types**: Lists available environment types (dev, test, prod)
4. **Projects**: Configures individual projects with identity, catalogs, pools,
   and networking
5. **Network**: Defines network configuration (Managed or Unmanaged)

### 🔧 Step 5: Provision Resources

The setup script automatically provisions resources, but you can manually
trigger provisioning:

```bash
# Provision all resources
azd provision -e prod

# Deploy only (assumes infrastructure exists)
azd deploy -e prod

# Full deployment (provision + deploy)
azd up -e prod
```

**🔄 Provisioning Process:**

1. **Validation Phase**:
   - Validates Bicep templates
   - Checks parameter values
   - Verifies subscription access

2. **Security Landing Zone**:
   - Creates security resource group
   - Deploys Azure Key Vault
   - Stores PAT as secret
   - Configures access policies

3. **Monitoring Landing Zone**:
   - Creates monitoring resource group
   - Deploys Log Analytics Workspace
   - Configures workspace solutions

4. **Workload Landing Zone**:
   - Creates workload resource group
   - Deploys DevCenter core
   - Configures catalogs
   - Creates environment types

5. **Project Provisioning**:
   - Creates DevCenter projects
   - Configures project catalogs
   - Creates environment types
   - Deploys DevBox pools

6. **Connectivity Landing Zone** (if unmanaged networking):
   - Creates connectivity resource group
   - Deploys virtual network
   - Creates subnets
   - Configures network connections

7. **RBAC Configuration**:
   - Assigns managed identity roles
   - Configures Azure AD group roles
   - Applies Key Vault access policies

8. **Diagnostic Settings**:
   - Links all resources to Log Analytics
   - Enables AllLogs category
   - Enables AllMetrics

### ✅ Step 6: Verify Deployment

#### 📁 Verify Resource Groups

```bash
# List all resource groups with tags
az group list --query "[?tags.component].{Name:name, Component:tags.component, Location:location}" -o table
```

**📊 Expected Output:**

```
Name                              Component      Location
security-prod-eastus2-RG         security       eastus2
monitoring-prod-eastus2-RG       monitoring     eastus2
workload-prod-eastus2-RG         workload       eastus2
connectivity-prod-eastus2-RG     connectivity   eastus2
```

#### 🏭 Verify DevCenter

```bash
# Show DevCenter details
az devcenter admin devcenter show \
  --name YOUR_DEVCENTER_NAME \
  --resource-group workload-prod-eastus2-RG
```

#### 📂 Verify Projects

```bash
# List all projects
az devcenter admin project list \
  --resource-group workload-prod-eastus2-RG \
  -o table
```

#### 📖 Verify Catalogs

```bash
# List catalogs for DevCenter
az devcenter admin catalog list \
  --dev-center-name YOUR_DEVCENTER_NAME \
  --resource-group workload-prod-eastus2-RG \
  -o table
```

#### 🔐 Verify Key Vault

```bash
# Show Key Vault details
az keyvault show \
  --name YOUR_KEYVAULT_NAME \
  --resource-group security-prod-eastus2-RG

# Verify secret exists (requires permissions)
az keyvault secret show \
  --name GitHubPAT \
  --vault-name YOUR_KEYVAULT_NAME
```

### 🔗 Step 7: Access DevCenter

1. **Navigate to Azure Portal**:
   - Go to [https://portal.azure.com](https://portal.azure.com)
   - Search for "DevCenter" or navigate to your resource group

2. **View DevCenter Resources**:
   - Select your DevCenter instance
   - Navigate to "Projects" to view deployed projects
   - Navigate to "Catalogs" to view synced repositories

3. **Developer Access**:
   - Users with `DevCenter Dev Box User` role can create Dev Boxes
   - Navigate to [https://devbox.microsoft.com](https://devbox.microsoft.com)
   - Select project and pool
   - Create and connect to Dev Box

### 📊 Step 8: Monitor Deployment

#### 📊 View Logs in Log Analytics

```bash
# Show Log Analytics Workspace details
az monitor log-analytics workspace show \
  --resource-group monitoring-prod-eastus2-RG \
  --workspace-name YOUR_WORKSPACE_NAME
```

#### 🔍 Query Deployment Logs

```bash
# Query DevCenter activity logs
az monitor log-analytics query \
  --workspace YOUR_WORKSPACE_ID \
  --analytics-query "AzureActivity | where OperationNameValue contains 'MICROSOFT.DEVCENTER' | project TimeGenerated, OperationNameValue, ActivityStatusValue, Caller" \
  --timespan P1D
```

#### 📈 Monitor Resource Metrics

```bash
# View DevCenter metrics
az monitor metrics list \
  --resource /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/workload-prod-eastus2-RG/providers/Microsoft.DevCenter/devcenters/YOUR_DEVCENTER_NAME \
  --metric-names "AvailableDevBoxes"
```

## Configuration Reference

### 🏠 Landing Zone Configuration

The solution organizes resources into four landing zones, each with a specific
purpose:

| Landing Zone     | Purpose                   | Resources                                     | Resource Group Pattern                   |
| ---------------- | ------------------------- | --------------------------------------------- | ---------------------------------------- |
| **Security**     | Secret and key management | Azure Key Vault, Secrets                      | `{name}-{environmentName}-{location}-RG` |
| **Monitoring**   | Observability and logging | Log Analytics Workspace, Solutions            | `{name}-{environmentName}-{location}-RG` |
| **Connectivity** | Network infrastructure    | Virtual Network, Subnets, Network Connections | `{name}-{environmentName}-{location}-RG` |
| **Workload**     | DevCenter resources       | DevCenter, Projects, Pools, Catalogs          | `{name}-{environmentName}-{location}-RG` |

### 📖 Catalog Configuration

Catalogs provide environment definitions and image definitions for Dev Boxes.
The solution supports two catalog types:

#### 🐙 GitHub Catalog

```yaml
catalogs:
  - name: 'catalog-github'
    type: 'gitHub'
    visibility: 'private'
    uri: 'https://github.com/YOUR_ORG/YOUR_REPO'
    branch: 'main'
    path: '/environments'
```

#### 🔵 Azure DevOps Catalog

```yaml
catalogs:
  - name: 'catalog-ado'
    type: 'adoGit'
    visibility: 'private'
    uri: 'https://dev.azure.com/YOUR_ORG/YOUR_PROJECT/_git/YOUR_REPO'
    branch: 'main'
    path: '/environments'
```

**⚙️ Configuration Options:**

- `name`: Unique identifier for the catalog
- `type`: Source control platform (`gitHub` or `adoGit`)
- `visibility`: `public` (no authentication) or `private` (requires PAT)
- `uri`: Full URL to the Git repository
- `branch`: Branch to sync from
- `path`: Path within the repository containing definitions

### 🌐 Network Configuration

The solution supports two networking models:

#### ☁️ Managed Networking (Microsoft-Hosted)

```yaml
network:
  virtualNetworkType: 'Managed'
  microsoftHostedNetworkEnableStatus: 'Enabled'
  create: false
```

**✨ Characteristics:**

- No customer-managed virtual network required
- Microsoft manages network infrastructure
- Simplified deployment and management
- Automatic Azure AD join for Dev Boxes

#### 🏢 Unmanaged Networking (Customer-Managed)

```yaml
network:
  name: 'vnet-devcenter'
  virtualNetworkType: 'Unmanaged'
  create: true
  resourceGroupName: 'connectivity-prod-eastus2-RG'
  addressPrefixes:
    - '10.0.0.0/16'
  subnets:
    - name: 'subnet-devbox'
      addressPrefix: '10.0.0.0/24'
  tags:
    component: 'connectivity'
```

**✨ Characteristics:**

- Customer-managed virtual network in dedicated resource group
- Full control over network topology and security
- Support for hybrid connectivity scenarios
- Custom DNS and routing configurations

### 🔐 Identity and RBAC Configuration

The solution implements multiple identity patterns for secure access:

#### 🏭 DevCenter Managed Identity

```yaml
identity:
  type: 'SystemAssigned'
  roleAssignments:
    devCenter:
      - id: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
        name: 'Owner'
        scope: 'ResourceGroup'
```

#### 📂 Project Managed Identity

```yaml
identity:
  type: 'SystemAssigned'
  roleAssignments:
    - azureADGroupId: 'YOUR_AZURE_AD_GROUP_OBJECT_ID'
      azureADGroupName: 'Developers'
      azureRBACRoles:
        - id: '45d50f46-0b78-4001-a660-4198cbe8cd05'
          name: 'DevCenter Dev Box User'
          scope: 'Project'
```

#### 🌍 Environment Type Identity

Each environment type automatically receives a system-assigned managed identity
with the following role:

- **Contributor** (`b24988ac-6180-42a0-ab88-20f7382dd24c`): Deployment target
  subscription access

### 💻 Pool Configuration

DevBox pools define the compute resources for development environments:

```yaml
pools:
  - name: 'pool-dev'
    imageDefinitionName: 'windows-11-enterprise'
    vmSku: 'general_i_8c32gb256ssd_v2'
```

**💻 Common VM SKUs:**

- `general_i_8c32gb256ssd_v2`: 8 vCPU, 32 GB RAM, 256 GB SSD
- `general_i_16c64gb512ssd_v2`: 16 vCPU, 64 GB RAM, 512 GB SSD
- `general_i_32c128gb1024ssd_v2`: 32 vCPU, 128 GB RAM, 1024 GB SSD

---

## 📦 Release Strategy

The Dev Box Landing Zone Accelerator uses a branch-based semantic release
strategy with intelligent version management. For complete details, see
[RELEASE_STRATEGY.md](RELEASE_STRATEGY.md).

### 📊 Version Strategy Summary

| Branch Pattern | Version Strategy              | Release Publication |
| -------------- | ----------------------------- | ------------------- |
| `main`         | Conditional major increment   | ✅ Published        |
| `feature/**`   | Patch increment with overflow | ❌ Not published    |
| `fix/**`       | Minor increment with overflow | ❌ Not published    |

### 🔢 Main Branch Versioning Logic

- **If `minor=0 AND patch=0`**: Increment major → `(major+1).0.0`
- **If `minor≠0 OR patch≠0`**: Increment patch → `major.minor.(patch+1)`
- **Overflow handling**: If `patch > 99` → `(minor+1).0`

---

## 🔧 Troubleshooting

> [!TIP] Most deployment issues can be resolved by verifying authentication and
> checking resource quotas. Review the common issues below for quick solutions.

### ⚠️ Common Issues

#### 🔑 Authentication Failures

**💥 Symptom**: Setup script fails with authentication errors

**✅ Resolution**:

1. Verify Azure CLI authentication:
   ```bash
   az account show
   az account list
   ```
2. Re-authenticate if necessary:
   ```bash
   az login
   az account set --subscription YOUR_SUBSCRIPTION_ID
   ```
3. For GitHub, verify GitHub CLI authentication:
   ```bash
   gh auth status
   gh auth login
   ```
4. For Azure DevOps, verify Azure DevOps CLI authentication and configuration

#### ⚠️ Quota Exceeded

**💥 Symptom**: Deployment fails with quota error

**✅ Resolution**:

1. Check DevCenter quota in target region:
   ```bash
   az devcenter admin usage list --location YOUR_LOCATION
   ```
2. Request quota increase via Azure Portal:
   - Navigate to Subscriptions → Usage + quotas
   - Search for "DevCenter"
   - Request increase for required resources

#### 🌐 Network Connection Failures

**💥 Symptom**: Network connection attachment fails during deployment

**✅ Resolution**:

1. Verify subnet exists and has available IP addresses:
   ```bash
   az network vnet subnet show \
     --resource-group connectivity-prod-eastus2-RG \
     --vnet-name YOUR_VNET_NAME \
     --name YOUR_SUBNET_NAME
   ```
2. Ensure subnet is not in use by other resources
3. Verify subnet delegation is not configured for other services
4. Check network security group rules for outbound connectivity

#### 🚫 Key Vault Access Denied

**💥 Symptom**: Unable to retrieve secrets from Key Vault

**✅ Resolution**:

1. Verify RBAC assignments:
   ```bash
   az role assignment list \
     --assignee YOUR_IDENTITY_OBJECT_ID \
     --scope /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/security-prod-eastus2-RG/providers/Microsoft.KeyVault/vaults/YOUR_KEYVAULT_NAME
   ```
2. Ensure managed identity has `Key Vault Secrets User` role
3. Verify Key Vault RBAC authorization is enabled:
   ```bash
   az keyvault show --name YOUR_KEYVAULT_NAME --query properties.enableRbacAuthorization
   ```

#### 🔄 Catalog Synchronization Failures

**💥 Symptom**: Catalog fails to sync or shows error status

**✅ Resolution**:

1. Verify PAT is valid and has correct permissions
2. Verify repository URL is correct and accessible
3. Verify branch and path exist in repository
4. Check catalog sync status:
   ```bash
   az devcenter admin catalog show \
     --dev-center-name YOUR_DEVCENTER_NAME \
     --resource-group workload-prod-eastus2-RG \
     --name YOUR_CATALOG_NAME
   ```
5. Trigger manual sync:
   ```bash
   az devcenter admin catalog sync \
     --dev-center-name YOUR_DEVCENTER_NAME \
     --resource-group workload-prod-eastus2-RG \
     --name YOUR_CATALOG_NAME
   ```

### 📝 Diagnostic Commands

#### 📜 View Deployment History

```bash
# List subscription-level deployments
az deployment sub list --query "[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}" -o table

# Show specific deployment details
az deployment sub show --name YOUR_DEPLOYMENT_NAME
```

#### 👤 View Role Assignments

```bash
# List all role assignments in subscription
az role assignment list \
  --scope /subscriptions/YOUR_SUBSCRIPTION_ID \
  --output table

# List role assignments for specific identity
az role assignment list \
  --assignee YOUR_IDENTITY_OBJECT_ID \
  --all
```

#### 🛠️ View Diagnostic Settings

```bash
# List diagnostic settings for a resource
az monitor diagnostic-settings list \
  --resource /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/workload-prod-eastus2-RG/providers/Microsoft.DevCenter/devcenters/YOUR_DEVCENTER_NAME
```

#### 📊 Query Log Analytics

```bash
# Query DevCenter activity logs
az monitor log-analytics query \
  --workspace YOUR_WORKSPACE_ID \
  --analytics-query "AzureDiagnostics | where ResourceProvider == 'MICROSOFT.DEVCENTER' | limit 100"

# Query diagnostic logs
az monitor log-analytics query \
  --workspace YOUR_WORKSPACE_ID \
  --analytics-query "AzureDiagnostics | where ResourceType == 'DEVCENTERS' | project TimeGenerated, OperationName, ResultType, Message"
```

---

## 🧹 Cleanup

To remove all deployed resources:

### Windows (PowerShell)

```powershell
.\cleanSetUp.ps1 -EnvName "prod" -Location "eastus2"
```

### Linux/macOS (Bash)

```bash
# Manual cleanup using azd
azd down -e prod --purge --force
```

> [!CAUTION] This operation is **irreversible** and will:
>
> - Delete all resource groups created by the deployment
> - Delete Key Vault secrets (with purge if purge protection is disabled)
> - Remove all RBAC role assignments
> - Delete diagnostic settings and monitoring data
> - Remove Azure Developer CLI environment configuration

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for
guidelines on:

- Code of conduct
- Development workflow
- Pull request process
- Coding standards and best practices
- Testing requirements

---

## 🔒 Security

For reporting security vulnerabilities, please review
[SECURITY.md](SECURITY.md).

> [!WARNING] **Security Best Practices:**
>
> - Never commit Personal Access Tokens or secrets to source control
> - Use Azure Key Vault for all sensitive data
> - Enable purge protection and soft delete for Key Vault
> - Implement least privilege RBAC assignments
> - Regularly review and rotate access credentials
> - Enable diagnostic logging for all resources
> - Monitor Log Analytics for suspicious activity

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for
details.

---

## 💬 Support

For issues, questions, or feature requests:

1. Check existing
   [GitHub Issues](https://github.com/Evilazaro/DevExp-DevBox/issues)
2. Search
   [closed issues](https://github.com/Evilazaro/DevExp-DevBox/issues?q=is%3Aissue+is%3Aclosed)
   for solutions
3. Create a new issue with detailed information:
   - Environment details (OS, tool versions)
   - Steps to reproduce
   - Error messages and logs
   - Expected vs actual behavior
4. Use appropriate labels:
   - `bug`: Something isn't working
   - `enhancement`: New feature or request
   - `question`: Further information requested
   - `documentation`: Documentation improvements

---

## 📚 Additional Resources

### 📘 Microsoft Documentation

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/azure/dev-box/)
- [Azure DevCenter Documentation](https://learn.microsoft.com/azure/dev-center/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure RBAC Documentation](https://learn.microsoft.com/azure/role-based-access-control/)
- [Azure Key Vault Documentation](https://learn.microsoft.com/azure/key-vault/)
- [Azure Monitor Documentation](https://learn.microsoft.com/azure/azure-monitor/)

### 🔗 Related Projects

- [Azure Landing Zones (Enterprise-Scale)](https://github.com/Azure/Enterprise-Scale)
- [Azure Verified Modules](https://github.com/Azure/bicep-registry-modules)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)

### 👥 Community Resources

- [Microsoft Dev Box Community](https://techcommunity.microsoft.com/t5/azure-dev-box/bd-p/AzureDevBox)
- [Azure DevCenter Community](https://techcommunity.microsoft.com/t5/azure-developer-community-blog/bg-p/AzureDevCommunityBlog)
- [Bicep Community](https://github.com/Azure/bicep/discussions)

---

## 📎 Related Documents

| Document                                   | Description                                      |
| :----------------------------------------- | :----------------------------------------------- |
| [RELEASE_STRATEGY.md](RELEASE_STRATEGY.md) | Branch-based versioning and release workflow     |
| [CONTRIBUTING.md](CONTRIBUTING.md)         | Contribution guidelines and development workflow |
| [SECURITY.md](SECURITY.md)                 | Security policies and vulnerability reporting    |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)   | Community guidelines and standards               |
| [LICENSE](LICENSE)                         | MIT License details                              |

---

<div align="center">

**🚀 Dev Box Landing Zone Accelerator**

Maintained by: **DevExp Team**<br> Repository:
[Evilazaro/DevExp-DevBox](https://github.com/Evilazaro/DevExp-DevBox)<br> Last
Updated: 2024

[⬆️ Back to Top](#-dev-box-landing-zone-accelerator) ·
[📦 Release Strategy](RELEASE_STRATEGY.md) · [🤝 Contributing](CONTRIBUTING.md)

</div>
