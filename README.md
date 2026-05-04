# DevExp-DevBox

![Build status badge showing static placeholder](https://img.shields.io/badge/build-passing-brightgreen)
![License badge showing MIT](https://img.shields.io/badge/license-MIT-blue)
![Version badge showing 1.0.0](https://img.shields.io/badge/version-1.0.0-orange)
![Coverage badge showing placeholder](https://img.shields.io/badge/coverage-N%2FA-lightgrey)

> [!NOTE] Replace the badge URLs above with actual CI/CD pipeline and coverage
> service endpoints once configured.

**DevExp-DevBox** is an Azure Dev Box accelerator that automates the
provisioning and configuration of Microsoft Dev Box environments using
infrastructure-as-code principles, enabling development teams to rapidly deploy
standardized, role-specific developer workstations.

This project solves the challenge of consistently provisioning secure, governed
developer environments at scale by codifying **Azure Dev Center** resources,
network connectivity, security controls, and monitoring into a repeatable,
version-controlled deployment pipeline.

The accelerator leverages **Bicep** for infrastructure-as-code, **YAML** for
declarative configuration, **Azure Developer CLI** (azd) for orchestration, and
**PowerShell**/Bash scripts for cross-platform automation.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

| Feature                      | Description                                                                                                                              |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 🏗️ Infrastructure-as-Code    | Deploy all Dev Box resources using **Bicep** modules with subscription-scoped orchestration.                                             |
| ⚙️ YAML-Driven Configuration | Define Dev Center settings, projects, pools, catalogs, and environment types through declarative YAML files with JSON Schema validation. |
| 🔐 Security Integration      | Provision **Azure Key Vault** with RBAC authorization, soft-delete, and purge protection for secrets management.                         |
| 📊 Centralized Monitoring    | Deploy **Log Analytics** workspaces with diagnostic settings for all resources.                                                          |
| 🌐 Network Connectivity      | Configure managed or unmanaged virtual networks with subnet isolation per project.                                                       |
| 👥 Role-Based Access Control | Assign Azure RBAC roles using system-assigned managed identities following least-privilege principles.                                   |
| 🚀 Cross-Platform Setup      | Automate environment provisioning with both PowerShell and Bash setup scripts.                                                           |
| 🔄 Multi-Environment Support | Define dev, staging, and UAT environment types with independent deployment targets.                                                      |
| 📦 Catalog Integration       | Connect **GitHub** and Azure DevOps repositories as Dev Box image definition and environment definition catalogs.                        |
| 🧹 Cleanup Automation        | Tear down all provisioned resources, role assignments, and GitHub secrets with a single cleanup script.                                  |

## Architecture

The **DevExp-DevBox** accelerator follows Azure Landing Zone principles,
organizing resources into functional groups (workload, security, monitoring)
under a subscription-scoped deployment. The system uses a layered architecture
where the **Azure Developer CLI** orchestrates Bicep modules that provision
resource groups, deploy core infrastructure services, and configure Dev Center
projects with their associated pools, catalogs, and network connections.

```mermaid
---
config:
  theme: base
  flowchart:
    htmlLabels: true
  themeVariables:
    fontSize: 16px
---
flowchart TB
    %% C4 Container Diagram — DevExp-DevBox Accelerator

    %% PERSONS / ACTORS
    DevManager([<b>Dev Manager</b><br>Person<br>Configures Dev Center projects,<br>pools, and environment types])
    Developer([<b>Developer</b><br>Person<br>Provisions and uses Dev Box<br>workstations for development])

    %% EXTERNAL SYSTEMS
    GitHub[\<b>GitHub</b><br>External System<br>Hosts catalog repositories<br>for image and environment definitions\]
    AzureAD[\<b>Microsoft Entra ID</b><br>External System<br>Provides identity, groups,<br>and RBAC role assignments\]

    %% SYSTEM BOUNDARY
    subgraph SystemBoundary [<b>DevExp-DevBox Accelerator — System Boundary</b>]
        direction TB

        %% ORCHESTRATION LAYER
        subgraph Orchestration [<b>Orchestration Layer</b>]
            direction LR
            AZD[<b>Azure Developer CLI</b><br>Container<br>Orchestrates provisioning hooks<br>and Bicep deployments]
            SetupScripts[<b>Setup Scripts</b><br>Container<br>PowerShell and Bash scripts<br>for environment initialization]
        end

        %% INFRASTRUCTURE LAYER
        subgraph Infrastructure [<b>Infrastructure Layer</b>]
            direction LR
            BicepModules[<b>Bicep Modules</b><br>Container<br>Defines all Azure resources<br>as infrastructure-as-code]
            YAMLConfig[<b>YAML Configuration</b><br>Container<br>Declarative settings for<br>Dev Center, security, and resources]
        end

        %% WORKLOAD LAYER
        subgraph Workload [<b>Workload Layer</b>]
            direction LR
            DevCenter[<b>Azure Dev Center</b><br>Container<br>Manages projects, pools,<br>catalogs, and environment types]
            Projects[<b>Dev Center Projects</b><br>Container<br>Isolated workspaces with<br>role-specific Dev Box pools]
        end

        %% SECURITY LAYER
        subgraph Security [<b>Security Layer</b>]
            direction LR
            KeyVault[(<b>Azure Key Vault</b><br>Container<br>Stores secrets, keys,<br>and certificates securely)]
        end

        %% MONITORING LAYER
        subgraph Monitoring [<b>Monitoring Layer</b>]
            direction LR
            LogAnalytics[(<b>Log Analytics</b><br>Container<br>Collects diagnostic logs<br>and monitoring telemetry)]
        end

        %% CONNECTIVITY LAYER
        subgraph Connectivity [<b>Connectivity Layer</b>]
            direction LR
            VNet[<b>Virtual Networks</b><br>Container<br>Provides network isolation<br>and subnet segmentation]
        end
    end

    %% RELATIONSHIPS
    DevManager -- "Runs setup and deploys" --> AZD
    Developer -- "Provisions Dev Box from" --> DevCenter

    AZD -- "Executes" --> SetupScripts
    AZD -- "Deploys" --> BicepModules
    BicepModules -- "Reads settings from" --> YAMLConfig
    BicepModules -- "Provisions" --> DevCenter
    BicepModules -- "Provisions" --> KeyVault
    BicepModules -- "Provisions" --> LogAnalytics
    BicepModules -- "Provisions" --> VNet

    DevCenter -- "Creates" --> Projects
    Projects -- "Connects via" --> VNet
    DevCenter -- "Retrieves secrets from" --> KeyVault
    DevCenter -- "Sends diagnostics to" --> LogAnalytics

    DevCenter -- "Syncs catalogs from" --> GitHub
    DevCenter -- "Authenticates via" --> AzureAD
```

## Technologies Used

| Technology                | Type                   | Purpose                                                                  |
| ------------------------- | ---------------------- | ------------------------------------------------------------------------ |
| Bicep                     | Infrastructure-as-Code | Define and deploy all Azure resources declaratively                      |
| Azure Developer CLI (azd) | CLI Tool               | Orchestrate provisioning workflows with deployment hooks                 |
| PowerShell                | Scripting              | Cross-platform setup and cleanup automation (Windows)                    |
| Bash                      | Scripting              | Cross-platform setup automation (Linux/macOS)                            |
| YAML                      | Configuration          | Declarative settings for Dev Center, security, and resource organization |
| JSON Schema               | Validation             | Validate YAML configuration files against defined schemas                |
| Azure Dev Center          | Azure Service          | Centralized management of developer workstations and environments        |
| Microsoft Dev Box         | Azure Service          | Cloud-hosted developer workstations with role-specific configurations    |
| Azure Key Vault           | Azure Service          | Secure storage of secrets, keys, and certificates                        |
| Azure Log Analytics       | Azure Service          | Centralized monitoring, diagnostics, and log collection                  |
| Azure Virtual Networks    | Azure Service          | Network isolation and connectivity for Dev Box resources                 |
| Azure RBAC                | Security               | Role-based access control with managed identities                        |
| GitHub CLI (gh)           | CLI Tool               | GitHub authentication and secrets management                             |
| Azure CLI (az)            | CLI Tool               | Azure resource management and authentication                             |

## Quick Start

### Prerequisites

| Prerequisite              | Version | Description                                                              |
| ------------------------- | ------- | ------------------------------------------------------------------------ |
| Azure CLI                 | Latest  | Authenticate and manage Azure resources                                  |
| Azure Developer CLI (azd) | Latest  | Orchestrate infrastructure deployment                                    |
| GitHub CLI (gh)           | Latest  | GitHub authentication (if using GitHub source control)                   |
| jq                        | Latest  | JSON processor (required for Bash setup script)                          |
| PowerShell                | 5.1+    | Run setup scripts on Windows                                             |
| Azure Subscription        | —       | Active subscription with Contributor and User Access Administrator roles |

> [!IMPORTANT] Ensure your Azure account has **Contributor** and **User Access
> Administrator** roles at the subscription level before running any deployment.

### Setup and Deployment

1. Clone the repository:

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
```

2. Authenticate with Azure and GitHub:

```bash
az login
azd auth login
gh auth login
```

3. Initialize and deploy (the `preprovision` hook in `azure.yaml` automatically
   runs the setup scripts to configure environment variables and
   authentication):

```bash
azd init
azd up
```

4. Verify the deployment outputs:

```bash
azd env get-values
```

> [!TIP] The `azd up` command triggers a `preprovision` hook that automatically
> executes the setup scripts, handling environment variable configuration
> (`AZURE_LOCATION`, `KEY_VAULT_SECRET`, `SOURCE_CONTROL_PLATFORM`) and platform
> authentication before provisioning resources.

### Cleanup

To tear down all provisioned resources, role assignments, service principals,
and GitHub secrets:

```powershell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

> [!WARNING] Running `cleanSetUp.ps1` deletes all subscription deployments,
> resource groups, role assignments, service principals, and GitHub secrets. Use
> with caution in shared environments.

## Configuration

The accelerator uses three YAML configuration files in `infra/settings/`, each
validated by a companion JSON Schema. Add
`# yaml-language-server: $schema=./<schema-file>.json` at the top of any YAML
file to enable editor validation.

### Dev Center Core (`infra/settings/workload/devcenter.yaml`)

| Option                                 | Default          | Description                                                        |
| -------------------------------------- | ---------------- | ------------------------------------------------------------------ |
| `name`                                 | `devexp`         | Name of the Dev Center instance (unique within the resource group) |
| `catalogItemSyncEnableStatus`          | `Enabled`        | Automatic synchronization of catalog items from Git repositories   |
| `microsoftHostedNetworkEnableStatus`   | `Enabled`        | Microsoft-hosted networking for Dev Boxes                          |
| `installAzureMonitorAgentEnableStatus` | `Enabled`        | Azure Monitor agent installation on Dev Boxes                      |
| `identity.type`                        | `SystemAssigned` | Managed identity type (`SystemAssigned`, `UserAssigned`, `None`)   |

### Dev Center RBAC (`devcenter.yaml` → `identity.roleAssignments`)

| Option                                  | Example                          | Description                                                       |
| --------------------------------------- | -------------------------------- | ----------------------------------------------------------------- |
| `devCenter[].name`                      | `Contributor`                    | Azure RBAC role assigned to the Dev Center identity               |
| `devCenter[].id`                        | `b24988ac-...`                   | Role definition GUID                                              |
| `devCenter[].scope`                     | `Subscription` / `ResourceGroup` | Scope at which the role applies                                   |
| `orgRoleTypes[].type`                   | `DevManager`                     | Organizational role type                                          |
| `orgRoleTypes[].azureADGroupId`         | GUID                             | Azure AD group receiving the role                                 |
| `orgRoleTypes[].azureADGroupName`       | `Platform Engineering Team`      | Display name of the Azure AD group                                |
| `orgRoleTypes[].azureRBACRoles[].name`  | `DevCenter Project Admin`        | RBAC role assigned to the organizational group                    |
| `orgRoleTypes[].azureRBACRoles[].scope` | `ResourceGroup`                  | Role scope (`Subscription`, `ResourceGroup`, `Project`, `Tenant`) |

### Projects (`devcenter.yaml` → `projects[]`)

| Option        | Example          | Description                           |
| ------------- | ---------------- | ------------------------------------- |
| `name`        | `eShop`          | Unique project name within Dev Center |
| `description` | `eShop project.` | Human-readable project purpose        |

### Project Networking (`projects[].network`)

| Option                               | Example                   | Description                                                |
| ------------------------------------ | ------------------------- | ---------------------------------------------------------- |
| `name`                               | `eShop`                   | Virtual network name                                       |
| `create`                             | `true`                    | Create a new VNet (`true`) or reference existing (`false`) |
| `resourceGroupName`                  | `eShop-connectivity-RG`   | Resource group for network resources                       |
| `virtualNetworkType`                 | `Managed` / `Unmanaged`   | Microsoft-hosted or customer-managed networking            |
| `addressPrefixes[]`                  | `10.0.0.0/16`             | VNet address space (required for `Unmanaged`)              |
| `subnets[].name`                     | `eShop-subnet`            | Subnet name                                                |
| `subnets[].properties.addressPrefix` | `10.0.1.0/24`             | Subnet CIDR range                                          |
| `tags`                               | `{environment: dev, ...}` | Network-specific resource tags                             |

### Project Identity and RBAC (`projects[].identity`)

| Option                                     | Example                     | Description                                                                                      |
| ------------------------------------------ | --------------------------- | ------------------------------------------------------------------------------------------------ |
| `type`                                     | `SystemAssigned`            | Managed identity type for project-level access                                                   |
| `roleAssignments[].azureADGroupId`         | GUID                        | Azure AD group object ID                                                                         |
| `roleAssignments[].azureADGroupName`       | `eShop Engineers`           | Azure AD group display name                                                                      |
| `roleAssignments[].azureRBACRoles[].name`  | `Dev Box User`              | Role name (e.g., Contributor, Dev Box User, Deployment Environment User, Key Vault Secrets User) |
| `roleAssignments[].azureRBACRoles[].id`    | `45d50f46-...`              | Role definition GUID                                                                             |
| `roleAssignments[].azureRBACRoles[].scope` | `Project` / `ResourceGroup` | Scope at which the role applies                                                                  |

### Dev Box Pools (`projects[].pools[]`)

| Option                | Example                       | Description                                    |
| --------------------- | ----------------------------- | ---------------------------------------------- |
| `name`                | `backend-engineer`            | Role-specific pool name                        |
| `imageDefinitionName` | `eshop-backend-dev`           | Image definition name from an attached catalog |
| `vmSku`               | `general_i_32c128gb512ssd_v2` | VM SKU (compute, memory, storage)              |

### Catalogs (`catalogs[]` and `projects[].catalogs[]`)

Catalogs can be defined at Dev Center level (shared) or project level (scoped).

| Option          | Example                                                | Description                                                |
| --------------- | ------------------------------------------------------ | ---------------------------------------------------------- |
| `name`          | `customTasks`                                          | Unique catalog name                                        |
| `type`          | `gitHub` / `imageDefinition` / `environmentDefinition` | Content type hosted in the catalog                         |
| `sourceControl` | `gitHub` / `adoGit`                                    | Git provider hosting the repository                        |
| `visibility`    | `public` / `private`                                   | Repository visibility (`private` requires Key Vault token) |
| `uri`           | `https://github.com/microsoft/devcenter-catalog.git`   | Repository clone URL                                       |
| `branch`        | `main`                                                 | Branch to synchronize                                      |
| `path`          | `./Tasks`                                              | Subdirectory within the repository containing definitions  |

### Environment Types (`environmentTypes[]` and `projects[].environmentTypes[]`)

Defined at Dev Center level (available to all projects) and optionally scoped
per project.

| Option               | Example                               | Description                            |
| -------------------- | ------------------------------------- | -------------------------------------- |
| `name`               | `dev`, `staging`, `uat`, `prod`       | Lifecycle stage name                   |
| `deploymentTargetId` | `""` (empty for default subscription) | Target subscription ID for deployments |

### Security (`infra/settings/security/security.yaml`)

| Option                               | Default     | Description                                             |
| ------------------------------------ | ----------- | ------------------------------------------------------- |
| `create`                             | `true`      | Create a new Key Vault (`false` to use an existing one) |
| `keyVault.name`                      | `contoso`   | Globally unique Key Vault name                          |
| `keyVault.description`               | —           | Human-readable purpose of the Key Vault                 |
| `keyVault.secretName`                | `gha-token` | Secret name storing the source control PAT              |
| `keyVault.enablePurgeProtection`     | `true`      | Prevent permanent deletion of secrets                   |
| `keyVault.enableSoftDelete`          | `true`      | Allow recovery of deleted secrets                       |
| `keyVault.softDeleteRetentionInDays` | `7`         | Retention period for soft-deleted secrets (7–90 days)   |
| `keyVault.enableRbacAuthorization`   | `true`      | Use Azure RBAC instead of vault access policies         |
| `keyVault.tags`                      | See below   | Resource tags for Key Vault governance                  |

### Resource Organization (`infra/settings/resourceOrganization/azureResources.yaml`)

| Option                 | Default           | Description                                                              |
| ---------------------- | ----------------- | ------------------------------------------------------------------------ |
| `workload.create`      | `true`            | Create the workload resource group                                       |
| `workload.name`        | `devexp-workload` | Name prefix for the workload resource group                              |
| `workload.description` | `prodExp`         | Resource group description                                               |
| `workload.tags`        | See below         | Tags for cost allocation and governance                                  |
| `security.create`      | `false`           | Create a separate security resource group (`false` → uses workload RG)   |
| `security.name`        | `devexp-workload` | Security resource group name prefix                                      |
| `monitoring.create`    | `false`           | Create a separate monitoring resource group (`false` → uses workload RG) |
| `monitoring.name`      | `devexp-workload` | Monitoring resource group name prefix                                    |

### Tags (applied at Dev Center, project, network, and resource group levels)

| Key           | Example         | Description                       |
| ------------- | --------------- | --------------------------------- |
| `environment` | `dev`           | Deployment stage                  |
| `division`    | `Platforms`     | Organizational division           |
| `team`        | `DevExP`        | Owning team                       |
| `project`     | `DevExP-DevBox` | Project for cost allocation       |
| `costCenter`  | `IT`            | Financial tracking                |
| `owner`       | `Contoso`       | Resource owner                    |
| `landingZone` | `Workload`      | Azure Landing Zone classification |
| `resources`   | `DevCenter`     | Resource type identifier          |

> [!TIP] Use JSON Schema validation in your editor by referencing the schema
> files (e.g., `devcenter.schema.json`) at the top of each YAML configuration
> file.

## Deployment

All provisioning is handled through **Azure Developer CLI**. The `preprovision`
hook in `azure.yaml` automatically runs the setup scripts before deployment.

```bash
azd up
```

To target a specific environment:

```bash
azd env new prod
azd up -e prod
```

Verify deployment:

```bash
azd env get-values
```

Confirm resource provisioning in the Azure Portal by navigating to the workload
resource group.

## Usage

### Add a New Project

Add a project entry to `infra/settings/workload/devcenter.yaml`:

```yaml
projects:
  - name: 'myProject'
    description: 'My team project.'
    network:
      name: myProject
      create: true
      resourceGroupName: 'myProject-connectivity-RG'
      virtualNetworkType: Managed
    pools:
      - name: 'developer'
        imageDefinitionName: 'my-dev-image'
        vmSku: general_i_16c64gb256ssd_v2
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: ''
```

### Configure Custom (Unmanaged) Networking

For projects requiring customer-managed VNets with specific address spaces:

```yaml
projects:
  - name: 'secureApp'
    network:
      name: secureApp
      create: true
      resourceGroupName: 'secureApp-connectivity-RG'
      virtualNetworkType: Unmanaged
      addressPrefixes:
        - 10.2.0.0/16
      subnets:
        - name: secureApp-subnet
          properties:
            addressPrefix: 10.2.1.0/24
      tags:
        environment: prod
        team: Security
```

### Define Role-Specific Dev Box Pools

Create multiple pools with different VM SKUs per team role:

```yaml
pools:
  - name: 'backend-engineer'
    imageDefinitionName: 'backend-dev'
    vmSku: general_i_32c128gb512ssd_v2
  - name: 'frontend-engineer'
    imageDefinitionName: 'frontend-dev'
    vmSku: general_i_16c64gb256ssd_v2
```

### Attach a Private Catalog with Key Vault Authentication

For private repositories, store the PAT in Key Vault and reference the catalog:

```yaml
# Project-level catalog (private repo)
catalogs:
  - name: 'environments'
    type: environmentDefinition
    sourceControl: gitHub
    visibility: private
    uri: 'https://github.com/myOrg/myRepo.git'
    branch: 'main'
    path: '/.devcenter/environments'
```

The accelerator automatically resolves the Key Vault secret (configured in
`security.yaml` → `keyVault.secretName`) for authentication.

### Assign RBAC to Project Teams

Grant Azure AD groups access to project resources:

```yaml
identity:
  type: SystemAssigned
  roleAssignments:
    - azureADGroupId: '<group-object-id>'
      azureADGroupName: 'My Team Engineers'
      azureRBACRoles:
        - name: 'Dev Box User'
          id: '45d50f46-0b78-4001-a660-4198cbe8cd05'
          scope: Project
        - name: 'Deployment Environment User'
          id: '18e40d4e-8d2e-438d-97e1-9528336e149c'
          scope: Project
```

### Add Organizational Role Assignments

Map Azure AD groups to Dev Center administrative roles:

```yaml
identity:
  roleAssignments:
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: '<group-object-id>'
        azureADGroupName: 'Platform Engineering Team'
        azureRBACRoles:
          - name: 'DevCenter Project Admin'
            id: '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
            scope: ResourceGroup
```

### Manage Multiple Environments

Create and deploy to isolated environments (dev, staging, prod):

```bash
azd env new dev
azd up -e dev

azd env new prod
azd up -e prod
```

### Separate Resource Groups for Security and Monitoring

Enable dedicated resource groups in `azureResources.yaml`:

```yaml
security:
  create: true
  name: devexp-security
monitoring:
  create: true
  name: devexp-monitoring
```

### Tear Down an Environment

Remove all provisioned resources, role assignments, service principals, and
GitHub secrets:

```powershell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

Or tear down only Azure resources via azd:

```bash
azd down
```

### Apply Configuration Changes

After modifying any YAML configuration file, redeploy:

```bash
azd up
```

## Contributing

Contributions are welcome and encouraged. To contribute to **DevExp-DevBox**:

1. Fork the repository.
2. Create a feature branch from `main`.
3. Commit your changes with descriptive messages.
4. Open a Pull Request against `main` with a clear description of the changes.

To report bugs or request features, open an issue in the
[GitHub Issues](https://github.com/Evilazaro/DevExp-DevBox/issues) tracker.

> [!NOTE] This project does not currently have a `CONTRIBUTING.md` or
> `CODE-OF-CONDUCT.md`. Consider adding these files as the community grows.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE)
file for details.
