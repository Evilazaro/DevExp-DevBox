# DevExp-DevBox — Azure Dev Box Adoption & Deployment Accelerator

![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Bicep](https://img.shields.io/badge/Bicep-IaC-0078D4?style=flat-square&logo=microsoftazure)
![Azure](https://img.shields.io/badge/Azure-Dev%20Box-0078D4?style=flat-square&logo=microsoftazure)

**Overview**

> [!NOTE] This accelerator deploys a production-ready Azure Dev Box environment
> in a single command using Azure Developer CLI (`azd`). It follows the
> Microsoft Cloud Adoption Framework and Azure Landing Zone principles for
> enterprise-grade developer workstation management.

DevExp-DevBox solves the challenge of provisioning and managing centralized,
secure, cloud-hosted developer workstations across engineering teams. Platform
engineers, DevOps leads, and IT administrators use this accelerator to deliver
role-specific Dev Box environments — with consistent tooling, network isolation,
and identity governance — without months of manual configuration.

The accelerator orchestrates Azure Dev Center, Dev Box pools, Key Vault, Log
Analytics, and Virtual Network resources through modular Bicep templates driven
entirely by YAML configuration files. Each team and project receives
pre-configured Dev Box pools tailored to their role (backend, frontend), with
Microsoft Entra ID integration for identity, RBAC for access control, and
centralized monitoring for operational visibility.

## 📑 Table of Contents

- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Contributing](#-contributing)
- [License](#-license)

## 🏗️ Architecture

**Overview**

This architecture follows Azure Landing Zone principles to segregate resources
by function — security, monitoring, and workload — into dedicated resource
groups. The design enables teams to manage Dev Box environments independently
while maintaining centralized governance, audit trails, and network controls.

Components are organized in a layered, modular pattern: the orchestration layer
(`infra/main.bicep`) coordinates subscription-scoped deployments across three
resource groups, while individual Bicep modules under `src/` handle each domain
— identity, connectivity, security, monitoring, and workload. Configuration is
externalized into validated YAML files, enabling environment customization
without code changes.

```mermaid
---
title: "DevExp-DevBox Platform Architecture"
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
    curve: cardinal
---
flowchart TB
    accTitle: DevExp-DevBox Platform Architecture
    accDescr: Azure Dev Box accelerator components organized by Landing Zone resource groups with relationships and data flows

    %% ═══════════════════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v1.1
    %% (Semantic + Structural + Font + Accessibility Governance)
    %% ═══════════════════════════════════════════════════════════════════════════
    %% PHASE 1 - FLUENT UI: All styling uses approved Fluent UI palette only
    %% PHASE 2 - GROUPS: Every subgraph has semantic color via style directive
    %% PHASE 3 - COMPONENTS: Every node has semantic classDef + icon prefix
    %% PHASE 4 - ACCESSIBILITY: accTitle/accDescr present, WCAG AA contrast
    %% PHASE 5 - STANDARD: Governance block present, classDefs centralized
    %% ═══════════════════════════════════════════════════════════════════════════

    subgraph platform["🏢 DevExp-DevBox Platform"]

        subgraph orchestration["⚙️ Orchestration Layer"]
            AZD("🛠️ Azure Developer CLI"):::core
            MAIN("📋 main.bicep"):::core
            YAML("📁 YAML Configuration"):::data
        end

        subgraph securityRG["🔒 Security Resource Group"]
            KV("🔐 Azure Key Vault"):::danger
            SECRET("🔑 GitHub Token Secret"):::danger
        end

        subgraph monitoringRG["📊 Monitoring Resource Group"]
            LOG("📈 Log Analytics Workspace"):::warning
            DIAG("📊 Diagnostic Settings"):::warning
        end

        subgraph workloadRG["🚀 Workload Resource Group"]
            DC("🏢 Azure Dev Center"):::core
            CAT("📦 Catalogs"):::success
            ENV("🌍 Environment Types"):::success
            PROJ("📋 Projects"):::core

            subgraph devboxes["💻 Dev Box Pools"]
                BACKEND("⚙️ Backend Engineer Pool"):::success
                FRONTEND("🎨 Frontend Engineer Pool"):::success
            end
        end

        subgraph identityLayer["🔑 Identity & Access"]
            ENTRA("👤 Microsoft Entra ID"):::data
            RBAC("🛡️ RBAC Assignments"):::data
        end

        subgraph connectivityLayer["🌐 Connectivity"]
            VNET("🔗 Virtual Network"):::neutral
            SUBNET("📡 Subnet"):::neutral
            NC("🌐 Network Connection"):::neutral
        end

    end

    AZD -->|"triggers"| MAIN
    YAML -->|"configures"| MAIN
    MAIN -->|"deploys"| KV
    MAIN -->|"deploys"| LOG
    MAIN -->|"deploys"| DC
    KV -->|"stores"| SECRET
    SECRET -->|"authenticates"| CAT
    LOG -->|"collects from"| DIAG
    DIAG -->|"monitors"| DC
    DIAG -->|"monitors"| KV
    DC -->|"hosts"| CAT
    DC -->|"defines"| ENV
    DC -->|"manages"| PROJ
    PROJ -->|"provisions"| BACKEND
    PROJ -->|"provisions"| FRONTEND
    ENTRA -->|"authenticates"| DC
    RBAC -->|"authorizes"| PROJ
    VNET -->|"contains"| SUBNET
    SUBNET -->|"connects via"| NC
    NC -->|"attaches to"| PROJ

    classDef neutral  fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core     fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef success  fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef warning  fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    classDef danger   fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef data     fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130

    style platform fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style orchestration fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style securityRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style monitoringRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style workloadRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style devboxes fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style identityLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style connectivityLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
```

**Component Responsibilities**

| Component                  | Purpose                                                     | Azure Service                              |
| -------------------------- | ----------------------------------------------------------- | ------------------------------------------ |
| 🛠️ **Azure Developer CLI** | Orchestrates end-to-end provisioning via `azd up`           | Azure Developer CLI                        |
| 🔐 **Key Vault**           | Stores GitHub PAT for private catalog authentication        | `Microsoft.KeyVault/vaults`                |
| 📈 **Log Analytics**       | Centralized monitoring, diagnostics, and audit logging      | `Microsoft.OperationalInsights/workspaces` |
| 🏢 **Dev Center**          | Manages Dev Box definitions, catalogs, and projects         | `Microsoft.DevCenter/devcenters`           |
| 📋 **Projects**            | Team-scoped Dev Box pools with role-specific configurations | `Microsoft.DevCenter/projects`             |
| 💻 **Dev Box Pools**       | Pre-configured virtual workstations by engineering role     | `Microsoft.DevCenter/projects/pools`       |
| 🔑 **Entra ID + RBAC**     | Identity governance and least-privilege access control      | Microsoft Entra ID                         |
| 🌐 **Virtual Network**     | Network isolation with managed or custom VNet support       | `Microsoft.Network/virtualNetworks`        |

## ✨ Features

**Overview**

This accelerator provides a comprehensive set of capabilities designed to reduce
the time from zero to a fully governed Dev Box platform from weeks to minutes.
Features are organized around five pillars: infrastructure automation, security,
monitoring, identity governance, and developer experience.

Each feature integrates with the others through the modular Bicep architecture
and YAML-driven configuration. For example, enabling a new project automatically
provisions its Dev Box pools, network connections, RBAC assignments, and
diagnostic settings — all from a single YAML entry.

| Feature                            | Description                                                                                                                                | Benefits                                                                |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| ⚡ **One-Command Deployment**      | Provisions the entire Dev Box platform with `azd up`, including resource groups, Key Vault, Log Analytics, Dev Center, projects, and pools | Eliminates manual resource creation and reduces deployment errors       |
| 📁 **YAML-Driven Configuration**   | All resources configured via validated YAML files with JSON Schema support (`devcenter.yaml`, `security.yaml`, `azureResources.yaml`)      | Enables environment customization without modifying Bicep code          |
| 🔒 **Enterprise Security**         | Key Vault with RBAC authorization, purge protection, soft delete, and secure GitHub token storage for private catalog access               | Meets compliance requirements with zero hard-coded secrets              |
| 📊 **Centralized Monitoring**      | Log Analytics workspace with diagnostic settings on Key Vault and Dev Center, activity logs, and all-metrics collection                    | Provides operational visibility and audit trails across all resources   |
| 🔑 **Identity Governance**         | Microsoft Entra ID integration with system-assigned managed identities, Azure AD group-based RBAC, and least-privilege role assignments    | Enforces zero-trust principles with automated access control            |
| 🌐 **Network Isolation**           | Managed or unmanaged Virtual Network support per project with configurable subnets and Azure AD-joined network connections                 | Ensures secure, isolated network environments for each team             |
| 🏢 **Multi-Project Support**       | Deploy multiple projects within a single Dev Center, each with independent pools, catalogs, environment types, and RBAC                    | Scales to support multiple teams with distinct configurations           |
| 💻 **Role-Specific Dev Boxes**     | Pre-configured Dev Box pools per engineering role (backend, frontend) with tailored VM SKUs, images, and tooling                           | Developers receive workstations optimized for their responsibilities    |
| 📦 **Catalog Integration**         | DevCenter-level and project-level catalogs from GitHub or Azure DevOps Git repositories with scheduled sync                                | Centralizes image definitions and environment templates as code         |
| 🌍 **Multi-Environment Lifecycle** | Environment types for dev, staging, and UAT with configurable deployment targets per project                                               | Supports the full software development lifecycle from a single platform |

## 📋 Prerequisites

**Overview**

Before deploying the accelerator, you need an Azure subscription with sufficient
permissions, several CLI tools installed locally, and a GitHub personal access
token if using private catalogs. These requirements ensure the setup scripts can
authenticate, provision resources, and configure identity assignments.

Meeting all prerequisites takes approximately 15 minutes for a fresh
workstation. The setup scripts validate tool availability automatically and
provide clear error messages if any dependency is missing.

> [!IMPORTANT] You must have **Owner** or **Contributor + User Access
> Administrator** permissions on your Azure subscription. The deployment creates
> subscription-scoped role assignments that require elevated privileges.

| Requirement                | Minimum Version     | Purpose                                               | More Information                                                                                                                    |
| -------------------------- | ------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| ☁️ **Azure Subscription**  | Active subscription | Target for all resource deployments                   | [Create a free account](https://azure.microsoft.com/free/)                                                                          |
| 🛠️ **Azure CLI**           | 2.60+               | Azure authentication and resource management          | [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)                                                        |
| 🛠️ **Azure Developer CLI** | 1.9+                | Orchestrates infrastructure provisioning via `azd up` | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)                                          |
| 🛠️ **GitHub CLI**          | 2.40+               | GitHub authentication and token management            | [Install GitHub CLI](https://cli.github.com/)                                                                                       |
| ⚙️ **PowerShell**          | 5.1+                | Required by `azd` preprovision hook on Windows        | [Install PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)                                |
| ⚙️ **Bash**                | 5.0+                | Required by `azd` preprovision hook (`setUp.sh`)      | Pre-installed on most Unix systems                                                                                                  |
| 🔐 **GitHub PAT**          | —                   | Authentication for private catalog repositories       | [Create a PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) |

## 🚀 Getting Started

**Overview**

The entire platform deploys with a single command: `azd up`. The Azure Developer
CLI orchestrates everything — authentication validation, environment setup,
GitHub token configuration, and Bicep provisioning — through a `preprovision`
hook. The setup scripts (`setUp.ps1`, `setUp.sh`) are **not** run manually; they
execute automatically as `azd` lifecycle hooks defined in `azure-pwh.yaml`
(Windows) and `azure.yaml` (Linux/macOS).

The deployment is fully idempotent — running `azd up` again updates existing
resources without duplication. The entire process completes in approximately
8–15 minutes depending on the Azure region.

### How It Works

When you run `azd up`, the following happens automatically:

1. **Preprovision hook** executes the setup script, which:
   - Validates that all required CLI tools are installed (`az`, `azd`, `gh`)
   - Verifies Azure and GitHub authentication
   - Creates or reuses the `azd` environment
   - Securely retrieves and stores the GitHub PAT for private catalog access
2. **Bicep provisioning** deploys all infrastructure at subscription scope,
   creating three resource groups (workload, security, monitoring) and all
   associated resources

### Deploy

**Step 1 — Clone the repository**

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
```

**Step 2 — Authenticate**

```bash
az login
azd auth login
gh auth login
```

**Step 3 — Provision and deploy**

```bash
azd up
```

`azd` prompts for environment name, Azure subscription, and location if not
already configured. The `preprovision` hook runs automatically before
provisioning begins.

**Expected output:**

```text
Running preprovision hook → setUp.sh
  ✅ All required tools found (az, azd, gh)
  ✅ GitHub authentication successful
  ✅ Azure Developer CLI environment created
  ✅ Environment variables configured

Provisioning Azure resources (azd provision)

SUCCESS: Your Azure resources have been provisioned.
 - Resource Group: devexp-workload-dev-eastus2-RG
 - Dev Center: devexp-devcenter
 - Key Vault: contoso-xxxxxxxx-kv
```

### Platform-Specific Configuration

| Platform           | azd Config       | Hook Shell      | Setup Script Invoked    |
| ------------------ | ---------------- | --------------- | ----------------------- |
| 🖥️ **Windows**     | `azure-pwh.yaml` | PowerShell 5.1+ | `setUp.sh` (via `bash`) |
| 🐧 **Linux/macOS** | `azure.yaml`     | Bash 5.0+       | `setUp.sh`              |

> [!NOTE] On Windows, the `azure-pwh.yaml` preprovision hook uses PowerShell to
> invoke `setUp.sh` through `bash`. Ensure Windows Subsystem for Linux (WSL) or
> Git Bash is available.

### Verify Deployment

```bash
az devcenter admin dev-center list --resource-group "devexp-workload-dev-eastus2-RG" --output table
```

**Expected output:**

```text
Name               Location    ProvisioningState
-----------------  ----------  -------------------
devexp-devcenter   eastus2     Succeeded
```

## 💻 Usage

**Overview**

After deployment, platform engineers manage the Dev Box environment through
Azure CLI commands, the Azure portal, or by updating the YAML configuration
files and rerunning `azd up`. Developers access their Dev Boxes through the
Microsoft Dev Box developer portal or the Windows App.

Day-to-day operations include onboarding new projects, adding Dev Box pools,
managing environment types, and monitoring resource health. All operational
changes flow through the same YAML-driven workflow used in initial deployment.

### Managing Projects

List deployed projects in the Dev Center:

```bash
az devcenter admin project list --dev-center-name "devexp-devcenter" --resource-group "devexp-workload-dev-eastus2-RG" --output table
```

**Expected output:**

```text
Name    Location    DevCenterName      ProvisioningState
------  ----------  -----------------  -------------------
eShop   eastus2     devexp-devcenter   Succeeded
```

### Managing Dev Box Pools

List available Dev Box pools in a project:

```bash
az devcenter admin pool list --project-name "eShop" --resource-group "devexp-workload-dev-eastus2-RG" --output table
```

**Expected output:**

```text
Name               DevBoxDefinition          VmSku
-----------------  ------------------------  ----------------------------
backend-engineer   eShop-backend-engineer    general_i_32c128gb512ssd_v2
frontend-engineer  eShop-frontend-engineer   general_i_16c64gb256ssd_v2
```

### Accessing Dev Boxes (Developer Portal)

Developers connect to their Dev Boxes through the Microsoft Dev Box portal at
`https://devbox.microsoft.com`. Team members assigned to the appropriate Entra
ID groups (e.g., "eShop Developers") can create and manage their Dev Box
instances directly.

### Cleanup

> [!WARNING] Cleanup permanently deletes all provisioned resources, role
> assignments, and associated Entra ID service principals. This action cannot be
> undone.

To remove all provisioned resources, including service principals and GitHub
secrets:

```powershell
.\cleanSetUp.ps1 -EnvName "dev"
```

**Expected output:**

```text
✅ Deleted resource groups
✅ Removed role assignments
✅ Cleaned up service principals
✅ Environment 'dev' removed
```

## 🔧 Configuration

**Overview**

The accelerator uses a YAML-first configuration model validated by JSON Schemas.
All resource definitions, feature toggles, and environment settings live in
three YAML files under `infra/settings/`. This design separates infrastructure
logic (Bicep modules) from environment-specific values (YAML), enabling teams to
customize deployments without modifying any template code.

Configuration changes take effect on the next `azd up` execution. The JSON
Schema files provide inline validation in editors like VS Code, catching
configuration errors before deployment.

> [!TIP] Open the YAML files in VS Code with the YAML extension installed. The
> `$schema` reference at the top of each file enables autocomplete and inline
> validation automatically.

### Configuration Files

| File                                                         | Purpose                            | Key Settings                                                            |
| ------------------------------------------------------------ | ---------------------------------- | ----------------------------------------------------------------------- |
| 📁 `infra/settings/resourceOrganization/azureResources.yaml` | Resource group organization        | Resource group names, Landing Zone tags, creation toggles               |
| 🔒 `infra/settings/security/security.yaml`                   | Key Vault configuration            | Vault name, secret name, purge protection, soft delete, RBAC            |
| ⚙️ `infra/settings/workload/devcenter.yaml`                  | Dev Center and project definitions | Dev Center name, catalogs, environment types, projects, pools, identity |

### Environment Variables

The following environment variables are set by the setup script and consumed by
`azd`:

| Variable              | Description                                       | Example            |
| --------------------- | ------------------------------------------------- | ------------------ |
| 🌍 `AZURE_ENV_NAME`   | Environment name for resource naming              | `dev`              |
| 🌍 `AZURE_LOCATION`   | Azure region for deployment                       | `eastus2`          |
| 🔐 `KEY_VAULT_SECRET` | GitHub personal access token for private catalogs | `ghp_xxxxxxxxxxxx` |

### Resource Organization (`azureResources.yaml`)

Defines the three resource groups following Azure Landing Zone segregation by
function:

| Resource Group | Purpose                                 | Key Settings             |
| -------------- | --------------------------------------- | ------------------------ |
| **Workload**   | Dev Center, projects, and Dev Box pools | `name`, `create`, `tags` |
| **Security**   | Key Vault for secret management         | `name`, `create`, `tags` |
| **Monitoring** | Log Analytics and diagnostic settings   | `name`, `create`, `tags` |

Set `create: false` to skip creation of any resource group when targeting
existing groups in brownfield environments.

### Security (`security.yaml`)

Configures Azure Key Vault for storing the GitHub PAT used by private catalog
authentication:

| Setting                              | Default     | Description                                |
| ------------------------------------ | ----------- | ------------------------------------------ |
| `keyVault.name`                      | `contoso`   | Globally unique Key Vault name prefix      |
| `keyVault.secretName`                | `gha-token` | Secret name for the GitHub PAT             |
| `keyVault.enablePurgeProtection`     | `true`      | Prevents permanent deletion of secrets     |
| `keyVault.enableSoftDelete`          | `true`      | Enables recovery of deleted secrets        |
| `keyVault.softDeleteRetentionInDays` | `7`         | Retention period for soft-deleted secrets  |
| `keyVault.enableRbacAuthorization`   | `true`      | Uses Azure RBAC instead of access policies |

### Dev Center & Projects (`devcenter.yaml`)

Central configuration for the Dev Center resource, catalogs, environment types,
and project definitions:

| Setting                                | Description                                     |
| -------------------------------------- | ----------------------------------------------- |
| `name`                                 | Dev Center resource name                        |
| `catalogItemSyncEnableStatus`          | Enable/disable catalog item synchronization     |
| `microsoftHostedNetworkEnableStatus`   | Enable/disable Microsoft-hosted network support |
| `installAzureMonitorAgentEnableStatus` | Enable/disable Azure Monitor agent installation |
| `identity.type`                        | Managed identity type (`SystemAssigned`)        |

Each project entry under `projects:` supports:

| Block              | Purpose                                                             |
| ------------------ | ------------------------------------------------------------------- |
| `network`          | VNet configuration — type, address prefixes, subnets                |
| `identity`         | RBAC role assignments via Entra ID group membership                 |
| `pools`            | Dev Box pool definitions with VM SKU and image references           |
| `environmentTypes` | Lifecycle environments available to the project (dev, staging, UAT) |
| `catalogs`         | Git-based catalog sources for images and environment definitions    |

### Adding a New Project

Add a new project entry to `infra/settings/workload/devcenter.yaml`:

```yaml
projects:
  - name: 'newProject'
    description: 'New team project'
    network:
      name: newProject
      create: true
      resourceGroupName: 'newProject-connectivity-RG'
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.1.0.0/16
      subnets:
        - name: newProject-subnet
          properties:
            addressPrefix: 10.1.1.0/24
    pools:
      - name: 'developer'
        imageDefinitionName: 'newProject-developer'
        vmSku: general_i_32c128gb512ssd_v2
```

Then run `azd up` to apply the changes.

### Project Structure

```text
.
├── infra/
│   ├── main.bicep                          # Subscription-scoped orchestration
│   ├── main.parameters.json                # azd parameter mapping
│   └── settings/
│       ├── resourceOrganization/
│       │   ├── azureResources.yaml         # Resource group definitions
│       │   └── azureResources.schema.json  # Validation schema
│       ├── security/
│       │   ├── security.yaml               # Key Vault configuration
│       │   └── security.schema.json        # Validation schema
│       └── workload/
│           ├── devcenter.yaml              # Dev Center, projects, pools
│           └── devcenter.schema.json       # Validation schema
├── src/
│   ├── connectivity/                       # VNet, subnet, network connection modules
│   ├── identity/                           # RBAC and role assignment modules
│   ├── management/                         # Log Analytics module
│   ├── security/                           # Key Vault and secret modules
│   └── workload/                           # Dev Center, project, pool modules
├── setUp.ps1                               # Setup script (PowerShell equivalent)
├── setUp.sh                                # Setup script (called by azd preprovision hook)
├── cleanSetUp.ps1                          # Resource teardown script
├── azure.yaml                              # azd config + preprovision hook (Linux/macOS)
├── azure-pwh.yaml                          # azd config + preprovision hook (Windows)
└── package.json                            # Documentation site (Hugo/Docsy)
```

## 🤝 Contributing

**Overview**

Contributions to the DevExp-DevBox accelerator are welcomed and valued. Whether
you are fixing a bug, adding a feature, improving documentation, or suggesting
an enhancement, your contribution helps the broader platform engineering
community adopt Dev Box faster.

The project follows a product-oriented delivery model organized around Epics,
Features, and Tasks. All contributions go through a standard GitHub pull request
workflow with required reviews, and infrastructure code must be parameterized
and idempotent.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on:

- Issue types and labeling conventions (Epic, Feature, Task)
- Branch naming conventions (`feature/<short-name>`, `fix/<short-name>`)
- Pull request requirements (linked issues, test evidence, docs updates)
- Engineering standards for Bicep modules (parameterized, idempotent)

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE)
file for details.

Copyright (c) 2025 Evilázaro Alves
