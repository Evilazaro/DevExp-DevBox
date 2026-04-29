# DevExp-DevBox

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Azure Dev Center](https://img.shields.io/badge/Azure-Dev%20Center-0078d4?logo=microsoftazure)](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
[![IaC: Bicep](https://img.shields.io/badge/IaC-Bicep-blueviolet)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
[![azd: Enabled](https://img.shields.io/badge/azd-enabled-brightgreen)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)

## Description

**DevExp-DevBox** is an accelerator for provisioning enterprise-grade
[Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
environments on Azure. It deploys an **Azure Dev Center** together with
role-specific Dev Box pools, project catalogs, environment types, networking,
and security controls — all from a single `azd up` command.

The accelerator addresses the problem of inconsistent, manually configured
developer workstations by providing a repeatable, configuration-as-code approach
to developer environment management. Teams gain on-demand, pre-built cloud
workstations that match the exact tools and network policies required for each
role.

The solution is built on **Azure Bicep** for infrastructure as code, the **Azure
Developer CLI (azd)** for end-to-end provisioning, and **YAML** configuration
files that let platform engineers customize Dev Center settings, project
definitions, and security policies without modifying Bicep templates directly.

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

| Feature                             | Description                                                                                                         |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 🚀 One-command provisioning         | Run `azd up` to deploy the complete Dev Box environment end-to-end.                                                 |
| 🔐 Role-based access control        | Assigns least-privilege RBAC roles to Dev Managers, Dev Box Users, and deployment environments out of the box.      |
| 📁 Multi-project support            | Define multiple Dev Box projects (e.g., `eShop`) with independent pools, catalogs, and environment types.           |
| 🐙 Source control catalog sync      | Automatically syncs Dev Box image definitions and environment definitions from GitHub or Azure DevOps repositories. |
| 🌐 Environment lifecycle management | Ships with `dev`, `staging`, and `uat` environment types aligned to the software development lifecycle.             |
| 🔑 Centralized secret management    | Stores source control access tokens in **Azure Key Vault** with RBAC authorization and soft-delete protection.      |
| 📊 Built-in observability           | Integrates **Log Analytics** diagnostic settings on all major resources for centralized monitoring.                 |
| 🕸️ Network isolation                | Provisions a dedicated **Virtual Network** per project to isolate Dev Box traffic.                                  |

## Architecture

The diagram below shows the high-level topology of the system, the human actors
that interact with it, and the primary data and control flows between
components.

> [!NOTE] Solid arrows represent synchronous interactions. Dashed arrows
> represent asynchronous or event-driven interactions.

```mermaid
---
config:
  description: "High-level architecture diagram showing actors, primary flows, and major components."
  theme: base
  theme: base
  themeVariables:
    textColor: "#242424"
    primaryColor: "#f5f5f5"
    primaryTextColor: "#FFFFFF"
    primaryBorderColor: "#e0e0e0"
---
flowchart TB

  %% ── Actors ────────────────────────────────────────────────────────────────
  DevManager(["👔 Dev Manager<br/>Platform Engineering"])
  Developer(["👩‍💻 Developer<br/>Dev Box User"])
  DevOps(["⚙️ DevOps Engineer<br/>azd CLI"])

  %% ── External Systems ──────────────────────────────────────────────────────
  GitHub(["🐙 GitHub /<br/>Azure DevOps"])

  %% ── Azure Subscription ────────────────────────────────────────────────────
  subgraph SUB["☁️ Azure Subscription"]

    subgraph MON["📊 Monitoring"]
      LogAnalytics[("📈 Log Analytics<br/>Workspace")]
    end

    subgraph SEC["🔒 Security"]
      KeyVault[("🔑 Azure Key Vault")]
    end

    subgraph WKL["🖥️ Workload"]
      DevCenter("🏢 Azure Dev Center")

      subgraph PROJ["📁 Dev Box Project"]
        Catalog("📚 Catalog")
        EnvType("🌐 Environment Types<br/>dev / staging / uat")
        Pool("🖥️ Dev Box Pool<br/>backend / frontend")
        VNet("🕸️ Virtual Network")
      end
    end

  end

  %% ── Interactions ──────────────────────────────────────────────────────────
  DevOps -- "azd up<br/>(provisions)" --> SUB
  DevManager -- "configures RBAC<br/>& pool settings" --> DevCenter
  Developer -- "requests<br/>Dev Box" --> Pool
  DevCenter -- "manages<br/>projects" --> PROJ
  GitHub -. "syncs catalogs<br/>(async)" .-> Catalog
  Catalog -- "provides image<br/>& env definitions" --> Pool
  EnvType -- "scopes<br/>environment" --> Pool
  Pool -- "deploys into" --> VNet
  VNet -- "network<br/>connection" --> DevCenter
  DevCenter -- "reads secrets" --> KeyVault
  DevCenter -. "sends diagnostics<br/>(async)" .-> LogAnalytics
  Pool -. "sends diagnostics<br/>(async)" .-> LogAnalytics

  %% ── Styles ────────────────────────────────────────────────────────────────
  classDef actor fill:#cce0f5,stroke:#0f6cbd,color:#242424
  classDef component fill:#0f6cbd,stroke:#115ea3,color:#ffffff
  classDef security fill:#fdf3f4,stroke:#c50f1f,color:#242424
  classDef monitoring fill:#f1faf1,stroke:#107c10,color:#242424
  classDef external fill:#f5f5f5,stroke:#616161,color:#242424
  classDef inner fill:#e8f4fd,stroke:#0f6cbd,color:#242424

  class DevManager,Developer,DevOps actor
  class DevCenter component
  class KeyVault security
  class LogAnalytics monitoring
  class GitHub external
  class Catalog,EnvType,Pool,VNet inner
```

**Architecture components:**

| Component                   | Role                                                                                                        |
| --------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Azure Dev Center**        | Central hub that hosts projects, catalogs, and environment types.                                           |
| **Dev Box Project**         | Isolated organizational unit (e.g., `eShop`) with its own pools, catalogs, and RBAC.                        |
| **Dev Box Pool**            | Collection of pre-configured cloud workstations scoped to a role (`backend-engineer`, `frontend-engineer`). |
| **Catalog**                 | GitHub or Azure DevOps repository that provides image definitions and environment definitions.              |
| **Environment Types**       | Lifecycle stages (`dev`, `staging`, `uat`) available to developers in a project.                            |
| **Azure Key Vault**         | Stores the source control access token used by the Dev Center for catalog sync.                             |
| **Log Analytics Workspace** | Receives diagnostic logs and metrics from Dev Center and Dev Box Pools.                                     |
| **Virtual Network**         | Provides network isolation for Dev Boxes within a project.                                                  |

## Technologies Used

| Technology                                                                                                             | Type                   | Purpose                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------- |
| [Azure Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)                           | Infrastructure as Code | Declares and deploys all Azure resources.                                               |
| [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)            | Developer toolchain    | Orchestrates end-to-end environment provisioning with `azd up`.                         |
| [Azure Dev Center](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)                 | Azure service          | Core platform that hosts Dev Box projects, pools, and catalogs.                         |
| [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/basic-concepts)                            | Azure service          | Stores secrets with RBAC authorization and soft-delete protection.                      |
| [Log Analytics Workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) | Azure service          | Centralized log aggregation and monitoring for all deployed resources.                  |
| [Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)             | Azure service          | Network isolation per project for Dev Box traffic.                                      |
| [PowerShell](https://learn.microsoft.com/en-us/powershell/)                                                            | Scripting language     | Windows-based setup automation (`setUp.ps1`, `cleanSetUp.ps1`).                         |
| [Bash](https://www.gnu.org/software/bash/)                                                                             | Scripting language     | Linux/macOS setup automation (`setUp.sh`).                                              |
| YAML                                                                                                                   | Configuration language | Declarative resource configuration for Dev Center, security, and resource organization. |

## Quick Start

### Prerequisites

| Prerequisite                                                                                                   | Minimum Version | Notes                                                                                 |
| -------------------------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------- |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)                                     | 2.65.0          | Required for authentication and resource management.                                  |
| [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) | 1.11.0          | Required for `azd up` provisioning.                                                   |
| [GitHub CLI](https://cli.github.com/)                                                                          | 2.x             | Required when using `github` as the source control platform.                          |
| Azure subscription                                                                                             | —               | Must have `Contributor` and `User Access Administrator` rights at subscription scope. |

> [!IMPORTANT] The deployment identity (service principal or user) must hold
> **Contributor** and **User Access Administrator** on the target Azure
> subscription so that the Dev Center managed identity can receive its role
> assignments.

### Installation

1. **Clone the repository.**

   ```bash
   git clone https://github.com/Evilazaro/DevExp-DevBox.git
   cd DevExp-DevBox
   ```

2. **Log in to Azure.**

   ```bash
   azd auth login
   ```

3. **Set the source control platform** (optional — defaults to `github`).

   ```bash
   export SOURCE_CONTROL_PLATFORM=github   # bash / zsh
   # or on Windows PowerShell:
   $env:SOURCE_CONTROL_PLATFORM = "github"
   ```

4. **Provision and deploy all resources.**

   ```bash
   azd up
   ```

   The `azd up` command runs the `setUp.sh` / `setUp.ps1` preprovision hook,
   prompts for the required parameters, and then deploys all Bicep modules.

### Minimal Working Example

```bash
# Authenticate, provision a dev environment, and confirm the Dev Center name
azd auth login
azd up --environment dev

# Expected output (values will differ):
# SUCCESS: Your up workflow to provision and deploy to Azure completed in 8 minutes 42 seconds.
# Outputs:
#   AZURE_DEV_CENTER_NAME   = devexp
#   AZURE_KEY_VAULT_NAME    = contoso-<suffix>
#   AZURE_LOG_ANALYTICS_WORKSPACE_NAME = logAnalytics-<suffix>
```

## Configuration

All configuration is stored in YAML files under `infra/settings/`. Edit these
files before running `azd up` to customise the deployment.

| Option                               | File                                                      | Default           | Description                                              |
| ------------------------------------ | --------------------------------------------------------- | ----------------- | -------------------------------------------------------- |
| `workload.name`                      | `infra/settings/resourceOrganization/azureResources.yaml` | `devexp-workload` | Name of the workload resource group.                     |
| `workload.create`                    | `infra/settings/resourceOrganization/azureResources.yaml` | `true`            | Set to `false` to use an existing resource group.        |
| `keyVault.name`                      | `infra/settings/security/security.yaml`                   | `contoso`         | Base name for the Azure Key Vault.                       |
| `keyVault.secretName`                | `infra/settings/security/security.yaml`                   | `gha-token`       | Name of the secret stored in Key Vault.                  |
| `keyVault.softDeleteRetentionInDays` | `infra/settings/security/security.yaml`                   | `7`               | Retention period (days) for deleted secrets.             |
| `name` (Dev Center)                  | `infra/settings/workload/devcenter.yaml`                  | `devexp`          | Name of the Azure Dev Center instance.                   |
| `catalogItemSyncEnableStatus`        | `infra/settings/workload/devcenter.yaml`                  | `Enabled`         | Enables automatic catalog item synchronisation.          |
| `SOURCE_CONTROL_PLATFORM`            | Environment variable                                      | `github`          | Source control platform: `github` or `adogit`.           |
| `AZURE_ENV_NAME`                     | Environment variable                                      | _(prompted)_      | Environment name used for resource naming (e.g., `dev`). |

> [!TIP] Override `SOURCE_CONTROL_PLATFORM` before calling `azd up` if your
> organization uses **Azure DevOps** instead of GitHub:
>
> ```powershell
> $env:SOURCE_CONTROL_PLATFORM = "adogit"
> azd up
> ```

### Example Override Snippet

```yaml
# infra/settings/security/security.yaml
keyVault:
  name: mycompany # Change to a globally unique name
  secretName: ado-token # Change when using Azure DevOps
  softDeleteRetentionInDays: 30
  enablePurgeProtection: true
```

## Deployment

Follow these steps to deploy the accelerator to a production or staging Azure
subscription.

1. **Authenticate** with Azure using the Azure Developer CLI.

   ```bash
   azd auth login
   ```

2. **Review and edit** the YAML configuration files in `infra/settings/` to
   match your organization's naming conventions, network addressing, and role
   assignments.

3. **Set required environment variables.**

   ```bash
   export AZURE_ENV_NAME=prod
   export SOURCE_CONTROL_PLATFORM=github
   ```

4. **Run `azd up`** to provision all infrastructure.

   ```bash
   azd up
   ```

   `azd up` runs the `setUp.sh` (Linux/macOS) or `setUp.ps1` (Windows)
   preprovision hook, which authenticates with GitHub or Azure DevOps and
   creates the required federated credentials before Bicep deployment begins.

5. **Verify outputs.** After a successful deployment, `azd` prints the following
   outputs:

   | Output                               | Description                                           |
   | ------------------------------------ | ----------------------------------------------------- |
   | `AZURE_DEV_CENTER_NAME`              | Name of the provisioned Dev Center.                   |
   | `AZURE_DEV_CENTER_PROJECTS`          | Array of project names deployed under the Dev Center. |
   | `AZURE_KEY_VAULT_NAME`               | Name of the Key Vault storing the access token.       |
   | `AZURE_KEY_VAULT_ENDPOINT`           | URI of the Key Vault.                                 |
   | `AZURE_LOG_ANALYTICS_WORKSPACE_NAME` | Name of the Log Analytics Workspace.                  |

6. **Clean up** all resources when no longer needed.

   ```powershell
   .\cleanSetUp.ps1 -EnvName prod -Location eastus2
   ```

> [!WARNING] Running `cleanSetUp.ps1` deletes resource groups, role assignments,
> and GitHub secrets. This action is irreversible. Back up any required secrets
> before running the cleanup script.

## Usage

### Request a Dev Box (Developer)

Developers access their Dev Box through the
[Microsoft Dev Box portal](https://devbox.microsoft.com) after an administrator
has provisioned a pool and assigned the **Dev Box User** role.

```bash
# Open the developer portal in a browser
# URL: https://devbox.microsoft.com
# Select your project (e.g., eShop) and pool (e.g., backend-engineer)
# Click "New Dev Box" and wait for provisioning to complete (~15 minutes)
```

Expected outcome: a fully configured cloud workstation is available in the
developer portal with Single Sign-On and local administrator rights enabled.

### Add a New Project

Add a new entry under `projects:` in `infra/settings/workload/devcenter.yaml`
and re-run `azd up`:

```yaml
# infra/settings/workload/devcenter.yaml
projects:
  - name: 'my-new-project'
    description: 'Dev Box project for the payments team.'
    network:
      name: my-new-project
      create: true
      resourceGroupName: 'my-new-project-connectivity-RG'
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.1.0.0/16
      subnets:
        - name: my-new-project-subnet
          properties:
            addressPrefix: 10.1.1.0/24
    # ... identity, pools, environmentTypes, catalogs, tags
```

```bash
# Apply the change
azd up
# Expected output: new project appears in AZURE_DEV_CENTER_PROJECTS
```

### Clean Up the Environment

```powershell
# Windows PowerShell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
# Expected output: all resource groups, role assignments, and GitHub secrets removed
```

## Contributing

Contributions are welcome. To contribute to this project:

1. **Open an issue** to report a bug or propose a feature before submitting a
   pull request.
2. **Fork** the repository and create a feature branch from `main`.
3. **Commit** your changes with a clear, descriptive commit message.
4. **Open a pull request** targeting the `main` branch and describe the changes
   you made and the problem they solve.

> [!NOTE] There is no `CONTRIBUTING.md` file in this repository at this time.
> Check the [Issues](https://github.com/Evilazaro/DevExp-DevBox/issues) tab to
> see open work items and discussions before starting new work.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE)
file for the full license text.
