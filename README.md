# DevExp-DevBox

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Azure Developer CLI](https://img.shields.io/badge/Azure%20Developer%20CLI-azd-0078d4)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
[![IaC: Bicep](https://img.shields.io/badge/IaC-Bicep-0078d4)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
[![Platform: Azure Dev Box](https://img.shields.io/badge/Platform-Microsoft%20Dev%20Box-0078d4)](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)

## Description

**DevExp-DevBox** is a Microsoft Dev Box Accelerator that automates the
end-to-end deployment of cloud-hosted developer workstations on Azure. It
provides a production-ready Infrastructure as Code (IaC) solution for
configuring Azure Dev Center resources, Dev Box projects, role-based access
control, catalog synchronization, networking, and monitoring — all driven by
versioned YAML configuration files and Azure Bicep templates.

Development teams in enterprise organizations face significant overhead when
provisioning consistent, role-specific development environments across multiple
projects and geographic regions. DevExp-DevBox solves this problem by encoding
the entire developer workstation platform as auditable, repeatable
configuration: from virtual network topology and Key Vault secrets to Dev Box
pool SKUs and environment types. Platform engineers deploy the full stack with a
single `azd up` command, and developers gain immediate access to cloud-hosted
Dev Boxes tailored to their role.

The solution uses **Azure Bicep** for infrastructure definition, the **Azure
Developer CLI (`azd`)** for lifecycle management, **PowerShell** and **Bash**
for cross-platform setup automation, and **YAML** for declarative resource
configuration. It integrates with both **GitHub** and **Azure DevOps** as source
control platforms for private and public catalog synchronization, and deploys
across all major Azure commercial regions.

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

| Feature                              | Description                                                                                                                                          |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🏢 **Dev Center Deployment**         | Provisions a fully configured Azure Dev Center with system-assigned managed identity, catalog item sync, and Azure Monitor agent integration.        |
| 📦 **Project Management**            | Supports multiple Dev Box projects — each with its own role-specific pools, environment types, team-scoped RBAC, and project-level managed identity. |
| 📚 **Catalog Integration**           | Attaches public or private catalogs from GitHub or Azure DevOps repositories for Dev Box customization tasks and image definitions.                  |
| 🔑 **Secrets Management**            | Stores and retrieves source control tokens in Azure Key Vault with RBAC authorization, soft-delete protection, and purge protection.                 |
| 🌐 **Flexible Networking**           | Supports both Microsoft-managed and customer-managed (Unmanaged) virtual network topologies with automated VNet and subnet provisioning.             |
| 📊 **Centralized Monitoring**        | Deploys a Log Analytics Workspace with the AzureActivity solution for diagnostics and activity tracking across all Dev Center resources.             |
| 🛡️ **Least-Privilege RBAC**          | Assigns only the roles required for Dev Center operation following the principle of least privilege across subscription and resource group scopes.   |
| ⚙️ **Declarative Configuration**     | All resource settings — Dev Center, projects, pools, network, security, and tagging — are expressed in YAML files for auditability and reuse.        |
| 🔄 **Multi-Platform Source Control** | Automates environment setup for **GitHub** and **Azure DevOps** via `setUp.sh` (Linux/macOS) and `setUp.ps1` (Windows).                              |
| 🧹 **Clean-Up Automation**           | Provides `cleanSetUp.ps1` to remove all deployed resources, role assignments, service principals, and source control secrets.                        |

## Architecture

The diagram below shows the actors, major components, and interactions that make
up the DevExp-DevBox platform. **Platform Engineers** run `azd up` to deploy the
full infrastructure stack, and **Developers** consume role-specific Dev Box
pools once the platform is live.

```mermaid
---
config:
  description: "High-level architecture diagram showing actors, primary flows, and major components."
  theme: base
  themeVariables:
    textColor: "#242424"
    primaryColor: "#f5f5f5"
    primaryTextColor: "#242424"
    primaryBorderColor: "#d1d1d1"
---
flowchart TB

%% ── Actors ─────────────────────────────────────────────────────────────────
subgraph ACTORS["👥 Actors"]
  direction TB
  PlatformEngineer(["👷 Platform Engineer"])
  Developer(["👩‍💻 Developer"])
end

%% ── External Systems ────────────────────────────────────────────────────────
subgraph EXTERNAL["🌐 External Systems"]
  direction TB
  GitHubADO(["🐙 GitHub / Azure DevOps"])
end

%% ── Deployment Tooling ──────────────────────────────────────────────────────
subgraph DEPLOY["🛠️ Deployment Tooling"]
  direction TB
  AZD("⚙️ Azure Developer CLI<br/>azd up / azd deploy")
  SetupScript("📜 Setup Script<br/>setUp.sh / setUp.ps1")
end

%% ── Azure Dev Center Core ───────────────────────────────────────────────────
subgraph DEVCENTER_CORE["🏢 Azure Dev Center"]
  direction TB
  DevCenter("🖥️ Dev Center")
  Catalog("📚 Catalog<br/>Tasks and Definitions")
  EnvType("🔖 Environment Types<br/>dev / staging / uat")
end

%% ── Dev Box Project ─────────────────────────────────────────────────────────
subgraph PROJECT_BLOCK["📦 Dev Box Project"]
  direction TB
  Project("🗂️ Project")
  Pool("🖥️ Dev Box Pool")
  NetworkConn("🔌 Network Connection")
end

%% ── Shared Infrastructure ───────────────────────────────────────────────────
subgraph INFRA["⚙️ Shared Infrastructure"]
  direction TB
  KeyVault[("🔑 Azure Key Vault")]
  LogAnalytics[("📊 Log Analytics Workspace")]
  VNet("🌐 Virtual Network")
  RBAC("🛡️ Azure RBAC")
end

%% ── Interactions ────────────────────────────────────────────────────────────
PlatformEngineer --> |"runs azd up"| AZD
AZD --> |"pre-provision hook"| SetupScript
SetupScript --> |"configures environment"| AZD
AZD --> |"Bicep deployment"| DevCenter
AZD --> |"provisions secrets store"| KeyVault
AZD --> |"provisions workspace"| LogAnalytics
AZD --> |"assigns roles"| RBAC
DevCenter --> |"attaches catalog"| Catalog
DevCenter --> |"registers types"| EnvType
Catalog -.-> |"scheduled sync"| GitHubADO
DevCenter --> |"reads secret"| KeyVault
DevCenter -.-> |"sends diagnostics"| LogAnalytics
DevCenter --> |"creates project"| Project
Project --> |"defines pool"| Pool
Project --> |"attaches"| NetworkConn
NetworkConn --> |"connects to"| VNet
Developer --> |"provisions Dev Box"| Pool

%% ── Class Definitions ───────────────────────────────────────────────────────
classDef actor fill:#cce3f5,stroke:#0f6cbd,color:#242424
classDef tooling fill:#e9d7f7,stroke:#6b2faa,color:#242424
classDef external fill:#fff4d6,stroke:#835b00,color:#242424
classDef devcenterNode fill:#0f6cbd,stroke:#0f6cbd,color:#ffffff
classDef projectNode fill:#cff0bd,stroke:#107c10,color:#242424
classDef infraNode fill:#f0f0f0,stroke:#616161,color:#242424
classDef datastore fill:#f5f5f5,stroke:#0f6cbd,color:#242424

%% ── Class Assignments ───────────────────────────────────────────────────────
class PlatformEngineer,Developer actor
class AZD,SetupScript tooling
class GitHubADO external
class DevCenter,Catalog,EnvType devcenterNode
class Project,Pool,NetworkConn projectNode
class VNet,RBAC infraNode
class KeyVault,LogAnalytics datastore

```

## Technologies Used

| Technology                    | Type           | Purpose                                                                          |
| ----------------------------- | -------------- | -------------------------------------------------------------------------------- |
| Azure Bicep                   | IaC Language   | Defines all Azure resources at subscription and resource group scope.            |
| Azure Developer CLI (`azd`)   | Deployment CLI | Orchestrates the full provisioning lifecycle, including pre-provision hooks.     |
| Azure Dev Center              | Azure Service  | Central hub for Dev Box projects, catalogs, environment types, and pools.        |
| Azure Key Vault               | Azure Service  | Stores source control authentication tokens used by private catalogs.            |
| Azure Log Analytics Workspace | Azure Service  | Collects diagnostic and activity logs from Dev Center resources.                 |
| Azure Virtual Network         | Azure Service  | Provides network connectivity for Dev Box machines in Unmanaged topology.        |
| Azure RBAC                    | Azure Service  | Enforces least-privilege access for Dev Center, projects, and Key Vault.         |
| PowerShell 5.1+               | Scripting      | Windows environment setup (`setUp.ps1`) and clean-up (`cleanSetUp.ps1`).         |
| Bash                          | Scripting      | Linux/macOS environment setup (`setUp.sh`).                                      |
| YAML                          | Configuration  | Declarative configuration for Dev Center, security, and resource organization.   |
| Azure CLI (`az`)              | CLI Tool       | Authenticates and manages Azure resources during environment setup.              |
| GitHub CLI (`gh`)             | CLI Tool       | Configures GitHub secrets for Azure credentials during GitHub integration setup. |

## Quick Start

### Prerequisites

| Requirement                                                                | Minimum Version | Notes                                                                               |
| -------------------------------------------------------------------------- | --------------- | ----------------------------------------------------------------------------------- |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | 2.60            | `az login` must succeed before running `azd up`.                                    |
| [Azure Developer CLI](https://aka.ms/azd)                                  | 1.9.0           | Install from [aka.ms/azd](https://aka.ms/azd).                                      |
| [GitHub CLI](https://cli.github.com/)                                      | 2.40            | Required only when `SOURCE_CONTROL_PLATFORM=github`.                                |
| PowerShell                                                                 | 5.1             | Required on Windows; pre-installed on Windows 10 and Windows 11.                    |
| Bash and `jq`                                                              | Any             | Required on Linux and macOS.                                                        |
| Azure Subscription                                                         | —               | Contributor and User Access Administrator access at subscription scope is required. |

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Evilazaro/DevExp-DevBox.git
   cd DevExp-DevBox
   ```

2. Authenticate with Azure and your chosen source control platform:

   ```bash
   az login
   azd auth login
   gh auth login   # Required only for GitHub integration
   ```

3. Initialize the `azd` environment and set the required variables:

   ```bash
   azd env new dev
   azd env set AZURE_LOCATION eastus2
   azd env set SOURCE_CONTROL_PLATFORM github
   azd env set KEY_VAULT_SECRET "<your-github-or-ado-pat>"
   ```

4. Deploy the infrastructure:

   ```bash
   azd up
   ```

> [!NOTE] The `azd up` command triggers a pre-provision hook that runs
> `setUp.sh` (Linux/macOS) or `setUp.ps1` (Windows) to configure the environment
> before deploying the Bicep templates.

### Minimal Working Example

```bash
# Deploy a Dev Box environment named "dev" in East US 2 with GitHub integration
azd env new dev
azd env set AZURE_LOCATION eastus2
azd env set SOURCE_CONTROL_PLATFORM github
azd env set KEY_VAULT_SECRET "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azd up
```

Expected output:

```text
SUCCESS: Your up workflow to provision and deploy to Azure completed.
```

## Configuration

All configuration is driven by YAML files in `infra/settings/` and environment
variables injected via `infra/main.parameters.json`.

### Environment Variables

| Option                    | Default      | Description                                                                                        |
| ------------------------- | ------------ | -------------------------------------------------------------------------------------------------- |
| `AZURE_ENV_NAME`          | _(required)_ | Environment name used in resource group names, for example `dev` or `prod`.                        |
| `AZURE_LOCATION`          | _(required)_ | Azure region for all resources, for example `eastus2` or `westeurope`.                             |
| `KEY_VAULT_SECRET`        | _(required)_ | GitHub Personal Access Token or Azure DevOps PAT to store in Key Vault for catalog authentication. |
| `SOURCE_CONTROL_PLATFORM` | `github`     | Source control integration to configure: `github` or `adogit`.                                     |

### Dev Center Configuration

Modify `infra/settings/workload/devcenter.yaml` to customize Dev Center
settings:

```yaml
name: 'devexp'
catalogItemSyncEnableStatus: 'Enabled'
microsoftHostedNetworkEnableStatus: 'Enabled'
installAzureMonitorAgentEnableStatus: 'Enabled'
```

> [!TIP] Set `microsoftHostedNetworkEnableStatus: 'Disabled'` and configure a
> custom virtual network in the project `network` block to use customer-managed
> networking instead of the Microsoft-hosted network.

### Security Configuration

Modify `infra/settings/security/security.yaml` to adjust Key Vault settings:

```yaml
keyVault:
  name: contoso
  enablePurgeProtection: true
  softDeleteRetentionInDays: 7
  enableRbacAuthorization: true
```

> [!WARNING] Do not store raw token values in YAML files. Always pass
> `KEY_VAULT_SECRET` as an environment variable using `azd env set`.

### Resource Organization

Modify `infra/settings/resourceOrganization/azureResources.yaml` to control
which resource groups are created and how they are tagged:

```yaml
workload:
  create: true
  name: devexp-workload
  tags:
    environment: dev
    team: DevExP
    project: Contoso-DevExp-DevBox
```

## Deployment

Follow these numbered steps to deploy DevExp-DevBox to a production or staging
environment.

1. Verify that all prerequisites listed in [Quick Start](#quick-start) are
   installed and authenticated.

2. Create a new `azd` environment for the target stage:

   ```bash
   azd env new staging
   ```

3. Set the required environment variables for the target environment:

   ```bash
   azd env set AZURE_LOCATION westeurope
   azd env set SOURCE_CONTROL_PLATFORM github
   azd env set KEY_VAULT_SECRET "<your-pat-token>"
   ```

4. Review `infra/settings/resourceOrganization/azureResources.yaml` and update
   resource group names and tags to match your organizational standards.

5. Review `infra/settings/workload/devcenter.yaml` and update project names,
   pool SKUs, and catalog URIs for the target environment.

6. Deploy all infrastructure:

   ```bash
   azd up --environment staging
   ```

7. Verify the deployment in the Azure Portal. Confirm that the Dev Center, Key
   Vault, Log Analytics Workspace, and all project resources are present in the
   expected resource groups.

> [!IMPORTANT] The deploying identity requires **Contributor** and **User Access
> Administrator** roles at subscription scope, because the deployment creates
> role assignments. Ensure the identity used by `azd` holds these roles before
> running `azd up`.

8. To remove all deployed resources, run the clean-up script:

   ```powershell
   .\cleanSetUp.ps1 -EnvName "staging" -Location "westeurope"
   ```

## Usage

### Add a Custom Dev Box Project

Edit `infra/settings/workload/devcenter.yaml` to add a new project entry, then
redeploy:

```yaml
projects:
  - name: 'MyProject'
    description: 'My development project.'
    network:
      virtualNetworkType: Managed
    pools:
      - name: 'backend-engineer'
        imageDefinitionName: 'my-backend-image'
        vmSku: general_i_32c128gb512ssd_v2
    environmentTypes:
      - name: 'dev'
    catalogs:
      - name: 'devboxImages'
        type: imageDefinition
        sourceControl: gitHub
        visibility: private
        uri: 'https://github.com/MyOrg/MyRepo.git'
        branch: 'main'
        path: '/.devcenter/imageDefinitions'
```

Deploy the updated configuration:

```bash
azd up
```

### Switch to Azure DevOps Source Control

```bash
azd env set SOURCE_CONTROL_PLATFORM adogit
azd env set KEY_VAULT_SECRET "<your-ado-pat>"
azd up
```

> [!NOTE] When using Azure DevOps, ensure the Personal Access Token has **Code
> (Read)** scope for the catalog repositories you want to sync.

### Clean Up All Resources

```powershell
# Remove all resources for the "dev" environment
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

Expected output:

```text
✅ Successfully removed subscription deployments.
✅ Successfully removed role assignments.
✅ Successfully deleted service principal.
✅ Successfully removed GitHub secrets.
✅ Successfully deleted resource groups.
```

### Compile Bicep Templates Locally

Validate all Bicep templates without deploying:

```bash
az bicep build --file infra/main.bicep
```

## Contributing

Contributions to DevExp-DevBox are welcome. To submit a change:

1. Fork the repository on GitHub at
   <https://github.com/Evilazaro/DevExp-DevBox>.

2. Create a feature branch from `main`:

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Make your changes and verify that the Bicep templates compile without errors:

   ```bash
   az bicep build --file infra/main.bicep
   ```

4. Open a pull request against the `main` branch, describing the change and its
   motivation.

5. Report bugs or request features by opening an issue at
   <https://github.com/Evilazaro/DevExp-DevBox/issues>.

> [!NOTE] A `CONTRIBUTING.md` file is not yet present in this repository. When
> participating in the community, follow the
> [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

## License

This project is licensed under the **MIT License**. See the [LICENSE](./LICENSE)
file for the full license text.
