# ContosoDevExp Dev Box Accelerator

![License](https://img.shields.io/badge/license-MIT-blue)
![IaC](https://img.shields.io/badge/IaC-Bicep-0078d4)
![CLI](https://img.shields.io/badge/CLI-Azure%20Developer%20CLI-0078d4)
![Platform](https://img.shields.io/badge/platform-Microsoft%20Dev%20Box-5c2e91)

**ContosoDevExp Dev Box Accelerator** is an Infrastructure-as-Code (IaC)
platform that automates the provisioning and management of
[Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
environments on Azure. It provides Platform Engineering teams with a repeatable,
policy-compliant way to deliver pre-configured cloud workstations to development
teams at scale.

Development teams frequently spend hours or days setting up consistent local
environments. This accelerator eliminates that friction by provisioning an
**Azure Dev Center** with role-specific Dev Box pools, secure credential
management, and centralized monitoring — all from a single `azd up` command. The
result is a reproducible, version-controlled developer workstation platform
aligned to Azure Landing Zone principles.

The accelerator is built on **Azure Bicep** for declarative infrastructure, the
**Azure Developer CLI** (`azd`) for orchestrated provisioning, and **YAML-driven
configuration** for environment customization. It supports both GitHub and Azure
DevOps as source control platforms and integrates Azure Key Vault, Log Analytics
Workspace, and Microsoft Entra ID for enterprise-grade security and
observability.

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

| Feature                      | Description                                                                                                                                                  |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 🖥️ Dev Box Provisioning      | Deploys a fully configured Azure Dev Center with role-specific Dev Box pools for backend and frontend engineers.                                             |
| 📁 Project Isolation         | Creates isolated Dev Box projects with dedicated virtual networks, catalogs, and environment types per team.                                                 |
| 🔑 Secret Management         | Stores source control access tokens (GitHub or Azure DevOps) in Azure Key Vault with RBAC-based access control.                                              |
| 📊 Centralized Monitoring    | Sends all diagnostic logs and metrics to a Log Analytics Workspace for unified observability across all resources.                                           |
| ⚙️ Automated Setup           | Provides `setUp.sh` and `setUp.ps1` scripts that authenticate with the chosen source control platform and prepare the `azd` environment before provisioning. |
| 🔐 Role-Based Access Control | Assigns least-privilege RBAC roles to the Dev Center managed identity, Dev Managers, and Dev Box Users via Microsoft Entra ID groups.                        |
| 📦 Catalog Integration       | Syncs Dev Box task definitions from public or private GitHub or Azure DevOps repositories on a scheduled basis.                                              |
| 🌍 Multi-Environment Support | Defines `dev`, `staging`, and `uat` environment types to match each stage of your software delivery lifecycle.                                               |

## Architecture

The ContosoDevExp Dev Box Accelerator delivers a managed cloud workstation platform for three actor types: **Platform Engineers** who configure the platform, **Dev Managers** who manage team project settings, and **Dev Box Users** who connect to their cloud workstations. The central component is the **Azure Dev Center**, which hosts a **Dev Center Catalog** that syncs task definitions from GitHub or Azure DevOps on a scheduled basis, registers **Environment Types** (`dev`, `staging`, `uat`) for deployment targets, and provisions one or more **Dev Box Projects**. Each project contains role-specific **Dev Box Pools** (such as `backend-engineer` and `frontend-engineer`) and attaches a **Virtual Network** for network isolation. A **Managed Identity** assigned to the Dev Center authenticates passwordlessly to **Azure Key Vault**, which stores the source control Personal Access Token used for private catalog authentication. Both the Dev Center and its projects emit diagnostic logs and metrics to a **Log Analytics Workspace** for centralized observability. **Microsoft Entra ID** enforces RBAC policies at the Dev Center and project scopes, governing access for Dev Managers and Dev Box Users throughout the platform.

```mermaid
---
config:
  description: "High-level architecture of the ContosoDevExp Dev Box Accelerator — actors, primary flows, and major components."
  theme: base
  themeVariables:
    htmlLabels: true
    fontFamily: "Segoe UI, system-ui, -apple-system, sans-serif"
    fontSize: 16
---
flowchart TB

  %% ── Class Definitions ─────────────────────────────────────────────────────
  %% Only classDefs actually assigned to nodes are declared.
  %% actor:      blue tint50  — human users
  %% external:   orange       — external systems
  %% service:    grey         — generic Azure services / components
  %% devops:     cornflower   — DevOps / catalog integration
  %% identity:   marigold     — managed identity / Entra resources
  %% monitor:    darkBlue     — monitoring / observability datastores
  %% security:   red          — security datastores (Key Vault)
  %% compute:    lightBlue    — compute resources (Dev Box Pools)
  %% networking: steel        — networking resources (VNets)
  classDef actor      fill:#d0e7f8,stroke:#0078d4,color:#242424,font-weight:bold
  classDef external   fill:#fff9f5,stroke:#f7630c,color:#835b00,font-weight:bold
  classDef service    fill:#f5f5f5,stroke:#616161,color:#242424,font-weight:bold
  classDef devops     fill:#f7f9fe,stroke:#4f6bed,color:#182047,font-weight:bold
  classDef identity   fill:#fefbf4,stroke:#eaa300,color:#463100,font-weight:bold
  classDef monitor    fill:#eff4f9,stroke:#003966,color:#00111f,font-weight:bold
  classDef security   fill:#fdf6f6,stroke:#d13438,color:#3f1011,font-weight:bold
  classDef compute    fill:#f6fafe,stroke:#3a96dd,color:#112d42,font-weight:bold
  classDef networking fill:#eff7f9,stroke:#005b70,color:#001b22,font-weight:bold

  %% ── Actors ─────────────────────────────────────────────────────────────────
  subgraph ACTORS["👥 Actors"]
    PLATENG(["👤 Platform Engineer"])
    DEVMGR(["👥 Dev Manager"])
    DEVUSER(["👤 Dev Box User"])
  end

  %% ── External Systems ────────────────────────────────────────────────────────
  subgraph EXT["🌍 External Systems"]
    GITHUB(["🔗 GitHub"])
    ADO(["🔗 Azure DevOps"])
    ENTRAID(["🔐 Microsoft Entra ID"])
  end

  %% ── Governance and Observability ────────────────────────────────────────────
  subgraph GOVLAYER["🔒 Governance and Observability"]
    KV[("🔑 Azure Key Vault")]
    MI("🪪 Managed Identity")
    LAW[("📋 Log Analytics Workspace")]
  end

  %% ── Azure Dev Center ─────────────────────────────────────────────────────────
  subgraph DEVCENTER["🖥️ Azure Dev Center"]
    DC("🖥️ Dev Center")
    CATALOG("⚙️ Dev Center Catalog")
    ENVTYPE("📋 Environment Types<br/>(dev / staging / uat)")
  end

  %% ── Dev Box Projects ─────────────────────────────────────────────────────────
  subgraph PROJECT_LAYER["📁 Dev Box Projects"]
    PROJECT("📁 Dev Box Project")
    POOL("🖥️ Dev Box Pools<br/>(backend / frontend)")
    VNET("🕸️ Virtual Network")
  end

  %% ── Primary Flows ────────────────────────────────────────────────────────────
  PLATENG -- "Configures platform"      --> DC
  DEVMGR  -- "Manages project settings" --> PROJECT
  DEVUSER -. "Connects to Dev Box" .->   POOL

  DC      -- "Hosts"                    --> CATALOG
  DC      -- "Registers"                --> ENVTYPE
  DC      -- "Provisions"               --> PROJECT
  DC      -. "Sends diagnostics" .->     LAW

  CATALOG -. "Syncs task definitions" .-> GITHUB
  CATALOG -. "Syncs task definitions" .-> ADO

  PROJECT -- "Contains"                 --> POOL
  PROJECT -- "Attaches"                 --> VNET
  PROJECT -. "Sends diagnostics" .->     LAW

  MI      -. "Assigned to" .->           DC
  MI      -- "Reads PAT secret"         --> KV

  ENTRAID -- "Enforces RBAC roles"      --> DC
  ENTRAID -- "Enforces RBAC roles"      --> PROJECT

  %% ── Class Assignments ────────────────────────────────────────────────────────
  class PLATENG,DEVMGR,DEVUSER actor
  class GITHUB,ADO,ENTRAID external
  class DC,ENVTYPE,PROJECT service
  class CATALOG devops
  class MI identity
  class KV security
  class LAW monitor
  class POOL compute
  class VNET networking

  %% ── Subgraph Styles ──────────────────────────────────────────────────────────
  style ACTORS        fill:#f0f0f0,stroke:#d1d1d1,color:#424242,stroke-width:2px
  style EXT           fill:#f0f0f0,stroke:#d1d1d1,color:#424242,stroke-width:2px
  style GOVLAYER      fill:#f0f0f0,stroke:#d1d1d1,color:#424242,stroke-width:2px
  style DEVCENTER     fill:#f0f0f0,stroke:#d1d1d1,color:#424242,stroke-width:2px
  style PROJECT_LAYER fill:#f0f0f0,stroke:#d1d1d1,color:#424242,stroke-width:2px
```

## Technologies Used

| Technology                                 | Type             | Purpose                                                                          |
| ------------------------------------------ | ---------------- | -------------------------------------------------------------------------------- |
| Azure Dev Center                           | Azure Service    | Central hub for managing developer workstations, Dev Box projects, and catalogs  |
| Azure Bicep                                | IaC Language     | Declarative infrastructure templates for all Azure resources                     |
| Azure Developer CLI (`azd`)                | CLI Tool         | Orchestrates pre-provisioning hooks, Bicep deployment, and environment lifecycle |
| Azure Key Vault                            | Azure Service    | Secure storage for source control Personal Access Tokens and secrets             |
| Log Analytics Workspace                    | Azure Service    | Centralized monitoring, diagnostics, and activity logging across all resources   |
| Azure Virtual Networks                     | Azure Service    | Network isolation for Dev Box projects and pools                                 |
| Microsoft Entra ID                         | Azure Service    | Identity provider for RBAC enforcement and group-based access control            |
| Managed Identity (SystemAssigned)          | Azure Service    | Passwordless authentication for the Dev Center to access Azure resources         |
| Bash (`setUp.sh`)                          | Script           | Pre-provisioning environment setup for Linux and macOS                           |
| PowerShell (`setUp.ps1`, `cleanSetUp.ps1`) | Script           | Pre-provisioning setup and resource cleanup for Windows                          |
| YAML                                       | Configuration    | Declarative configuration for Dev Center, security, and resource organization    |
| GitHub / Azure DevOps                      | External Service | Source control platforms for catalog definitions and CI/CD integration           |

## Quick Start

### Prerequisites

| Prerequisite                | Version | Notes                                                                                           |
| --------------------------- | ------- | ----------------------------------------------------------------------------------------------- |
| Azure CLI (`az`)            | Latest  | Required for Azure authentication and resource management                                       |
| Azure Developer CLI (`azd`) | Latest  | Required for provisioning and environment lifecycle management                                  |
| GitHub CLI (`gh`)           | Latest  | Required when `SOURCE_CONTROL_PLATFORM` is set to `github`                                      |
| `jq`                        | Latest  | Required by `setUp.sh` for JSON processing                                                      |
| Azure subscription          | —       | The deploying identity requires Contributor and User Access Administrator at subscription scope |
| Microsoft Entra ID groups   | —       | Groups for Dev Managers and Dev Box Users must exist before deployment                          |

> [!IMPORTANT] Update the `azureADGroupId` values in
> `infra/settings/workload/devcenter.yaml` to match your actual Microsoft Entra
> ID group object IDs before running `azd up`.

### Installation

1. Clone the repository.

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
```

2. Log in to the Azure Developer CLI and target your subscription.

```bash
azd auth login
az account set --subscription "<your-subscription-id>"
```

3. Create a new `azd` environment and set the required variables.

```bash
azd env new dev
azd env set AZURE_LOCATION "eastus2"
azd env set KEY_VAULT_SECRET "<your-github-or-ado-pat-token>"
azd env set SOURCE_CONTROL_PLATFORM "github"   # or "adogit" for Azure DevOps
```

4. Run `azd up` to execute the pre-provisioning scripts and deploy all Azure
   resources.

```bash
azd up
```

> [!NOTE] The `azd up` command automatically triggers `setUp.sh` on Linux/macOS
> or `setUp.ps1` on Windows as a pre-provisioning hook before deploying the
> Bicep templates.

### Minimal Working Example

```bash
# Clone, configure, and provision the full Dev Box environment
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
azd auth login
azd env new dev
azd env set AZURE_LOCATION "eastus2"
azd env set KEY_VAULT_SECRET "ghp_yourGitHubPersonalAccessToken"
azd env set SOURCE_CONTROL_PLATFORM "github"
azd up

# Expected output:
# ✅ Pre-provisioning completed.
# ✅ Resource groups created: devexp-workload-dev-eastus2-RG
# ✅ Azure Dev Center deployed: devexp
# ✅ Key Vault deployed: contoso-<unique>-kv
# ✅ Log Analytics Workspace deployed.
# ✅ Dev Box Projects deployed: eShop
```

## Configuration

The accelerator reads its settings from three YAML files under
`infra/settings/`. Edit these files to customize the deployment before running
`azd up`.

| Option                                  | Default           | Description                                                                                                                                |
| --------------------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `workload.name`                         | `devexp-workload` | Base name for the workload resource group. Defined in `infra/settings/resourceOrganization/azureResources.yaml`.                           |
| `workload.create`                       | `true`            | Controls whether the workload resource group is created.                                                                                   |
| `security.create`                       | `false`           | Controls whether a dedicated security resource group is created. When `false`, security resources share the workload resource group.       |
| `monitoring.create`                     | `false`           | Controls whether a dedicated monitoring resource group is created. When `false`, monitoring resources share the workload resource group.   |
| `keyVault.name`                         | `contoso`         | Base name for the Azure Key Vault instance. A unique suffix is appended automatically. Defined in `infra/settings/security/security.yaml`. |
| `keyVault.softDeleteRetentionInDays`    | `7`               | Number of days to retain deleted secrets before permanent removal.                                                                         |
| `devcenter.name`                        | `devexp`          | Name of the Azure Dev Center instance. Defined in `infra/settings/workload/devcenter.yaml`.                                                |
| `devcenter.catalogItemSyncEnableStatus` | `Enabled`         | Enables or disables scheduled synchronization of catalog items from source control.                                                        |
| `SOURCE_CONTROL_PLATFORM`               | `github`          | Source control platform for catalog authentication. Accepted values: `github`, `adogit`. Set as an `azd` environment variable.             |
| `AZURE_ENV_NAME`                        | —                 | Name of the `azd` environment; used as part of resource group naming. Set via `azd env new <name>`.                                        |
| `AZURE_LOCATION`                        | —                 | Azure region for resource deployment. Accepted values: `eastus`, `eastus2`, `westus`, `westus2`, `westus3`, and others.                    |

### Example Override

```yaml
# infra/settings/workload/devcenter.yaml — add a new project with a managed network
name: 'mydevexp'
projects:
  - name: 'myTeam'
    description: 'My Team Dev Box Project'
    network:
      virtualNetworkType: Managed
    pools:
      - name: 'fullstack-engineer'
        imageDefinitionName: 'myteam-fullstack-dev'
        vmSku: general_i_32c128gb512ssd_v2
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: ''
```

> [!TIP] Set `security.create: true` and `monitoring.create: true` in
> `azureResources.yaml` to deploy dedicated resource groups for Key Vault and
> Log Analytics, following Azure Landing Zone best practices for environment
> segregation.

## Deployment

1. Confirm all [Prerequisites](#prerequisites) are installed and that your Azure
   identity has Contributor and User Access Administrator roles at the
   subscription scope.

2. Edit the YAML configuration files under `infra/settings/` to match your
   organization's naming conventions, Entra ID group object IDs, and preferred
   Dev Box pool VM SKUs.

3. Set the required environment variables.

```bash
azd env set AZURE_ENV_NAME "<environment-name>"
azd env set AZURE_LOCATION "<azure-region>"
azd env set KEY_VAULT_SECRET "<source-control-pat-token>"
azd env set SOURCE_CONTROL_PLATFORM "github"
```

4. Run `azd up` to provision all Azure resources.

```bash
azd up
```

5. Verify the deployment outputs printed by `azd`.

```bash
azd env get-values

# Expected output:
# AZURE_DEV_CENTER_NAME=devexp
# AZURE_DEV_CENTER_PROJECTS=["eShop"]
# AZURE_KEY_VAULT_NAME=contoso-<unique>-kv
# AZURE_KEY_VAULT_ENDPOINT=https://contoso-<unique>-kv.vault.azure.net/
# AZURE_LOG_ANALYTICS_WORKSPACE_NAME=logAnalytics-<unique>
```

6. To remove all provisioned resources, run the cleanup script.

```powershell
.\cleanSetUp.ps1 -EnvName "<environment-name>" -Location "<azure-region>"
```

> [!WARNING] The `cleanSetUp.ps1` script deletes Azure resource groups, service
> principals, and GitHub secrets. Review all parameters carefully before
> executing it against a shared or production environment.

## Usage

### Listing Dev Boxes

After a successful deployment, Dev Box Users can list and connect to their cloud
workstations using the Azure CLI.

```bash
az devbox dev-box list \
  --dev-center-name "devexp" \
  --project-name "eShop"

# Expected output:
# [
#   {
#     "name": "mydevbox",
#     "poolName": "backend-engineer",
#     "provisioningState": "Succeeded",
#     "powerState": "Running"
#   }
# ]
```

### Adding a New Dev Box Pool

To add a new Dev Box pool, add an entry to the `pools` array for the target
project in `infra/settings/workload/devcenter.yaml` and re-run `azd up`.

```yaml
# infra/settings/workload/devcenter.yaml
pools:
  - name: 'data-engineer'
    imageDefinitionName: 'eshop-data-dev'
    vmSku: general_i_32c128gb512ssd_v2
```

```bash
azd up
# Expected output:
# ✅ Dev Box pool 'data-engineer' deployed to project 'eShop'.
```

### Cleaning Up All Resources

Run the `cleanSetUp.ps1` script to remove all resources created by the
accelerator.

```powershell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"

# Expected output:
# ✅ Azure resource groups deleted.
# ✅ Service principal removed.
# ✅ GitHub secret AZURE_CREDENTIALS deleted.
```

## Contributing

Community contributions are welcome. To propose a bug fix or new feature:

1. Open an issue describing the problem or enhancement at
   [https://github.com/Evilazaro/DevExp-DevBox/issues](https://github.com/Evilazaro/DevExp-DevBox/issues).
2. Fork the repository and create a feature branch from `main`.
3. Commit your changes with descriptive commit messages.
4. Submit a pull request referencing the issue number and describing the change.

> [!NOTE] A `CONTRIBUTING.md` and `CODE-OF-CONDUCT.md` are not yet present in
> this repository. Open an issue to request their addition.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE)
file for the full license text.
