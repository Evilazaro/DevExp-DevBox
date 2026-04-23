# DevExp-DevBox

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![IaC: Bicep](https://img.shields.io/badge/IaC-Bicep-orange)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
[![Azure Developer CLI](https://img.shields.io/badge/azd-enabled-0078D4?logo=microsoft-azure)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
[![Platform: Azure](https://img.shields.io/badge/Platform-Microsoft%20Azure-0078D4?logo=microsoft-azure)](https://azure.microsoft.com)
[![Bicep API](https://img.shields.io/badge/DevCenter%20API-2026--01--01--preview-blueviolet)](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
[![Scope: Subscription](https://img.shields.io/badge/Bicep%20Scope-Subscription-informational)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-subscription)

An **Azure Developer CLI (azd)**-enabled accelerator that provisions a fully configured [Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box) environment — including Dev Centers, projects, catalogs, environment types, Dev Box pools, networking, Key Vault secrets management, and centralized Log Analytics monitoring — all declared as Infrastructure-as-Code using Bicep.

## 📑 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#️-architecture)
- [Quick Start](#-quick-start)
- [Requirements](#-requirements)
- [Deployment](#-deployment)
- [Usage](#-usage)
- [Configuration](#️-configuration)
- [Contributing](#-contributing)
- [License](#-license)

## 📖 Overview

**Overview**

DevExp-DevBox is an enterprise-grade platform engineering accelerator that automates the end-to-end provisioning of developer workstation infrastructure on Azure. It targets platform engineering teams who need a repeatable, configuration-driven approach to standing up Microsoft Dev Box environments across multiple projects and teams.

The solution follows Azure Landing Zone principles, separating workload, security, and monitoring concerns into independently managed resource groups. All configuration is YAML-driven, enabling teams to onboard new Dev Box projects, catalogs, networking topologies, and role assignments without modifying Bicep source files. The Bicep deployment is subscription-scoped (`targetScope = 'subscription'` in `infra/main.bicep`), so a single `azd up` command creates resource groups, provisions all resources, and applies RBAC role assignments in a single pass.

> [!NOTE]
> This accelerator supports both **GitHub** (`github`) and **Azure DevOps Git** (`adogit`) as source control back-ends for catalog and image definition synchronization. Set the `SOURCE_CONTROL_PLATFORM` environment variable or pass the `-s` / `-SourceControl` flag to the setup scripts before provisioning.

> [!TIP]
> `infra/settings/workload/devcenter.yaml` is the single configuration entry point for the entire Dev Center topology — projects, pools, catalogs, environment types, and RBAC roles are all declared there, and Bicep loads it at deployment time via `loadYamlContent()`.

## ✨ Features

**Overview**

DevExp-DevBox delivers a complete developer experience platform by composing Azure Dev Center, Key Vault, Log Analytics, virtual networking, and identity management into a single, automated deployment. Every feature maps directly to a dedicated Bicep module under `src/` and is parameterized through YAML files under `infra/settings/`.

> [!TIP]
> **Why This Matters**: Platform engineers can provision a production-grade Dev Box environment — with secure secrets, centralized logging, and role-based access — in a single `azd up` command, reducing onboarding time from days to minutes.

> [!IMPORTANT]
> **How It Works**: Each feature maps to a dedicated Bicep module under `src/`. The YAML configuration files under `infra/settings/` drive runtime parameterization, keeping infrastructure code generic and reusable across environments.

| ✨ Feature | 📝 Description | 📁 Bicep Module |
|---|---|---|
| 🏗️ Dev Center Provisioning | Deploys a fully configured Azure Dev Center (`devexp`) with system-assigned managed identity, catalog item sync, and Azure Monitor agent | `src/workload/core/devCenter.bicep` |
| 📦 Project Management | Creates one or more Dev Center projects, each with dedicated pools, catalogs, environment types, and RBAC assignments | `src/workload/project/project.bicep` |
| 🗂️ Catalog Integration | Syncs Dev Box image definitions and environment definitions from GitHub or Azure DevOps Git repositories on a scheduled basis | `src/workload/core/catalog.bicep`, `src/workload/project/projectCatalog.bicep` |
| 🖥️ Dev Box Pools | Creates role-specific Dev Box pools (e.g., `backend-engineer-0-pool`, `frontend-engineer-0-pool`) mapped to image definitions and VM SKUs via `~Catalog~<catalog>~<imageDefinition>` references | `src/workload/project/projectPool.bicep` |
| 🌐 Network Connectivity | Provisions Managed or Unmanaged virtual networks and attaches them to Dev Center projects via network connections; supports configurable address spaces and subnets | `src/connectivity/connectivity.bicep`, `src/connectivity/vnet.bicep` |
| 🔐 Key Vault Secrets | Creates an Azure Key Vault with RBAC authorization, purge protection, and 7-day soft delete; stores a GitHub Actions or ADO token as `gha-token` for private catalog authentication | `src/security/keyVault.bicep`, `src/security/secret.bicep` |
| 📊 Log Analytics Monitoring | Deploys a Log Analytics Workspace (PerGB2018 SKU) with the `AzureActivity` solution for centralized observability; VNet diagnostic settings forward all logs and metrics | `src/management/logAnalytics.bicep` |
| 🔑 RBAC Role Assignments | Assigns Dev Center (`Contributor`, `User Access Administrator`), project (`Dev Box User`, `Deployment Environment User`), and Key Vault (`Key Vault Secrets User/Officer`) roles to Azure AD groups | `src/identity/devCenterRoleAssignment.bicep`, `src/identity/orgRoleAssignment.bicep` |
| ⚙️ Environment Types | Configures `dev`, `staging`, and `uat` environment types at both Dev Center and project scope with configurable deployment target subscriptions | `src/workload/core/environmentType.bicep`, `src/workload/project/projectEnvironmentType.bicep` |
| 🏷️ Consistent Tagging | Applies `environment`, `division`, `team`, `project`, `costCenter`, `owner`, and `resources` tags to all resource groups and resources for governance and cost allocation | `infra/settings/resourceOrganization/azureResources.yaml` |
| 📜 Cross-Platform Setup Scripts | `setUp.sh` (Linux/macOS) and `setUp.ps1` (Windows) validate tool availability, authenticate with the chosen source control platform, and wire up the azd environment before provisioning | `setUp.sh`, `setUp.ps1` |
| 🧹 Teardown Automation | `cleanSetUp.ps1` removes subscription deployments, service principals, app registrations, and GitHub secrets with `-WhatIf` preview support | `cleanSetUp.ps1` |

## 🚀 Quick Start

**Overview**

The fastest path to a running Dev Box environment is a single `azd up` command. The `preprovision` hook in `azure.yaml` automatically invokes the platform-appropriate setup script to authenticate with your source control provider before Bicep resources are provisioned.

> [!TIP]
> **Why This Matters**: The setup scripts (`setUp.sh` / `setUp.ps1`) validate all required CLI tools are installed and authenticated before any Azure resources are created, preventing partial deployments from missing prerequisites.

> [!NOTE]
> On Windows, the `preprovision` hook in `azure.yaml` attempts to invoke `setUp.sh` via `bash`. Ensure Git Bash or WSL is available on Windows hosts. If `bash` is not found, the hook falls back to executing `setUp.sh` directly.

**Step 1 — Verify required tools**

```bash
az version          # Azure CLI — latest stable
azd version         # Azure Developer CLI — latest stable
gh auth status      # GitHub CLI — required when SOURCE_CONTROL_PLATFORM=github
```

**Step 2 — Clone the repository**

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
```

**Step 3 — Authenticate with Azure**

```bash
az login
azd auth login
```

**Step 4 — Initialize the azd environment**

```bash
azd env new <your-env-name>
# Example (environment name must be 2–10 characters):
azd env new dev
```

**Step 5 — Set required environment variables**

```bash
azd env set AZURE_LOCATION eastus2
azd env set KEY_VAULT_SECRET <your-github-pat-or-ado-token>
# Optional: set source control platform (defaults to "github")
azd env set SOURCE_CONTROL_PLATFORM github
```

**Step 6 — Deploy everything**

```bash
azd up
```

**Expected output:**

```text
  (✓) Done: Resource group: devexp-workload-dev-eastus2-RG
  (✓) Done: Log Analytics Workspace: logAnalytics-<unique>
  (✓) Done: Key Vault: contoso-<unique>-kv
  (✓) Done: DevCenter: devexp
  (✓) Done: Project: eShop
  (✓) Done: Dev Box Pools: backend-engineer-0-pool, frontend-engineer-0-pool

SUCCESS: Your up workflow to provision and deploy to Azure completed in 12m 34s.
```

## 📋 Requirements

**Overview**

DevExp-DevBox requires an active Azure subscription with sufficient quota for Dev Box resources, along with local tooling for authentication and deployment. All prerequisites are validated at the start of `setUp.sh` / `setUp.ps1` via `test_command_availability` / `Test-CommandAvailability` checks before any Azure resources are created.

> [!TIP]
> **Why This Matters**: Missing any prerequisite tool causes the `preprovision` hook to exit with an error before any Azure resources are created, preventing partial deployments. Run `az version && azd version && gh auth status` manually to verify prerequisites before invoking `azd up`.

> [!IMPORTANT]
> **How It Works**: The setup scripts verify each required command is present in `PATH` and that authentication is active before calling `azd provision`. The Bicep deployment enforces region constraints via the `@allowed` decorator on the `location` parameter in `infra/main.bicep` (lines 8–25).

| 🔧 Requirement | 📋 Version / Details | ✅ When Required | 🔗 Reference |
|---|---|---|---|
| ☁️ Azure Subscription | Active subscription with **Owner** or **Contributor + User Access Administrator** rights (subscription-scoped role assignments are created during deployment) | Always | [Azure Portal](https://portal.azure.com) |
| 🔵 Azure CLI (`az`) | Latest stable | Always | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| 🚀 Azure Developer CLI (`azd`) | Latest stable | Always | [Install azd](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) |
| 🐙 GitHub CLI (`gh`) | Latest stable; required for GitHub authentication flow | When `SOURCE_CONTROL_PLATFORM=github` | [Install GitHub CLI](https://cli.github.com/) |
| 🌐 Supported Azure Region | `eastus`, `eastus2`, `westus`, `westus2`, `westus3`, `centralus`, `northeurope`, `westeurope`, `southeastasia`, `australiaeast`, `japaneast`, `uksouth`, `canadacentral`, `swedencentral`, `switzerlandnorth`, `germanywestcentral` | Always | `infra/main.bicep:8-25` |
| 🔑 GitHub PAT or ADO Token | Personal Access Token with `repo` scope for private catalog authentication; stored in Key Vault as `gha-token` | When using private catalogs | `infra/settings/security/security.yaml` |
| 📦 Bicep CLI | Included with Azure CLI 2.20.0+ | Always | [Bicep overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) |
| 🐚 Bash (Windows only) | Git Bash or WSL; the `azure.yaml` preprovision hook runs `setUp.sh` via `bash` on Windows | Windows hosts | [Git for Windows](https://gitforwindows.org/) |

## 📦 Deployment

**Overview**

The deployment pipeline is orchestrated by the Azure Developer CLI using the `azure.yaml` configuration file at the repository root. A `preprovision` hook runs the platform-appropriate setup script to authenticate with the chosen source control platform before Bicep resources are provisioned. The Bicep entry point at `infra/main.bicep` deploys monitoring, security, and workload modules in dependency order at subscription scope.

> [!IMPORTANT]
> **How It Works**: `azd up` executes the `preprovision` hook defined in `azure.yaml`, which invokes `setUp.sh -e <env> -s <platform>` (Linux/macOS) or calls `setUp.sh` via `bash` on Windows. The script validates tool availability, authenticates with GitHub or Azure DevOps, and sets up the environment. After the hook succeeds, `azd provision` deploys the subscription-scoped Bicep template.

> [!TIP]
> **Why This Matters**: The `preprovision` hook ensures source control authentication is in place before any Azure resources are created. This prevents catalog sync failures that would occur if the Dev Center is provisioned without a valid `gha-token` in Key Vault.

**Linux / macOS**

```bash
# Full deploy with GitHub as source control
./setUp.sh -e dev -s github

# Full deploy with Azure DevOps
./setUp.sh -e dev -s adogit

# Then provision infrastructure
azd provision
```

**Windows (PowerShell)**

```powershell
# Full deploy with GitHub as source control
.\setUp.ps1 -EnvName dev -SourceControl github

# Full deploy with Azure DevOps
.\setUp.ps1 -EnvName dev -SourceControl adogit

# Then provision infrastructure
azd provision
```

**One-command deploy (all platforms)**

```bash
azd up
```

**Cleanup / Teardown**

```powershell
# Preview cleanup actions without making changes
.\cleanSetUp.ps1 -EnvName dev -Location eastus2 -WhatIf

# Remove all deployed resources, role assignments, credentials, and GitHub secrets
.\cleanSetUp.ps1 -EnvName dev -Location eastus2

# Custom app registration and GitHub secret names
.\cleanSetUp.ps1 -EnvName dev -Location eastus2 `
  -AppDisplayName "ContosoDevEx GitHub Actions Enterprise App" `
  -GhSecretName "AZURE_CREDENTIALS"
```

> [!WARNING]
> `cleanSetUp.ps1` deletes Azure subscription-level deployments, service principals, app registrations, and GitHub secrets. Always run with `-WhatIf` first to preview actions. This operation is **irreversible**.

## 💻 Usage

**Overview**

After deployment, platform engineers interact with the Dev Center through the Azure portal, Azure CLI, or VS Code Dev Box extension. The YAML configuration files in `infra/settings/` control the shape of the environment — modifying them and re-running `azd provision` applies changes incrementally without recreating existing resources.

> [!TIP]
> **Onboarding a new project**: Add a new entry under the `projects:` array in `infra/settings/workload/devcenter.yaml` with the project name, description, network settings, identity/RBAC, pools, catalogs, and environment types. Then run `azd provision` to deploy.

> [!IMPORTANT]
> **How It Works**: `azd provision` re-evaluates the YAML configuration and reconciles the live Azure state with the desired configuration. Existing resources are updated in-place where possible; new entries are created. Removed entries are not automatically deleted — use `cleanSetUp.ps1` for full teardown.

**Query deployed outputs**

```bash
# Get all azd environment values including Dev Center name and project list
azd env get-values

# Get just the Dev Center name
azd env get-values | grep AZURE_DEV_CENTER_NAME

# Get the list of deployed projects
azd env get-values | grep AZURE_DEV_CENTER_PROJECTS
```

**List Dev Boxes in a project**

```bash
az devcenter dev dev-box list \
  --dev-center-name devexp \
  --project-name eShop
```

**Expected output:**

```json
[
  {
    "name": "my-dev-box",
    "poolName": "backend-engineer-0-pool",
    "provisioningState": "Succeeded",
    "powerState": "Running"
  }
]
```

**Create a Dev Box**

```bash
az devcenter dev dev-box create \
  --dev-center-name devexp \
  --project-name eShop \
  --pool-name backend-engineer-0-pool \
  --name my-dev-box
```

**Add a new catalog to the Dev Center**

Edit `infra/settings/workload/devcenter.yaml`:

```yaml
catalogs:
  - name: 'myNewCatalog'
    type: gitHub
    visibility: public
    uri: 'https://github.com/my-org/my-catalog.git'
    branch: 'main'
    path: './Tasks'
```

Then re-provision:

```bash
azd provision
```

**Add a new Dev Box pool to an existing project**

Edit the target project entry in `infra/settings/workload/devcenter.yaml`:

```yaml
pools:
  - name: 'data-engineer'
    imageDefinitionName: 'eshop-data-dev'
    vmSku: general_i_32c128gb512ssd_v2
```

Then apply:

```bash
azd provision
```

**Update environment name and region**

```bash
azd env set AZURE_ENV_NAME staging
azd env set AZURE_LOCATION westeurope
azd provision
```

## ⚙️ Configuration

**Overview**

All infrastructure behavior is controlled through three YAML files in `infra/settings/`. These files are loaded at Bicep compile time using the `loadYamlContent()` function, making the configuration fully type-safe and validated against JSON Schema files in the same directories. Environment-specific values are injected through `main.parameters.json` via `azd` environment variables.

> [!TIP]
> **Why This Matters**: YAML-driven configuration separates the _what_ (your topology and policies) from the _how_ (Bicep resource definitions). You can onboard a new project, change a VM SKU, or rotate an environment type without touching a single Bicep file.

> [!IMPORTANT]
> **How It Works**: At deployment time, `infra/main.bicep` calls `loadYamlContent('settings/workload/devcenter.yaml')`, `loadYamlContent('settings/security/security.yaml')`, and `loadYamlContent('settings/resourceOrganization/azureResources.yaml')`. The loaded objects are passed as parameters to their respective modules. JSON Schema files (`.schema.json`) in each settings folder provide IDE validation.

**Configuration Files**

| 📁 File | 🏷️ Domain | 🔧 Key Settings | 📐 Schema |
|---|---|---|---|
| 📋 `infra/settings/workload/devcenter.yaml` | Dev Center topology | Dev Center name, projects, pools, catalogs, environment types, RBAC, networking, VM SKUs | `devcenter.schema.json` |
| 🔐 `infra/settings/security/security.yaml` | Key Vault | Key Vault name, SKU, soft delete retention, purge protection, RBAC authorization, secret name | `security.schema.json` |
| 🗂️ `infra/settings/resourceOrganization/azureResources.yaml` | Resource groups | Resource group names, `create` flags, tags (environment, division, team, project, costCenter, owner) | `azureResources.schema.json` |
| ⚙️ `infra/main.parameters.json` | azd parameters | `environmentName` → `${AZURE_ENV_NAME}`, `location` → `${AZURE_LOCATION}`, `secretValue` → `${KEY_VAULT_SECRET}` | — |

**Environment Variables**

| 🔑 Variable | 📝 Description | ✅ Required | 🏷️ Default |
|---|---|---|---|
| `AZURE_ENV_NAME` | Azure Developer CLI environment name; used as the `env` segment in resource group naming (pattern: `<name>-<env>-<region>-RG`). Must be 2–10 characters. | ✅ Yes | — |
| `AZURE_LOCATION` | Azure region for deployment. Must be one of the 16 supported regions enforced by the `@allowed` decorator in `infra/main.bicep`. | ✅ Yes | — |
| `KEY_VAULT_SECRET` | GitHub Personal Access Token or Azure DevOps token stored in Key Vault as the `gha-token` secret. Used by the Dev Center for private catalog synchronization. | ✅ Yes | — |
| `SOURCE_CONTROL_PLATFORM` | Source control platform for catalog and identity setup. Accepted values: `github`, `adogit`. Passed as `-s` to `setUp.sh` or `-SourceControl` to `setUp.ps1`. | Optional | `github` |

**Separate Resource Groups for All Domains**

Edit `infra/settings/resourceOrganization/azureResources.yaml`:

```yaml
workload:
  create: true
  name: devexp-workload
security:
  create: true   # Creates a dedicated security resource group
  name: devexp-security
monitoring:
  create: true   # Creates a dedicated monitoring resource group
  name: devexp-monitoring
```

**Use an Existing Key Vault**

Edit `infra/settings/security/security.yaml`:

```yaml
keyVault:
  create: false   # Skip Key Vault creation; reference an existing vault
  name: my-existing-vault
  secretName: gha-token
```

**Add a New Project**

Add an entry under `projects:` in `infra/settings/workload/devcenter.yaml`:

```yaml
projects:
  - name: 'myNewProject'
    description: 'My new Dev Box project'
    networks:
      type: Managed
      addressSpace: '10.1.0.0/16'
    pools:
      - name: 'fullstack-engineer'
        imageDefinitionName: 'eshop-fullstack-dev'
        vmSku: general_i_32c128gb512ssd_v2
    catalogs:
      - name: 'myProjectCatalog'
        type: gitHub
        visibility: private
        uri: 'https://github.com/my-org/my-project-catalog.git'
        branch: 'main'
        path: '/imageDefinitions'
    environmentTypes:
      - name: 'dev'
      - name: 'staging'
```

Then apply:

```bash
azd provision
```

## 🤝 Contributing

**Overview**

Contributions are welcome. The recommended workflow follows a fork-and-branch pattern with mandatory preview validation before raising a pull request. All configuration changes should be validated against the JSON Schema files in `infra/settings/` using an IDE with YAML Language Server support before committing.

> [!TIP]
> **Why This Matters**: Each YAML settings folder contains a `.schema.json` file that provides IDE auto-complete and validation for the configuration structure. Configure your YAML language server to reference `devcenter.schema.json`, `security.schema.json`, and `azureResources.schema.json` for a guided authoring experience.

> [!IMPORTANT]
> **How It Works**: Pull requests should include a successful `azd provision --preview` (what-if) result as evidence that the Bicep changes produce the expected resource diff. Run `.\cleanSetUp.ps1 -WhatIf` before teardown to validate the cleanup plan.

**Development Workflow**

```bash
# 1. Fork and clone
git clone https://github.com/<your-fork>/DevExp-DevBox.git
cd DevExp-DevBox

# 2. Create a feature branch
git checkout -b feature/my-improvement

# 3. Make configuration or Bicep changes
# Edit files under infra/settings/ or src/

# 4. Preview changes (no resources created)
azd provision --preview

# 5. Deploy to a test environment
azd env new test && azd provision

# 6. Test and validate
az devcenter dev dev-box list --dev-center-name devexp --project-name eShop

# 7. Cleanup test environment
.\cleanSetUp.ps1 -EnvName test -Location eastus2 -WhatIf  # preview first
.\cleanSetUp.ps1 -EnvName test -Location eastus2

# 8. Raise a PR
```

**Project Structure**

```text
DevExp-DevBox/
├── azure.yaml                          # azd project config; defines preprovision hooks for setUp.sh
├── setUp.sh                            # Linux/macOS setup: -e <envName> -s <sourcePlatform> [-h]
├── setUp.ps1                           # Windows setup: -EnvName [string] -SourceControl [github|adogit|""] [-Help]
├── cleanSetUp.ps1                      # Teardown: -EnvName [string] -Location [region] -AppDisplayName [string] -GhSecretName [string] [-WhatIf]
├── package.json                        # Node project manifest
├── infra/
│   ├── main.bicep                      # Subscription-scoped entry point; deploys monitoring, security, workload modules
│   ├── main.parameters.json            # azd parameter bindings: environmentName, location, secretValue
│   └── settings/
│       ├── workload/
│       │   ├── devcenter.yaml          # Dev Center topology: projects, pools, catalogs, env types, RBAC, networking
│       │   └── devcenter.schema.json   # JSON Schema for IDE validation of devcenter.yaml
│       ├── security/
│       │   ├── security.yaml           # Key Vault settings: name, SKU, soft delete, RBAC authorization
│       │   └── security.schema.json    # JSON Schema for IDE validation of security.yaml
│       └── resourceOrganization/
│           ├── azureResources.yaml     # Resource group names, create flags, tags
│           └── azureResources.schema.json
└── src/
    ├── connectivity/                   # VNet, subnet, network connection Bicep modules
    ├── identity/                       # RBAC role assignment Bicep modules
    ├── management/                     # Log Analytics Workspace Bicep module
    ├── security/                       # Key Vault and secret Bicep modules
    └── workload/
        ├── workload.bicep              # Workload orchestration module
        ├── core/                       # Dev Center, catalog, environment type modules
        └── project/                    # Project, pool, project catalog, project env type modules
```

**Contribution Areas**

| 🏷️ Area | 📝 Description | 📁 Target Path |
|---|---|---|
| 🖥️ New VM SKU / Pool | Add a new Dev Box pool with a different VM SKU or image definition | `infra/settings/workload/devcenter.yaml` → `pools:` |
| 🌐 New Region Support | Add a supported Azure region to the `@allowed` list | `infra/main.bicep` — `location` parameter |
| 🗂️ New Catalog Source | Integrate an additional GitHub or ADO Git catalog for environment definitions or image definitions | `infra/settings/workload/devcenter.yaml` → `catalogs:` |
| 🔒 Key Vault Policy | Adjust soft-delete retention, purge protection, or RBAC settings | `infra/settings/security/security.yaml` |
| 🏗️ Bicep Module Improvements | Refactor or extend modules in `src/` to support new Dev Center API features | `src/workload/`, `src/security/`, `src/connectivity/` |

## 📄 License

This project is licensed under the [MIT License](./LICENSE) — Copyright (c) 2025 Evilázaro Alves.

**References**

- 📖 [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- 🚀 [Azure Developer CLI (azd) Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- 🔧 [Bicep Language Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- 🏗️ [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- ⭐ [Microsoft DevExp-DevBox Accelerator](https://github.com/Evilazaro/DevExp-DevBox)
