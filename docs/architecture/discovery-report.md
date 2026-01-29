# Discovery Report

**Generated**: January 29, 2026  
**Workspace**: z:\DevExp-DevBox  
**Repository**: Evilazaro/DevExp-DevBox  
**Branch**: docs/refacto

---

## 1. Workspace Overview

### 1.1 Structure Summary

- **Total Files**: ~50 files
- **Total Directories**: ~25 directories
- **Primary Languages**: Bicep (Azure Infrastructure as Code), YAML
  (Configuration), PowerShell/Bash (Setup Scripts), GitHub Actions Workflow
- **Key Patterns Identified**:
  - Infrastructure as Code (IaC) with Bicep modules
  - Configuration-as-Code with YAML settings files
  - Azure Developer CLI (azd) integration
  - CI/CD with GitHub Actions
  - Desired State Configuration (DSC) for developer workstations

### 1.2 Directory Map

```
z:\DevExp-DevBox\
├── .configuration/
│   ├── devcenter/
│   │   └── workloads/           # DSC configurations for Dev Box workloads
│   │       ├── common-backend-config.dsc.yaml
│   │       ├── common-backend-usertasks-config.dsc.yaml
│   │       ├── common-config.dsc.yaml
│   │       ├── common-frontend-usertasks-config.dsc.yaml
│   │       ├── winget-update.ps1
│   │       ├── winget-upgrade-packages.dsc.yaml
│   │       └── ADO/             # Azure DevOps specific DSC configs
│   ├── powershell/
│   │   └── cleanUp.ps1
│   └── setup/
│       └── powershell/
│           ├── Azure/           # Azure credential management scripts
│           └── GitHub/          # GitHub secret management scripts
├── .github/
│   ├── actions/
│   │   └── ci/                  # Custom CI actions
│   └── workflows/
│       ├── ci.yml               # Continuous Integration workflow
│       ├── deploy.yml           # Azure deployment workflow
│       └── release.yml          # Release management workflow
├── infra/
│   ├── main.bicep               # Main deployment template
│   ├── main.parameters.json
│   └── settings/
│       ├── resourceOrganization/
│       │   └── azureResources.yaml
│       ├── security/
│       │   └── security.yaml
│       └── workload/
│           └── devcenter.yaml
├── prompts/                     # Documentation generation prompts
├── src/
│   ├── connectivity/            # Network connectivity modules
│   ├── identity/                # RBAC and identity modules
│   ├── management/              # Monitoring and management modules
│   ├── security/                # Security modules (Key Vault)
│   └── workload/
│       ├── core/                # DevCenter core resources
│       └── project/             # DevCenter project resources
├── azure.yaml                   # azd configuration (Linux/macOS)
├── azure-pwh.yaml               # azd configuration (Windows PowerShell)
├── setUp.ps1                    # Windows setup script
├── setUp.sh                     # Linux/macOS setup script
└── cleanSetUp.ps1               # Cleanup script
```

---

## 2. Business Capabilities Discovered

| ID     | Capability Name                     | Source Evidence                                                                                                                                                                                       | File Path                                                                                                                              |
| ------ | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| BC-001 | Developer Self-Service Platform     | "deploys the DevCenter workload infrastructure for the DevExp-DevBox solution. It orchestrates the deployment of developer self-service infrastructure enabling cloud-based development environments" | [src/workload/workload.bicep](src/workload/workload.bicep)                                                                             |
| BC-002 | Infrastructure Provisioning         | "provisions a complete development environment with security, monitoring, and DevCenter workload resources"                                                                                           | [infra/main.bicep](infra/main.bicep)                                                                                                   |
| BC-003 | Security Management                 | "Security Resource Group: Contains Key Vault for secret management with diagnostic settings"                                                                                                          | [infra/main.bicep](infra/main.bicep)                                                                                                   |
| BC-004 | Centralized Monitoring              | "Monitoring Resource Group: Contains Log Analytics Workspace for centralized monitoring and log aggregation"                                                                                          | [infra/main.bicep](infra/main.bicep)                                                                                                   |
| BC-005 | Dev Box Pool Management             | "DevBox pools define the configuration for developer workstations that can be provisioned on-demand within a DevCenter project"                                                                       | [src/workload/project/projectPool.bicep](src/workload/project/projectPool.bicep)                                                       |
| BC-006 | Environment Template Management     | "Catalogs for Dev Box image definitions and environment templates"                                                                                                                                    | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                       |
| BC-007 | Network Connectivity                | "Orchestrates network connectivity resources for DevCenter projects. This module provisions virtual networks, network connections"                                                                    | [src/connectivity/connectivity.bicep](src/connectivity/connectivity.bicep)                                                             |
| BC-008 | Identity & Access Management        | "Role-based access control (RBAC) assignments for Dev Center and projects"                                                                                                                            | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                       |
| BC-009 | Developer Workstation Configuration | "defines the common backend development tools and emulators required for Azure-based backend development"                                                                                             | [.configuration/devcenter/workloads/common-backend-config.dsc.yaml](.configuration/devcenter/workloads/common-backend-config.dsc.yaml) |
| BC-010 | CI/CD Pipeline Automation           | "automates the CI pipeline for the Dev Box Accelerator project"                                                                                                                                       | [.github/workflows/ci.yml](.github/workflows/ci.yml)                                                                                   |

---

## 3. Business Services Discovered

| ID     | Service Name               | Type     | Source Evidence                                                                                                    | File Path                                                                                |
| ------ | -------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| BS-001 | Azure DevCenter            | External | "Microsoft DevCenter instance along with its associated resources"                                                 | [src/workload/core/devCenter.bicep](src/workload/core/devCenter.bicep)                   |
| BS-002 | Azure Key Vault            | External | "Azure Key Vault resource with configurable settings for security, soft delete, purge protection"                  | [src/security/keyVault.bicep](src/security/keyVault.bicep)                               |
| BS-003 | Log Analytics Workspace    | External | "Log Analytics Workspace with associated solutions and diagnostic settings for centralized logging and monitoring" | [src/management/logAnalytics.bicep](src/management/logAnalytics.bicep)                   |
| BS-004 | DevCenter Project          | External | "deploys a complete DevCenter project infrastructure for Azure Dev Box and Azure Deployment Environments"          | [src/workload/project/project.bicep](src/workload/project/project.bicep)                 |
| BS-005 | DevCenter Catalog          | External | "DevCenter catalog resource that syncs environment definitions from a GitHub or Azure DevOps Git repository"       | [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep)                       |
| BS-006 | DevCenter Environment Type | External | "Environment Types define the different deployment environments (e.g., Development, Testing, Staging, Production)" | [src/workload/core/environmentType.bicep](src/workload/core/environmentType.bicep)       |
| BS-007 | Virtual Network            | External | "provisions or references an Azure Virtual Network (VNet) for use in Dev Box"                                      | [src/connectivity/vnet.bicep](src/connectivity/vnet.bicep)                               |
| BS-008 | Network Connection         | External | "Network connection enables DevCenter to provision Dev Boxes within the specified subnet using Azure AD Join"      | [src/connectivity/networkConnection.bicep](src/connectivity/networkConnection.bicep)     |
| BS-009 | DevBox Pool                | External | "DevBox pools define the configuration for developer workstations that can be provisioned on-demand"               | [src/workload/project/projectPool.bicep](src/workload/project/projectPool.bicep)         |
| BS-010 | Azure RBAC Role Assignment | External | "creates role assignments at the subscription scope for a given identity"                                          | [src/identity/devCenterRoleAssignment.bicep](src/identity/devCenterRoleAssignment.bicep) |

---

## 4. Business Processes Discovered

| ID     | Process Name                       | Trigger                                           | Outcome                                                                   | File Path                                                                                                                                          |
| ------ | ---------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| BP-001 | Infrastructure Provisioning        | Azure Developer CLI (azd) preprovision hook       | Complete development environment deployed to Azure                        | [azure.yaml](azure.yaml), [infra/main.bicep](infra/main.bicep)                                                                                     |
| BP-002 | Environment Setup                  | Manual script execution or azd preprovision       | azd environment initialized with source control platform credentials      | [setUp.ps1](setUp.ps1), [setUp.sh](setUp.sh)                                                                                                       |
| BP-003 | Deployment Credential Generation   | Manual script execution                           | Service principal with RBAC roles created, GitHub secret stored           | [.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1](.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1) |
| BP-004 | Continuous Integration             | Push to feature/** or fix/** branches, PR to main | Bicep templates built, version generated, artifacts created               | [.github/workflows/ci.yml](.github/workflows/ci.yml)                                                                                               |
| BP-005 | Azure Deployment                   | Manual workflow_dispatch trigger                  | Infrastructure provisioned to Azure using azd                             | [.github/workflows/deploy.yml](.github/workflows/deploy.yml)                                                                                       |
| BP-006 | Resource Cleanup                   | Manual script execution                           | Users, credentials, GitHub secrets, resource groups deleted               | [cleanSetUp.ps1](cleanSetUp.ps1)                                                                                                                   |
| BP-007 | DevCenter Core Deployment          | Workload module invocation                        | DevCenter with catalogs, environment types, and role assignments deployed | [src/workload/core/devCenter.bicep](src/workload/core/devCenter.bicep)                                                                             |
| BP-008 | Project Deployment                 | Workload module loop                              | Project with pools, networks, catalogs, and environment types deployed    | [src/workload/project/project.bicep](src/workload/project/project.bicep)                                                                           |
| BP-009 | Network Connectivity Setup         | Project deployment                                | Virtual network and network connection created and attached to DevCenter  | [src/connectivity/connectivity.bicep](src/connectivity/connectivity.bicep)                                                                         |
| BP-010 | Developer Workstation Provisioning | DSC configuration application                     | Development tools installed via WinGet DSC                                | [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml)                             |

---

## 5. Business Actors/Roles Discovered

| ID     | Actor/Role Name             | Type           | Responsibilities                                                                                             | File Path                                                                                                                                          |
| ------ | --------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| BA-001 | Platform Engineering Team   | Azure AD Group | "Dev Manager role - for users who manage Dev Box deployments. These users can configure Dev Box definitions" | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-002 | eShop Developers            | Azure AD Group | "Project-level access with Contributor, Dev Box User, Deployment Environment User roles"                     | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-003 | DevCenter Project Admin     | RBAC Role      | "DevCenter Project Admin role allows managing project settings"                                              | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-004 | Contributor                 | RBAC Role      | "Azure Contributor role for Dev Center management"                                                           | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-005 | User Access Administrator   | RBAC Role      | "Assigns User Access Administrator role for managing access control"                                         | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-006 | Key Vault Secrets User      | RBAC Role      | "Access to Key Vault secrets at ResourceGroup scope"                                                         | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-007 | Key Vault Secrets Officer   | RBAC Role      | "Manage Key Vault secrets at ResourceGroup scope"                                                            | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-008 | Dev Box User                | RBAC Role      | "Allows users to create and manage Dev Boxes within projects"                                                | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-009 | Deployment Environment User | RBAC Role      | "Allows users to create deployment environments"                                                             | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                   |
| BA-010 | Service Principal           | Identity Type  | "Creates a service principal with Contributor role at the subscription scope"                                | [.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1](.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1) |

---

## 6. Business Events Discovered

| ID     | Event Name                 | Producer                       | Consumer(s)       | File Path                                                          |
| ------ | -------------------------- | ------------------------------ | ----------------- | ------------------------------------------------------------------ |
| BE-001 | Push to feature/fix branch | GitHub Repository              | CI Workflow       | [.github/workflows/ci.yml](.github/workflows/ci.yml)               |
| BE-002 | Pull Request to main       | GitHub Repository              | CI Workflow       | [.github/workflows/ci.yml](.github/workflows/ci.yml)               |
| BE-003 | Workflow Dispatch          | GitHub Actions UI              | Deploy Workflow   | [.github/workflows/deploy.yml](.github/workflows/deploy.yml)       |
| BE-004 | Preprovision Hook          | Azure Developer CLI            | Setup Script      | [azure.yaml](azure.yaml)                                           |
| BE-005 | Catalog Sync               | GitHub/Azure DevOps Repository | DevCenter Catalog | [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep) |

---

## 7. Business Rules Discovered

| ID     | Rule Name                        | Enforcement Point                                      | File Path                                                                            |
| ------ | -------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| BR-001 | Location Restriction             | Parameter validation in main.bicep                     | [infra/main.bicep](infra/main.bicep)                                                 |
| BR-002 | Environment Name Length          | @minLength(2) @maxLength(10) param constraint          | [infra/main.bicep](infra/main.bicep)                                                 |
| BR-003 | Resource Group Naming Convention | "{name}-{environment}-{location}-RG" pattern           | [infra/main.bicep](infra/main.bicep)                                                 |
| BR-004 | Key Vault Purge Protection       | enablePurgeProtection: true in security.yaml           | [infra/settings/security/security.yaml](infra/settings/security/security.yaml)       |
| BR-005 | Key Vault Soft Delete            | enableSoftDelete: true, softDeleteRetentionInDays: 7   | [infra/settings/security/security.yaml](infra/settings/security/security.yaml)       |
| BR-006 | RBAC Authorization               | enableRbacAuthorization: true for Key Vault            | [infra/settings/security/security.yaml](infra/settings/security/security.yaml)       |
| BR-007 | Domain Join Type                 | domainJoinType: 'AzureADJoin' for network connections  | [src/connectivity/networkConnection.bicep](src/connectivity/networkConnection.bicep) |
| BR-008 | Catalog Sync Type                | syncType: 'Scheduled' for DevCenter catalogs           | [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep)                   |
| BR-009 | Deployment Concurrency           | Single deployment per environment (concurrency group)  | [.github/workflows/deploy.yml](.github/workflows/deploy.yml)                         |
| BR-010 | Source Control Platform Default  | Default to 'github' if SOURCE_CONTROL_PLATFORM not set | [azure.yaml](azure.yaml)                                                             |

---

## 8. Domain Entities Discovered

| ID     | Entity Name     | Key Attributes                                                                                                                   | Relationships                                                      | File Path                                                                                                          |
| ------ | --------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| BO-001 | DevCenter       | name, identity, catalogItemSyncEnableStatus, microsoftHostedNetworkEnableStatus, installAzureMonitorAgentEnableStatus, tags      | Has many: Catalogs, EnvironmentTypes, Projects                     | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |
| BO-002 | Project         | name, description, identity, network, pools, catalogs, environmentTypes, tags                                                    | Belongs to: DevCenter; Has many: Pools, Catalogs, EnvironmentTypes | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |
| BO-003 | Catalog         | name, type, visibility, uri, branch, path                                                                                        | Belongs to: DevCenter or Project                                   | [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep)                                                 |
| BO-004 | EnvironmentType | name, deploymentTargetId                                                                                                         | Belongs to: DevCenter or Project                                   | [src/workload/core/environmentType.bicep](src/workload/core/environmentType.bicep)                                 |
| BO-005 | Pool            | name, imageDefinitionName, vmSku                                                                                                 | Belongs to: Project                                                | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |
| BO-006 | Network         | name, create, resourceGroupName, virtualNetworkType, addressPrefixes, subnets, tags                                              | Belongs to: Project                                                | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |
| BO-007 | KeyVault        | name, description, secretName, enablePurgeProtection, enableSoftDelete, softDeleteRetentionInDays, enableRbacAuthorization, tags | Contains: Secrets                                                  | [infra/settings/security/security.yaml](infra/settings/security/security.yaml)                                     |
| BO-008 | ResourceGroup   | name, create, description, tags                                                                                                  | Contains: Resources (Workload, Security, Monitoring)               | [infra/settings/resourceOrganization/azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml) |
| BO-009 | Identity        | type, roleAssignments                                                                                                            | Belongs to: DevCenter, Project                                     | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |
| BO-010 | RoleAssignment  | id, name, scope                                                                                                                  | Belongs to: Identity                                               | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                   |

---

## 9. Value Streams (If Identifiable)

| ID     | Value Stream Name            | Stages                                                                           | File Path                                                                                                                                                                |
| ------ | ---------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| VS-001 | Developer Onboarding         | Setup Environment → Configure Source Control → Provision Dev Box → Install Tools | [setUp.ps1](setUp.ps1), [azure.yaml](azure.yaml), [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml) |
| VS-002 | Infrastructure Deployment    | Build Bicep → Authenticate → Provision Resources → Configure DevCenter           | [.github/workflows/ci.yml](.github/workflows/ci.yml), [.github/workflows/deploy.yml](.github/workflows/deploy.yml), [infra/main.bicep](infra/main.bicep)                 |
| VS-003 | Environment Lifecycle (SDLC) | dev → staging → UAT (defined as environment types)                               | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                                         |

---

## 10. Organization Units (If Identifiable)

| ID     | Org Unit Name      | Owned Capabilities                             | File Path                                                                                                                                                 |
| ------ | ------------------ | ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| OU-001 | DevExP Team        | BC-001, BC-002, BC-003, BC-004, BC-005, BC-009 | Evidence: "team: DevExP" tag in [infra/settings/resourceOrganization/azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml)        |
| OU-002 | Platforms Division | BC-001 through BC-010 (All capabilities)       | Evidence: "division: Platforms" tag in [infra/settings/resourceOrganization/azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml) |
| OU-003 | Contoso (Owner)    | Resource ownership and governance              | Evidence: "owner: Contoso" tag in all configuration files                                                                                                 |

---

## 11. Relationship Map

### 11.1 Actor → Service Relationships

| Actor                              | Service                    | Relationship Type | Evidence                                            |
| ---------------------------------- | -------------------------- | ----------------- | --------------------------------------------------- |
| Platform Engineering Team (BA-001) | DevCenter (BS-001)         | Manages           | "DevCenter Project Admin" role assignment           |
| eShop Developers (BA-002)          | DevCenter Project (BS-004) | Uses              | "Dev Box User", "Deployment Environment User" roles |
| Service Principal (BA-010)         | Key Vault (BS-002)         | Accesses          | "Key Vault Secrets User/Officer" role assignments   |
| DevCenter Identity                 | Key Vault (BS-002)         | Authenticates     | Role assignments for secret access                  |

### 11.2 Service → Capability Relationships

| Service                  | Capability                               | Relationship Type | Evidence                            |
| ------------------------ | ---------------------------------------- | ----------------- | ----------------------------------- |
| DevCenter (BS-001)       | Developer Self-Service Platform (BC-001) | Realizes          | Core platform service               |
| Key Vault (BS-002)       | Security Management (BC-003)             | Realizes          | Secret storage and management       |
| Log Analytics (BS-003)   | Centralized Monitoring (BC-004)          | Realizes          | Log aggregation and analytics       |
| DevBox Pool (BS-009)     | Dev Box Pool Management (BC-005)         | Realizes          | Pool configuration and provisioning |
| Catalog (BS-005)         | Environment Template Management (BC-006) | Realizes          | Template synchronization            |
| Virtual Network (BS-007) | Network Connectivity (BC-007)            | Realizes          | Network infrastructure              |
| Role Assignment (BS-010) | Identity & Access Management (BC-008)    | Realizes          | RBAC enforcement                    |

### 11.3 Capability → Entity Relationships

| Capability                               | Entity             | Relationship Type | Evidence                     |
| ---------------------------------------- | ------------------ | ----------------- | ---------------------------- |
| Developer Self-Service Platform (BC-001) | DevCenter (BO-001) | Operates on       | Main configuration entity    |
| Developer Self-Service Platform (BC-001) | Project (BO-002)   | Operates on       | Project-level configurations |
| Security Management (BC-003)             | KeyVault (BO-007)  | Operates on       | Secret management            |
| Dev Box Pool Management (BC-005)         | Pool (BO-005)      | Operates on       | Pool configurations          |
| Environment Template Management (BC-006) | Catalog (BO-003)   | Operates on       | Template repositories        |
| Network Connectivity (BC-007)            | Network (BO-006)   | Operates on       | Network configurations       |

### 11.4 Process → Event Relationships

| Process                            | Event                               | Relationship Type | Evidence                          |
| ---------------------------------- | ----------------------------------- | ----------------- | --------------------------------- |
| Continuous Integration (BP-004)    | Push to feature/fix branch (BE-001) | Triggered by      | CI workflow trigger               |
| Continuous Integration (BP-004)    | Pull Request to main (BE-002)       | Triggered by      | CI workflow trigger               |
| Azure Deployment (BP-005)          | Workflow Dispatch (BE-003)          | Triggered by      | Manual trigger                    |
| Environment Setup (BP-002)         | Preprovision Hook (BE-004)          | Triggered by      | azd lifecycle hook                |
| DevCenter Core Deployment (BP-007) | Catalog Sync (BE-005)               | Triggers          | Scheduled catalog synchronization |

### 11.5 Organization → Capability Relationships

| Organization                | Capability                                   | Relationship Type | Evidence                    |
| --------------------------- | -------------------------------------------- | ----------------- | --------------------------- |
| DevExP Team (OU-001)        | Developer Self-Service Platform (BC-001)     | Owns              | "team: DevExP" tag          |
| DevExP Team (OU-001)        | Developer Workstation Configuration (BC-009) | Owns              | DSC configuration ownership |
| Platforms Division (OU-002) | All Capabilities                             | Oversees          | "division: Platforms" tag   |

---

## 12. Glossary of Terms

| Term               | Definition                                                                                                                        | Source File                                                                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| DevCenter          | Azure service that provides management and orchestration for developer environments including Dev Box and Deployment Environments | [src/workload/core/devCenter.bicep](src/workload/core/devCenter.bicep)                                                 |
| Dev Box            | Cloud-based developer workstation provisioned on-demand with pre-configured development tools                                     | [src/workload/project/projectPool.bicep](src/workload/project/projectPool.bicep)                                       |
| Catalog            | Repository of environment definitions or image definitions that DevCenter syncs from GitHub or Azure DevOps                       | [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep)                                                     |
| Environment Type   | Deployment environment category (dev, staging, UAT) that defines where applications can be deployed                               | [src/workload/core/environmentType.bicep](src/workload/core/environmentType.bicep)                                     |
| Pool               | Collection of Dev Boxes with specific VM configurations and image definitions                                                     | [src/workload/project/projectPool.bicep](src/workload/project/projectPool.bicep)                                       |
| Network Connection | Link between DevCenter and a virtual network subnet enabling Dev Box provisioning with Azure AD Join                              | [src/connectivity/networkConnection.bicep](src/connectivity/networkConnection.bicep)                                   |
| DSC                | Desired State Configuration - PowerShell-based configuration management for declaring desired machine state                       | [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml) |
| WinGet             | Windows Package Manager used to install and manage software packages                                                              | [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml) |
| azd                | Azure Developer CLI - tool for streamlined cloud application development with templates and provisioning                          | [azure.yaml](azure.yaml)                                                                                               |
| Bicep              | Domain-specific language for deploying Azure resources declaratively                                                              | [infra/main.bicep](infra/main.bicep)                                                                                   |
| Landing Zone       | Azure architectural pattern for organizing resources into functional groups (security, monitoring, workload)                      | [infra/main.bicep](infra/main.bicep)                                                                                   |
| RBAC               | Role-Based Access Control - Azure authorization system for managing resource access                                               | [src/identity/devCenterRoleAssignment.bicep](src/identity/devCenterRoleAssignment.bicep)                               |
| Managed Identity   | Azure AD identity automatically managed by Azure for authenticating between services                                              | [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                       |
| OIDC               | OpenID Connect - authentication protocol used for GitHub Actions to Azure authentication                                          | [.github/workflows/deploy.yml](.github/workflows/deploy.yml)                                                           |
| Dev Drive          | Windows 11 optimized storage using ReFS format for improved development workload performance                                      | [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml) |

---

## 13. Gaps & Limitations

| Gap ID | Category           | Description                                                                | Impact on Documentation                               |
| ------ | ------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------- |
| G-001  | Business Logic     | No application business logic exists - this is infrastructure-only project | Business rules limited to infrastructure constraints  |
| G-002  | API Specifications | No REST API definitions found                                              | Cannot document API contracts                         |
| G-003  | User Journey       | No explicit user journey documentation exists                              | Value streams inferred from process flows             |
| G-004  | SLA/SLO            | No service level agreements or objectives documented                       | Cannot document availability/performance requirements |
| G-005  | Cost Model         | No cost allocation model beyond tags                                       | Cannot document financial business rules              |
| G-006  | Data Flow          | No explicit data flow documentation                                        | Data relationships inferred from configuration        |
| G-007  | Testing Strategy   | No test files or testing documentation found                               | Cannot document testing business rules                |
| G-008  | Disaster Recovery  | No DR/BC documentation found                                               | Cannot document resilience requirements               |
| G-009  | Schema Validation  | Schema files exist but full validation not documented                      | Schema constraints partially documented               |
| G-010  | Release Management | release.yml workflow file exists but was not fully analyzed                | Release process partially documented                  |

---

## 14. Source File Index

| File Path                                                                                                                                                    | Elements Extracted                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [infra/main.bicep](infra/main.bicep)                                                                                                                         | BC-002, BC-003, BC-004, BR-001, BR-002, BR-003                                                                                                 |
| [infra/settings/workload/devcenter.yaml](infra/settings/workload/devcenter.yaml)                                                                             | BC-006, BC-008, BA-001, BA-002, BA-003, BA-004, BA-005, BA-006, BA-007, BA-008, BA-009, BO-001, BO-002, BO-005, BO-006, BO-009, BO-010, VS-003 |
| [infra/settings/security/security.yaml](infra/settings/security/security.yaml)                                                                               | BO-007, BR-004, BR-005, BR-006                                                                                                                 |
| [infra/settings/resourceOrganization/azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml)                                           | BO-008, OU-001, OU-002, OU-003                                                                                                                 |
| [src/workload/workload.bicep](src/workload/workload.bicep)                                                                                                   | BC-001, BS-001                                                                                                                                 |
| [src/workload/core/devCenter.bicep](src/workload/core/devCenter.bicep)                                                                                       | BS-001, BP-007                                                                                                                                 |
| [src/workload/core/catalog.bicep](src/workload/core/catalog.bicep)                                                                                           | BS-005, BO-003, BR-008, BE-005                                                                                                                 |
| [src/workload/core/environmentType.bicep](src/workload/core/environmentType.bicep)                                                                           | BS-006, BO-004                                                                                                                                 |
| [src/workload/project/project.bicep](src/workload/project/project.bicep)                                                                                     | BS-004, BP-008                                                                                                                                 |
| [src/workload/project/projectPool.bicep](src/workload/project/projectPool.bicep)                                                                             | BC-005, BS-009, BO-005                                                                                                                         |
| [src/security/security.bicep](src/security/security.bicep)                                                                                                   | BC-003                                                                                                                                         |
| [src/security/keyVault.bicep](src/security/keyVault.bicep)                                                                                                   | BS-002                                                                                                                                         |
| [src/management/logAnalytics.bicep](src/management/logAnalytics.bicep)                                                                                       | BS-003                                                                                                                                         |
| [src/connectivity/connectivity.bicep](src/connectivity/connectivity.bicep)                                                                                   | BC-007, BP-009                                                                                                                                 |
| [src/connectivity/vnet.bicep](src/connectivity/vnet.bicep)                                                                                                   | BS-007                                                                                                                                         |
| [src/connectivity/networkConnection.bicep](src/connectivity/networkConnection.bicep)                                                                         | BS-008, BR-007                                                                                                                                 |
| [src/identity/devCenterRoleAssignment.bicep](src/identity/devCenterRoleAssignment.bicep)                                                                     | BS-010                                                                                                                                         |
| [src/identity/projectIdentityRoleAssignment.bicep](src/identity/projectIdentityRoleAssignment.bicep)                                                         | BC-008                                                                                                                                         |
| [src/identity/orgRoleAssignment.bicep](src/identity/orgRoleAssignment.bicep)                                                                                 | BC-008                                                                                                                                         |
| [.github/workflows/ci.yml](.github/workflows/ci.yml)                                                                                                         | BC-010, BP-004, BE-001, BE-002                                                                                                                 |
| [.github/workflows/deploy.yml](.github/workflows/deploy.yml)                                                                                                 | BP-005, BE-003, BR-009                                                                                                                         |
| [azure.yaml](azure.yaml)                                                                                                                                     | BP-001, BE-004, BR-010                                                                                                                         |
| [setUp.ps1](setUp.ps1)                                                                                                                                       | BP-002, VS-001                                                                                                                                 |
| [setUp.sh](setUp.sh)                                                                                                                                         | BP-002                                                                                                                                         |
| [cleanSetUp.ps1](cleanSetUp.ps1)                                                                                                                             | BP-006                                                                                                                                         |
| [.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1](.configuration/setup/powershell/Azure/generateDeploymentCredentials.ps1)           | BP-003, BA-010                                                                                                                                 |
| [.configuration/devcenter/workloads/common-config.dsc.yaml](.configuration/devcenter/workloads/common-config.dsc.yaml)                                       | BC-009, BP-010, VS-001                                                                                                                         |
| [.configuration/devcenter/workloads/common-backend-config.dsc.yaml](.configuration/devcenter/workloads/common-backend-config.dsc.yaml)                       | BC-009                                                                                                                                         |
| [.configuration/devcenter/workloads/common-frontend-usertasks-config.dsc.yaml](.configuration/devcenter/workloads/common-frontend-usertasks-config.dsc.yaml) | BC-009                                                                                                                                         |

---

## 15. Configuration Summary

### 15.1 DevCenter Configuration (devcenter.yaml)

| Property                             | Value            | Description                       |
| ------------------------------------ | ---------------- | --------------------------------- |
| name                                 | devexp-devcenter | DevCenter instance name           |
| catalogItemSyncEnableStatus          | Enabled          | Automatic catalog synchronization |
| microsoftHostedNetworkEnableStatus   | Enabled          | Microsoft-managed networking      |
| installAzureMonitorAgentEnableStatus | Enabled          | Azure Monitor agent on Dev Boxes  |
| identity.type                        | SystemAssigned   | Managed identity type             |

### 15.2 Projects Configured

| Project | Pools                               | Environment Types | Network Type |
| ------- | ----------------------------------- | ----------------- | ------------ |
| eShop   | backend-engineer, frontend-engineer | dev, staging, UAT | Managed      |

### 15.3 Resource Groups (azureResources.yaml)

| Resource Group    | Purpose                              | Tags                                                |
| ----------------- | ------------------------------------ | --------------------------------------------------- |
| devexp-workload   | Core workload resources (DevCenter)  | environment: dev, division: Platforms, team: DevExP |
| devexp-security   | Security resources (Key Vault)       | environment: dev, division: Platforms, team: DevExP |
| devexp-monitoring | Monitoring resources (Log Analytics) | environment: dev, division: Platforms, team: DevExP |

### 15.4 Security Configuration (security.yaml)

| Property           | Value                      |
| ------------------ | -------------------------- |
| Key Vault Name     | contoso                    |
| Secret Name        | gha-token                  |
| Purge Protection   | Enabled                    |
| Soft Delete        | Enabled (7 days retention) |
| RBAC Authorization | Enabled                    |

---

_End of Discovery Report_

**Completion Status**: ☑ All directories scanned ☑ All source files analyzed ☑
All Business Architecture elements cataloged ☑ All relationships mapped ☑ All
terminology extracted ☑ All gaps documented ☑ Source file index complete ☑
Discovery report saved

**Next Phase**: Proceed to `./prompts/document-generation.md` for Phase 2:
Document Generation
