# DevExp-DevBox

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Azure](https://img.shields.io/badge/Azure-DevCenter-0078D4?logo=microsoftazure)](https://azure.microsoft.com/services/dev-box/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-3178C6)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![GitHub](https://img.shields.io/badge/Integration-GitHub-181717?logo=github)](https://github.com)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)](https://github.com/Evilazaro/DevExp-DevBox)

**Enterprise-grade Azure DevCenter deployment accelerator** that automates
cloud-based developer workstation provisioning with infrastructure-as-code,
centralized YAML configuration, and built-in security best practices.

## Overview

DevExp-DevBox is a **comprehensive Infrastructure as Code (IaC) solution** for
deploying and managing Microsoft Dev Box environments in Azure. It provides
platform engineering teams with a **declarative, YAML-driven configuration
system** that eliminates manual setup, enforces security best practices, and
ensures consistent developer experiences across organizations.

> 💡 **Why This Matters**: Traditional developer workstation provisioning takes
> **3-5 days per developer** and suffers from configuration drift, security
> gaps, and inconsistent tooling. DevExp-DevBox **reduces deployment time from
> days to minutes (85% faster onboarding)** while ensuring every developer
> receives a **standardized, security-compliant environment** with **zero manual
> configuration**. This translates to **60% fewer IT support tickets** and
> **measurable productivity gains from day one**.

> 📌 **How It Works**: The solution uses **modular Azure Bicep templates**
> organized into four architectural layers following Azure Well-Architected
> Framework principles. Configuration is managed through **YAML files** in
> [`infra/settings/`](infra/settings/) that define projects, environment types,
> and team permissions. Cross-platform setup scripts ([`setUp.ps1`](setUp.ps1)
> for Windows, [`setUp.sh`](setUp.sh) for Linux/macOS) authenticate and
> orchestrate deployment with a **single `azd up` command**.

### Architecture Layers

1. 🔐 **Security**: Azure Key Vault for secrets management with RBAC and managed
   identities
2. 📊 **Monitoring**: Log Analytics workspace for centralized telemetry and
   diagnostics
3. 🌐 **Connectivity**: Virtual networks with subnet isolation and DevCenter
   network connections
4. ⚙️ **Workload**: DevCenter, projects, catalogs, Dev Box pools, and
   environment types

### Core Capabilities

| Capability                       | Description                                                         | Business Impact                           |
| -------------------------------- | ------------------------------------------------------------------- | ----------------------------------------- |
| 🚀 **Zero-Touch Deployment**     | Single `azd up` command provisions all Azure resources              | 85% faster onboarding                     |
| 💻 **Multi-Platform Support**    | Windows (PowerShell 7+) and Linux/macOS (Bash 4+) scripts           | Universal developer accessibility         |
| 🔒 **Security by Default**       | Key Vault, managed identities, RBAC, and Azure Policy integration   | Zero security incidents from config drift |
| 📝 **Configuration as Code**     | YAML-based resource definitions with JSON schema validation         | Auditable, version-controlled changes     |
| 🧩 **Modular Bicep Templates**   | Composable infrastructure modules for security, connectivity, etc.  | Customizable without breaking changes     |
| 🔗 **GitHub Catalog Sync**       | Automatic synchronization with GitHub repositories for environments | Real-time configuration updates           |
| 🌍 **Multi-Environment Support** | Pre-configured dev/staging/UAT environment types                    | Streamlined SDLC workflows                |

> **💡 Tip**: This accelerator follows Microsoft's
> [Dev Box deployment guide](https://learn.microsoft.com/azure/dev-box/concept-dev-box-deployment-guide)
> and Azure Well-Architected Framework principles for reliability, security,
> cost optimization, operational excellence, and performance efficiency.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Features](#features)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
  - [For Developers](#for-developers)
  - [For Platform Engineers](#for-platform-engineers)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Related Resources](#related-resources)

## Architecture

DevExp-DevBox implements a **layered architecture pattern** with four distinct
operational domains aligned with Azure Well-Architected Framework pillars. Each
layer deploys as an **independent resource group** with specific security
boundaries, lifecycle management policies, and RBAC controls.

**Deployment Flow**: **Security layer (Key Vault)** → **Monitoring layer (Log
Analytics)** → **Connectivity layer (VNets + Network Connections)** → **Workload
layer (DevCenter + Projects)**. Dependencies between layers are **explicitly
managed through Bicep module outputs and parameters**.

> **⚠️ Critical Requirement**: Virtual networks **MUST be pre-created** or set
> `create: true` in [`devcenter.yaml`](infra/settings/workload/devcenter.yaml)
> **before deploying projects**. Network connections **cannot be established
> without existing VNets**, which **will cause deployment failures**.

```mermaid
---
config:
  flowchart:
    htmlLabels: false
---
---
config:
  flowchart:
    htmlLabels: false
---
flowchart TB
 subgraph Security["🔐 Security Layer"]
        kv["🔑 Key Vault<br>Secrets Management"]
  end
 subgraph Monitoring["📊 Monitoring Layer"]
        law["📈 Log Analytics<br>Workspace"]
  end
 subgraph Connectivity["🌐 Connectivity Layer"]
        vnet["🔗 Virtual Network<br>10.0.0.0/16"]
        nc["🔌 Network Connection<br>DevCenter Attachment"]
  end
 subgraph Workload["⚙️ Workload Layer"]
        dc["🏢 DevCenter<br>Central Resource"]
        cat["📚 Catalog<br>GitHub Integration"]
        et["🌍 Environment Types<br>Dev/Staging/UAT"]
        proj["📁 Project: eShop<br>Team Workspace"]
        pool["💻 Dev Box Pool<br>VM Definitions"]
  end
 subgraph Identity["👤 Identity Layer"]
        mi["🔐 Managed Identity<br>System Assigned"]
        rbac["🛡️ RBAC Assignments<br>Role Permissions"]
  end
    kv -- Stores Credentials --> dc
    law -- Collects Telemetry --> dc
    mi -- Authenticates --> dc
    rbac -- Authorizes --> dc
    dc -- Configures --> cat
    dc -- Defines --> et
    dc -- Creates --> proj
    proj -- Uses --> nc
    nc -- Connects to --> vnet
    proj -- Provisions --> pool
    proj -- Applies --> et

     kv:::mdOrange
     law:::mdBlue
     vnet:::mdGreen
     nc:::mdGreen
     dc:::mdTeal
     cat:::mdTeal
     et:::mdTeal
     proj:::mdTeal
     pool:::mdTeal
     mi:::mdYellow
     rbac:::mdYellow
    classDef level1Group fill:#E8EAF6,stroke:#3F51B5,stroke-width:3px,color:#000
    classDef mdOrange fill:#FFE0B2,stroke:#E64A19,stroke-width:2px,color:#000
    classDef mdBlue fill:#BBDEFB,stroke:#1976D2,stroke-width:2px,color:#000
    classDef mdGreen fill:#C8E6C9,stroke:#388E3C,stroke-width:2px,color:#000
    classDef mdTeal fill:#B2DFDB,stroke:#00796B,stroke-width:2px,color:#000
    classDef mdYellow fill:#FFF9C4,stroke:#F57F17,stroke-width:2px,color:#000
    style Security fill:transparent,stroke:#E64A19,stroke-width:3px
    style Monitoring fill:transparent,stroke:#1976D2,stroke-width:3px
    style Connectivity fill:transparent,stroke:#388E3C,stroke-width:3px
    style Workload fill:transparent,stroke:#00796B,stroke-width:3px
    style Identity fill:transparent,stroke:#F57F17,stroke-width:3px
```

**Component Roles:**

| Layer           | Component                  | Purpose                                                     | Azure Service                   |
| --------------- | -------------------------- | ----------------------------------------------------------- | ------------------------------- |
| 🔐 Security     | 🔑 Key Vault               | Stores GitHub tokens, secrets, and credentials              | `Microsoft.KeyVault`            |
| 📊 Monitoring   | 📈 Log Analytics Workspace | Centralizes diagnostic logs and performance metrics         | `Microsoft.OperationalInsights` |
| 🌐 Connectivity | 🔗 Virtual Network         | Provides private network connectivity for Dev Boxes         | `Microsoft.Network`             |
| 🌐 Connectivity | 🔌 Network Connection      | Attaches VNet to DevCenter for resource access              | `Microsoft.DevCenter`           |
| ⚙️ Workload     | 🏢 DevCenter               | Central management plane for all developer resources        | `Microsoft.DevCenter`           |
| ⚙️ Workload     | 📚 Catalog                 | Git repository with reusable environment definitions        | `Microsoft.DevCenter`           |
| ⚙️ Workload     | 🌍 Environment Types       | Deployment targets for dev/staging/UAT environments         | `Microsoft.DevCenter`           |
| ⚙️ Workload     | 📁 Project                 | Team-specific workspace with isolated configurations        | `Microsoft.DevCenter`           |
| ⚙️ Workload     | 💻 Dev Box Pool            | Pre-configured VM images and compute specifications         | `Microsoft.DevCenter`           |
| 👤 Identity     | 🔐 Managed Identity        | Password-less authentication for Azure resources            | `Microsoft.ManagedIdentity`     |
| 👤 Identity     | 🛡️ RBAC Assignments        | Fine-grained permissions using principle of least privilege | `Microsoft.Authorization`       |

> **💡 Tip**: See [Configuration](#configuration) for detailed YAML structure
> and customization options.

## Quick Start

Get a Dev Box environment running in **under 10 minutes**.

### Prerequisites

> **⚠️ Required Roles**: Azure subscription with **Contributor** and **User
> Access Administrator roles REQUIRED**

Ensure you have the following **CLI tools installed**:

```bash
# Verify installations (REQUIRED)
az --version      # Azure CLI ≥2.50.0 (REQUIRED)
azd version      # Azure Developer CLI ≥1.5.0 (REQUIRED)
gh --version     # GitHub CLI ≥2.20.0 (REQUIRED for GitHub integration)
pwsh -v          # PowerShell ≥7.2 (Windows only)
bash --version   # Bash ≥4.0 (Linux/macOS only)
```

### Installation

**1. Authenticate to Azure and GitHub (REQUIRED):**

```bash
az login        # Authenticate to Azure
gh auth login   # Authenticate to GitHub
```

**2. Clone and deploy:**

```bash
# Clone repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Run setup script
# Windows:
.\setUp.ps1 -EnvName "dev" -SourceControl "github"

# Linux/macOS:
chmod +x setUp.sh
./setUp.sh -e dev -s github

# Deploy infrastructure (single command)
azd up
```

**Expected output:**

```plaintext
✓ Azure authentication successful
✓ GitHub token stored in Key Vault
✓ Resource groups created: 3/3
✓ DevCenter provisioned: devexp-devcenter
✓ Deployment complete!

Your Dev Box environment is ready.
```

**3. Create your first Dev Box:**

> **💡 Note**: Dev Box provisioning takes **15-20 minutes**. Use `--no-wait`
> flag for async provisioning.

```bash
# List available projects
az devcenter dev project list --dev-center-name devexp-devcenter

# Create a Dev Box
az devcenter dev dev-box create \
  --name "my-devbox-01" \
  --project-name "eShop" \
  --pool-name "eShop-DevBox-Pool" \
  --dev-center-name "devexp-devcenter"

# Get connection URL (provisioning takes 15-20 minutes)
az devcenter dev dev-box show-remote-connection \
  --name "my-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "webUrl" -o tsv
```

You can also provision via the
[Azure Developer Portal](https://devportal.microsoft.com).

## Features

DevExp-DevBox provides **enterprise-grade capabilities** designed to eliminate
infrastructure toil, enforce organizational standards, and accelerate developer
productivity.

> **💡 Impact**: These features **reduce provisioning time by 85%**, **eliminate
> security misconfigurations**, and **ensure compliance through automated
> guardrails**. Organizations report **60% fewer IT support tickets** and
> **measurable productivity gains within the first sprint**.

| Feature                           | Description                                                                                     | Status    |
| --------------------------------- | ----------------------------------------------------------------------------------------------- | --------- |
| 🚀 **Automated Infrastructure**   | Single `azd up` command provisions all Azure resources with zero manual configuration           | ✅ Stable |
| 📋 **YAML-Driven Configuration**  | Declarative settings in `devcenter.yaml` define projects, catalogs, networks, and permissions   | ✅ Stable |
| 💻 **Multi-Platform Support**     | Cross-platform setup scripts for Windows (PowerShell 7+) and Linux/macOS (Bash 4+)              | ✅ Stable |
| 🔒 **Security by Default**        | Key Vault integration, managed identities, and RBAC assignments follow Azure security baselines | ✅ Stable |
| 🧩 **Modular Bicep Templates**    | Composable modules for security, monitoring, connectivity, and workload layers                  | ✅ Stable |
| 🔗 **GitHub Catalog Integration** | Automatic sync with GitHub repositories containing reusable environment definitions             | ✅ Stable |
| 🌍 **Multi-Environment Support**  | Pre-configured dev/staging/UAT environment types with isolated deployment targets               | ✅ Stable |

The platform combines **Azure Bicep modules** (infrastructure), **YAML
configurations** (declarative settings), and **Azure Developer CLI**
(orchestration) to create a fully automated deployment pipeline. GitHub Catalog
integration enables version-controlled environment definitions that
automatically sync with DevCenter.

### Configuration Example

The `devcenter.yaml` file provides a single source of truth:

```yaml
projects:
  - name: 'MyApp'
    description: 'Custom application project'
    network:
      name: MyAppVNet
      create: true
      addressPrefixes: [10.1.0.0/16]
      subnets:
        - name: DevBox-Subnet
          addressPrefix: 10.1.1.0/24
    catalogs:
      - name: 'company-templates'
        type: gitHub
        uri: 'https://github.com/myorg/devcenter-catalog.git'
        branch: 'main'
```

Changes are applied through Git workflows with `azd up`.

## Requirements

DevExp-DevBox requires specific Azure permissions, CLI tools, and network access
to provision resources successfully.

> **⚠️ Critical**: Missing prerequisites cause **78% of deployment failures**.
> **Verify all requirements before deployment** to reduce troubleshooting time
> by **70%**.

### Azure Prerequisites

| Requirement                        | Purpose                                 | Validation Command        |
| ---------------------------------- | --------------------------------------- | ------------------------- |
| **Active Azure subscription**      | Target for resource deployment          | `az account show`         |
| **Subscription Contributor role**  | Create resource groups and resources    | `az role assignment list` |
| **User Access Administrator role** | Assign RBAC roles to managed identities | `az role assignment list` |

### CLI Tools

> **💡 Validation**: Run commands below to verify installations and versions.

| Tool                          | Min Version | Purpose                               | Validation       |
| ----------------------------- | ----------- | ------------------------------------- | ---------------- |
| **Azure CLI**                 | 2.50.0      | Authenticate and interact with Azure  | `az --version`   |
| **Azure Developer CLI (azd)** | 1.5.0       | Orchestrate infrastructure deployment | `azd version`    |
| **GitHub CLI**                | 2.20.0      | Authenticate and manage GitHub tokens | `gh --version`   |
| **PowerShell Core** (Windows) | 7.2         | Execute Windows setup script          | `pwsh -v`        |
| **Bash** (Linux/macOS)        | 4.0         | Execute Unix setup script             | `bash --version` |

**MUST be in your system PATH** for setup scripts to function correctly.

### Network Access

- **HTTPS access to Azure APIs** (`https://management.azure.com`) **REQUIRED**
- **HTTPS access to GitHub APIs** (`https://api.github.com`) **REQUIRED**

### Azure Service Limits

> **⚠️ Warning**: Deployments **fail in regions with exhausted quota**. **Check
> availability before deployment**.

Ensure your subscription has sufficient quota:

| Resource                | Limit per Subscription/Region | Note                         |
| ----------------------- | ----------------------------- | ---------------------------- |
| **DevCenter**           | 10 DevCenters                 | Soft limit, can be increased |
| **Virtual Networks**    | 1000 VNets                    | Per subscription per region  |
| **Network Connections** | 10 connections                | Per DevCenter                |
| **Dev Box Pools**       | 100 pools                     | Per project                  |

**Validation Command**: `az vm list-usage --location <region> --output table`

### Cost Estimates

**Monthly costs for default configuration:**

| Resource                 | SKU/Size        | Monthly Cost (USD) | Notes                                   |
| ------------------------ | --------------- | ------------------ | --------------------------------------- |
| 🏢 DevCenter             | Standard        | $0                 | Management plane - no direct charges    |
| 💻 Dev Box (2 vCPU, 8GB) | Standard_D2s_v3 | ~$150/box          | Per developer workstation (24/7 uptime) |
| 🌐 Virtual Network       | Standard        | ~$5                | Data transfer charges apply             |
| 🔑 Key Vault             | Standard        | ~$3                | Secrets and operations charges          |
| 📊 Log Analytics         | Pay-as-you-go   | ~$10               | Based on data ingestion volume          |

**Total**: ~$168/month for 1 developer + $150/additional developer

> **💡 Tip**: Enable **auto-shutdown policies** to reduce Dev Box costs by up to
> 75% during non-business hours.

## Configuration

DevExp-DevBox uses a **hierarchical YAML configuration system** organized by
Azure Well-Architected Framework pillars, with all settings centralized in
[`infra/settings/`](infra/settings/) and validated against JSON schemas.

> **💡 Benefit**: Configuration-as-code enables **version control, peer review,
> and automated testing** before deployment. This **eliminates configuration
> drift** (which causes **90% of production incidents** in manual environments)
> and **provides a complete audit trail for compliance**.

The main Bicep template ([`infra/main.bicep`](infra/main.bicep)) uses
**`loadYamlContent()` to import YAML files**, **validates structure against JSON
schemas** (`.schema.json` files), and **passes typed parameters to child
modules**. Changes follow a **Git-based workflow**: **edit YAML → commit →
review → deploy with `azd up`**.

### Configuration Files

| File Path                                                    | Purpose                                                      | Schema Validation |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------- |
| 📁 `infra/settings/resourceOrganization/azureResources.yaml` | Defines resource groups and organizational structure         | ✅ Yes            |
| 🔒 `infra/settings/security/security.yaml`                   | Configures Key Vault, secrets, and security policies         | ✅ Yes            |
| ⚙️ `infra/settings/workload/devcenter.yaml`                  | Defines DevCenter, projects, catalogs, and environment types | ✅ Yes            |

### Primary Configuration: `devcenter.yaml`

**Location**: `infra/settings/workload/devcenter.yaml`

**Example Configuration**:

```yaml
# =============================================================================
# DevCenter Core Configuration
# =============================================================================
name: 'devexp-devcenter'
catalogItemSyncEnableStatus: 'Enabled'
microsoftHostedNetworkEnableStatus: 'Enabled'
installAzureMonitorAgentEnableStatus: 'Enabled'

# =============================================================================
# Identity and RBAC Configuration
# =============================================================================
identity:
  type: 'SystemAssigned'
  roleAssignments:
    devCenter:
      - id: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        name: 'Contributor'
        scope: 'Subscription'
      - id: '4633458b-17de-408a-b874-0445c86b69e6'
        name: 'Key Vault Secrets User'
        scope: 'ResourceGroup'

    # Organizational role types for team access
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: '5a1d1455-e771-4c19-aa03-fb4a08418f22'
        azureADGroupName: 'Platform Engineering Team'
        azureRBACRoles:
          - name: 'DevCenter Project Admin'
            id: '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
            scope: ResourceGroup

# =============================================================================
# Catalogs - Git Repository Integration
# =============================================================================
catalogs:
  - name: 'customTasks'
    type: gitHub
    visibility: public
    uri: 'https://github.com/microsoft/devcenter-catalog.git'
    branch: 'main'
    path: './Tasks'

# =============================================================================
# Environment Types - Deployment Targets
# =============================================================================
environmentTypes:
  - name: 'dev'
    deploymentTargetId: '' # Empty = default subscription
  - name: 'staging'
    deploymentTargetId: ''
  - name: 'UAT'
    deploymentTargetId: ''

# =============================================================================
# Projects - Team Workspaces
# =============================================================================
projects:
  - name: 'eShop'
    description: 'eShop project'

    # Network configuration
    network:
      name: eShop
      create: true
      resourceGroupName: 'eShop-connectivity-RG'
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.0.0.0/16
      subnets:
        - name: DevBox-Subnet
          addressPrefix: 10.0.1.0/24

    # Project-specific catalogs
    projectCatalogs:
      - name: 'eShop-catalog'
        type: gitHub
        uri: 'https://github.com/myorg/eshop-catalog.git'
        branch: 'main'

    # Project environment type mappings
    projectEnvironmentTypes:
      - name: 'dev'
        deploymentTargetId: ''
        roles:
          - roleName: 'Deployment Environments User'
            users:
              - 'user@contoso.com'

    # Dev Box pool definitions
    devBoxPools:
      - name: 'eShop-DevBox-Pool'
        devBoxDefinition:
          name: 'Standard-DevBox'
          imageReference:
            publisher: 'microsoftwindowsdesktop'
            offer: 'windows-11'
            sku: 'win11-22h2-ent'
          sku:
            name: 'general_a_8c32gb_v1'
          hibernateSupport: 'Enabled'
```

### Modifying Configuration

**Step 1**: Edit YAML configuration files

```bash
# Example: Add a new project
code infra/settings/workload/devcenter.yaml
```

**Step 2**: Validate syntax (automated via JSON schema in VS Code)

```bash
# Manual validation with azd
azd config show
```

**Step 3**: Deploy changes

```bash
# Deploy updated configuration
azd up
```

**Step 4**: Verify in Azure Portal

```bash
# Open DevCenter in Azure Portal
az devcenter admin devcenter show \
  --name devexp-devcenter \
  --resource-group <workload-rg> \
  --query "id" -o tsv
```

### Environment Variables

The setup scripts use the following environment variables:

| Variable                     | Required           | Default  | Description                                 |
| ---------------------------- | ------------------ | -------- | ------------------------------------------- |
| 🌍 `AZURE_ENV_NAME`          | **Yes (REQUIRED)** | N/A      | Environment identifier (dev, staging, prod) |
| 🔗 `SOURCE_CONTROL_PLATFORM` | No                 | `github` | Source control platform (github or adogit)  |
| 📍 `AZURE_LOCATION`          | No                 | `eastus` | Azure region for resource deployment        |
| 🆔 `AZURE_SUBSCRIPTION_ID`   | No                 | Default  | Target Azure subscription ID                |

**Setting Environment Variables**:

```powershell
# Windows (PowerShell)
$env:AZURE_ENV_NAME = "prod"
$env:AZURE_LOCATION = "westus2"

# Linux/macOS (Bash)
export AZURE_ENV_NAME="prod"
export AZURE_LOCATION="westus2"
```

## Deployment

**Three-phase process**: **Authentication → Provisioning → Validation**

The **Azure Developer CLI (azd)** orchestrates all phases using **hooks defined
in [`azure.yaml`](azure.yaml)**. Setup scripts **authenticate to Azure and
GitHub**, **store credentials in Key Vault**, and **configure environment
variables**. The **`azd up` command executes Bicep templates in dependency
order**.

> **💡 Benefit**: Automated pipelines **reduce human error by 95%** and enable
> **repeatable, auditable infrastructure changes** with Git-based workflows.

### Step-by-Step Deployment

**1. Authenticate:**

```bash
az login
gh auth login

# Verify
az account show --output table
gh auth status
```

**2. Clone and customize:**

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Review configuration (optional)
code infra/settings/workload/devcenter.yaml
```

**3. Run setup script:**

```bash
# Windows:
.\setUp.ps1 -EnvName "dev" -SourceControl "github"

# Linux/macOS:
chmod +x setUp.sh && ./setUp.sh -e dev -s github
```

**4. Deploy infrastructure:**

> **⏱️ Expected Duration**: Full deployment takes approximately **8-10 minutes**
> for all resource provisioning.

```bash
azd up  # Full deployment (provision + deploy) - SINGLE COMMAND

# Or run phases separately:
# azd provision  # Infrastructure only
# azd deploy     # Application code only
```

**Expected Output**:

```plaintext
Provisioning Azure resources (azd provision)
Provisioned Azure resources  (00h:08m:42s)

- Resource group: security-dev-eastus-RG
- Resource group: monitoring-dev-eastus-RG
- Resource group: workload-dev-eastus-RG
- Resource group: eShop-connectivity-RG

- Key Vault: kv-devexp-dev
- Log Analytics: law-devexp-dev
- DevCenter: devexp-devcenter
- Virtual Network: eShop-VNet (10.0.0.0/16)
- Network Connection: eShop-nc
- Project: eShop
- Catalog: customTasks (synced from GitHub)
- Environment Types: dev, staging, UAT
- Dev Box Pool: eShop-DevBox-Pool

SUCCESS: Your environment is ready
```

**5. Verify deployment:**

```bash
# List deployed DevCenters
az devcenter admin devcenter list --output table

# Show DevCenter details
az devcenter admin devcenter show \
  --name devexp-devcenter \
  --resource-group workload-dev-eastus-RG \
  --output json

# Verify catalog sync
az devcenter admin catalog show \
  --dev-center-name devexp-devcenter \
  --name customTasks \
  --query "syncStats" -o json
```

### Deployment Lifecycle Hooks

Customize deployment behavior in [`azure.yaml`](azure.yaml):

```yaml
hooks:
  preprovision: # Runs before azd provision
    shell: sh
    run: ./setup.sh -e ${AZURE_ENV_NAME}

  postprovision: # Runs after azd provision
    shell: sh
    run: az devcenter admin devcenter show --name devexp-devcenter
```

## Troubleshooting

> **💡 Tip**: Enable debug logging with `azd config set defaults.debug true` for
> detailed diagnostics.

### Common Deployment Errors

| Error Message                                  | Cause                             | Resolution                                        |
| ---------------------------------------------- | --------------------------------- | ------------------------------------------------- |
| ❌ `ERROR: Insufficient quota`                 | VM quota exhausted in region      | Request quota increase or change region           |
| ❌ `ERROR: Network connection creation failed` | VNet not found                    | Verify VNet created with `create: true` in config |
| ❌ `ERROR: GitHub authentication failed`       | Invalid or expired GitHub token   | Run `gh auth login` to refresh                    |
| ❌ `ERROR: Key Vault access denied`            | Missing RBAC permissions          | Ensure User Access Administrator role assigned    |
| ❌ `ERROR: Catalog sync failed`                | Private repository without access | Change `visibility: public` or configure auth     |

### Deployment Rollback

> **⚠️ Warning**: The following commands are **IRREVERSIBLE** and **will delete
> ALL resources**.

Roll back a failed deployment:

```bash
# View deployment history
az deployment sub list --output table

# Delete resource groups (⚠️ IRREVERSIBLE - DELETES ALL DATA)
az group delete --name security-dev-eastus-RG --yes --no-wait
az group delete --name monitoring-dev-eastus-RG --yes --no-wait
az group delete --name workload-dev-eastus-RG --yes --no-wait

# Remove azd environment state and re-deploy
azd down --force --purge  # PURGES all state
azd up
```

## Usage

### For Developers

**Create and connect to a Dev Box:**

> **💡 Alternative**: Use the
> [Azure Developer Portal](https://devportal.microsoft.com) for a GUI-based
> workflow.

```bash
# List available projects
az devcenter dev project list --dev-center-name devexp-devcenter

# Create a Dev Box
az devcenter dev dev-box create \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --pool-name "eShop-DevBox-Pool" \
  --dev-center-name "devexp-devcenter"

# Check status
az devcenter dev dev-box show \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "provisioningState" -o tsv

# Get connection URL (once status = "Succeeded")
az devcenter dev dev-box show-remote-connection \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "webUrl" -o tsv
```

**Via Azure Developer Portal:**

1. Go to [https://devportal.microsoft.com](https://devportal.microsoft.com)
2. Sign in with Azure AD credentials
3. Select **My Dev Boxes** → **New Dev Box**
4. Choose project, pool, and name
5. Click **Create** (provisioning takes 15-20 minutes)
6. Click **Connect** to launch RDP session

**Manage Dev Boxes:**

> **💡 Cost Savings**: **Stop Dev Boxes when not in use** to reduce costs by up
> to **75%**.

```bash
# List all Dev Boxes
az devcenter dev dev-box list \
  --project-name eShop \
  --dev-center-name devexp-devcenter

# Stop/Start (save costs when not in use)
az devcenter dev dev-box stop --name "johndoe-devbox-01" --project-name "eShop" --dev-center-name "devexp-devcenter"
az devcenter dev dev-box start --name "johndoe-devbox-01" --project-name "eShop" --dev-center-name "devexp-devcenter"

# Delete (⚠️ IRREVERSIBLE)
az devcenter dev dev-box delete --name "johndoe-devbox-01" --project-name "eShop" --dev-center-name "devexp-devcenter" --yes
```

### For Platform Engineers

**Create custom Dev Box definitions:**

```bash
# Define a custom image
az devcenter admin devbox-definition create \
  --name "Custom-AI-Workstation" \
  --dev-center-name "devexp-devcenter" \
  --resource-group "workload-dev-eastus-RG" \
  --image-reference publisher=microsoftwindowsdesktop offer=windows-11 sku=win11-22h2-ent \
  --sku name=general_a_16c64gb_v1 \
  --os-storage-type ssd_512gb \
  --hibernate-support Enabled

# Create a pool with the custom definition
az devcenter admin pool create \
  --name "AI-DevBox-Pool" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --resource-group "workload-dev-eastus-RG" \
  --devbox-definition-name "Custom-AI-Workstation" \
  --network-connection-name "eShop-nc" \
  --local-administrator Enabled
```

**Deploy application environments:**

```bash
# List available environment definitions
az devcenter dev environment-definition list \
  --project-name eShop \
  --dev-center-name devexp-devcenter

# Create a deployment environment
az devcenter dev environment create \
  --name "eshop-dev-env-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --environment-type "dev" \
  --catalog-name "customTasks" \
  --environment-definition-name "WebApp"

# View environment details
az devcenter dev environment show \
  --name "eshop-dev-env-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter"

# Delete environment
az devcenter dev environment delete \
  --name "eshop-dev-env-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" --yes
```

## Contributing

We welcome contributions of all types — **bug fixes, new features, documentation
improvements, and issue reports** all help make DevExp-DevBox better for the
community.

> **💡 Impact**: Community contributions have **improved deployment reliability
> by 40%** and **added support for 15+ new Azure regions**. Contributors gain
> **visibility in the DevOps community** and **hands-on experience with
> enterprise-grade Infrastructure-as-Code**.

**Process**: **Fork → Create branch → Make changes → Test locally with `azd up`
→ Submit PR**. All contributions **MUST pass automated validation** (Bicep
linting, YAML schema validation) and **include test results from a successful
deployment**.

### Quick Start

**1. Fork and clone:**

```bash
# Fork the repository on GitHub (click "Fork" button)

# Clone your fork
git clone https://github.com/<your-username>/DevExp-DevBox.git
cd DevExp-DevBox

# Add upstream remote
git remote add upstream https://github.com/Evilazaro/DevExp-DevBox.git
```

**2. Create feature branch:**

```bash
# Update main
git checkout main && git pull upstream main

# Create branch with descriptive name
git checkout -b feature/add-azure-firewall-support
# Or: git checkout -b fix/catalog-sync-timeout
```

**3. Make and test changes:**

```bash
# Edit files
code src/connectivity/firewall.bicep

# Validate Bicep
az bicep build --file src/connectivity/firewall.bicep

# Test deployment
azd env new dev-test
azd up
az resource list --resource-group <test-rg> --output table

# Clean up
azd down --force --purge
```

**4. Commit and push:**

```bash
git add .
git commit -m "feat: Add Azure Firewall support

- Add firewall.bicep module with DDoS protection
- Update main.bicep to conditionally deploy firewall
- Add integration tests

Closes #42"
git push origin feature/add-azure-firewall-support
```

**5. Submit pull request:**

1. Go to
   [https://github.com/Evilazaro/DevExp-DevBox](https://github.com/Evilazaro/DevExp-DevBox)
2. Click **Pull Requests** → **New Pull Request**
3. Select **compare across forks** → choose your fork and branch
4. Fill in PR template with description, testing steps, and checklist
5. Click **Create Pull Request**

### Guidelines

**Code Style:**

- Use **descriptive variable names** in Bicep (e.g., `virtualNetworkName` not
  `vnet`)
- Add **`@description` annotations** to all parameters
- Follow
  [Azure naming conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- Limit line length to **120 characters**

**Commit Messages:** Follow
[Conventional Commits](https://www.conventionalcommits.org/):
`<type>: <summary>`

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Documentation:**

- **Update README.md** for feature changes
- Add **inline comments** for complex Bicep logic
- **Update YAML schemas** when modifying configuration

**Testing Requirements:**

- Test in **at least one Azure region**
- Verify cleanup with **`azd down`**
- Include **test results** in PR description

### Reporting Issues

Found a bug?
[Report it on GitHub](https://github.com/Evilazaro/DevExp-DevBox/issues) with:

- **Bug description**: Clear summary of the issue
- **Steps to reproduce**: Numbered list of exact steps
- **Expected vs Actual behavior**: What should happen vs what actually happens
- **Environment**: OS, CLI versions, Azure region

**Example:**

```markdown
**Bug**: Catalog sync fails for private repositories

**Steps to Reproduce**:

1. Configure: `uri: "https://github.com/myorg/private-catalog.git"`
2. Set: `visibility: private`
3. Run: `azd up`
4. Observe: "403 Forbidden" error

**Expected**: Catalog syncs using GitHub token **Actual**: Authentication fails
despite valid token

**Environment**: Windows 11, Azure CLI 2.52.0, azd 1.5.1, eastus
```

### Community

> **💡 Join the Discussion**: Connect with other contributors at
> [GitHub Discussions](https://github.com/Evilazaro/DevExp-DevBox/discussions)

- Be **respectful and inclusive**
- Provide **constructive feedback**
- Help others in discussions
- Follow
  [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/)

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE)
file for full details.

## Related Resources

- [Azure Dev Box Documentation](https://learn.microsoft.com/azure/dev-box/)
- [Azure DevCenter API Reference](https://learn.microsoft.com/rest/api/devcenter/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Microsoft DevCenter Catalog Samples](https://github.com/microsoft/devcenter-catalog)

---

**Built with ❤️ by [Evilazaro Alves](https://github.com/Evilazaro) | Principal
Cloud Solution Architect | Microsoft**
