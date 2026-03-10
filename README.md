# DevExp-DevBox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Azure Developer CLI](https://img.shields.io/badge/azd-compatible-blue)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-0078D4)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
[![Platform](https://img.shields.io/badge/Platform-Azure-0078D4)](https://azure.microsoft.com)
[![Status](https://img.shields.io/badge/Status-Stable-brightgreen)](https://github.com/Evilazaro/DevExp-DevBox)

The **DevExp-DevBox** accelerator automates end-to-end deployment of
[Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
environments on Azure using Infrastructure as Code (Bicep) and the
[Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/).
A single `azd up` command provisions a fully governed, multi-project Dev Center
with networking, security, monitoring, and role-based access control — no manual
portal steps required.

## Overview

**Overview**

DevExp-DevBox bridges the gap between manual Dev Box configuration and scalable,
repeatable developer environment management. Platform engineering teams and
DevOps architects use this accelerator to stand up enterprise-grade developer
workstations across multiple projects without per-project scripting or portal
work.

It packages every required Azure resource — Dev Center, Key Vault, Log Analytics
Workspace, virtual networks, and role assignments — into a YAML-driven,
pipeline-ready blueprint. Teams declaratively define their developer
environments in `infra/settings/`, and the accelerator handles provisioning,
wiring, and governance in a single deployment pass compliant with
[Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
principles.

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Architecture

**Overview**

The accelerator deploys across three dedicated Azure resource groups following
landing zone principles: **Security** (Key Vault), **Monitoring** (Log
Analytics), and **Workload** (Dev Center, projects, and connectivity).
Dependencies flow deliberately: the monitoring layer feeds telemetry to Dev
Center, the security layer supplies credentials via Key Vault, and project-level
virtual networks attach through dedicated network connections.

```mermaid
---
title: "DevExp-DevBox Infrastructure Architecture"
config:
  theme: base
  look: classic
  layout: dagre
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: DevExp-DevBox Infrastructure Architecture
    accDescr: Azure subscription-scoped infrastructure with Security, Monitoring, and Workload landing zones. Dev Center consumes Key Vault secrets and Log Analytics telemetry, manages role-specific Dev Box pools through YAML-configured projects, and attaches to project-level virtual networks via network connections.

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

    subgraph sub["☁️ Azure Subscription"]
        direction TB

        subgraph secRG["🔐 Security Resource Group"]
            kv["🔑 Azure Key Vault"]:::core
            sec["🔒 Secrets & Tokens"]:::data
        end

        subgraph monRG["📊 Monitoring Resource Group"]
            law["📈 Log Analytics Workspace"]:::core
        end

        subgraph wrkRG["⚙️ Workload Resource Group"]
            dc["🖥️ Azure Dev Center"]:::core

            subgraph proj["📁 Projects"]
                p1["🎯 Dev Box Project"]:::neutral
                pools["💻 Dev Box Pools"]:::neutral
                envt["🌍 Environment Types"]:::neutral
            end

            subgraph netg["🔗 Connectivity"]
                vnet["🕸️ Virtual Network"]:::external
                nc["🔌 Network Connection"]:::external
            end
        end
    end

    sec -->|"stored in"| kv
    kv -->|"provides secrets"| dc
    law -->|"monitors"| dc
    dc -->|"manages"| p1
    p1 -->|"provisions"| pools
    p1 -->|"defines"| envt
    vnet -->|"backs"| nc
    nc -->|"attaches to"| dc

    style sub  fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style secRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style monRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style wrkRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style proj  fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style netg  fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    %% Centralized semantic classDefs (Phase 5 compliant)
    classDef neutral  fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core     fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data     fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef external fill:#E0F7F7,stroke:#038387,stroke-width:2px,color:#323130
```

**Component Roles:**

| Component                    | Description                                                                     |
| ---------------------------- | ------------------------------------------------------------------------------- |
| ☁️ Azure Subscription        | Top-level scope; all resource groups deploy here (`infra/main.bicep`)           |
| 🔐 Security Resource Group   | Hosts Azure Key Vault for token and secret management                           |
| 🔑 Azure Key Vault           | Stores GitHub Actions or Azure DevOps tokens with RBAC authorization            |
| 📊 Monitoring Resource Group | Centralizes observability for all Dev Center diagnostic events                  |
| 📈 Log Analytics Workspace   | Receives diagnostic logs from Dev Center and connected resources                |
| ⚙️ Workload Resource Group   | Contains Dev Center, Dev Box projects, pools, and network resources             |
| 🖥️ Azure Dev Center          | Central hub for Dev Box definitions, catalogs, and environment types            |
| 💻 Dev Box Pools             | Role-specific VM configurations (e.g., `backend-engineer`, `frontend-engineer`) |

## Features

**Overview**

DevExp-DevBox removes the operational burden of configuring developer
workstations at scale. From a single YAML configuration in
`infra/settings/workload/devcenter.yaml`, platform teams define role-specific
Dev Box pool configurations, multi-project access policies, and environment
lifecycle management — deployable repeatably through CI/CD pipelines or
`azd up`.

The accelerator enforces Azure landing zone principles by default, ensuring
clear resource group separation, least-privilege RBAC, managed identity
integration, and centralized logging. Every deployment is functional and
audit-ready from day one, with no manual portal steps required.

| Feature                      | Description                                                    | Status    |
| ---------------------------- | -------------------------------------------------------------- | --------- |
| 🚀 One-command deployment    | Full environment provisioned with `azd up`                     | ✅ Stable |
| 🏗️ YAML-driven configuration | Dev Center, projects, and pools declared in YAML               | ✅ Stable |
| 🔐 Key Vault integration     | GitHub tokens stored with RBAC authorization enabled           | ✅ Stable |
| 📊 Built-in monitoring       | Log Analytics Workspace auto-wired to Dev Center               | ✅ Stable |
| 🧩 Multi-project support     | Multiple Dev Box projects per Dev Center                       | ✅ Stable |
| 💻 Role-specific pools       | Backend, frontend, and custom VM SKU pools supported           | ✅ Stable |
| 🌍 Multi-environment types   | Dev, Staging, and UAT environments out of the box              | ✅ Stable |
| 🔗 Flexible networking       | Managed (Microsoft-hosted) and unmanaged (customer VNet) modes | ✅ Stable |
| 🔑 Managed identity          | System-assigned identity with least-privilege RBAC assignments | ✅ Stable |
| 🧹 Cleanup automation        | `cleanSetUp.ps1` removes all provisioned resources             | ✅ Stable |

## Requirements

**Overview**

The accelerator runs on any workstation or CI/CD runner with the Azure Developer
CLI and an authenticated Azure session. Cross-platform support is built in:
`azure.yaml` drives Linux and macOS deployments via Bash hooks, while
`azure-pwh.yaml` handles Windows PowerShell environments. The only Azure-side
requirement is an active subscription with Contributor or Owner rights at the
subscription scope.

Before deploying, ensure all tools listed below are installed and authenticated.
The `setUp.sh` and `setUp.ps1` scripts validate dependencies at startup and halt
with descriptive error messages if any prerequisite is missing.

| Prerequisite           | Minimum Version | Purpose                                         | Install                                                                                            |
| ---------------------- | --------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| ☁️ Azure Subscription  | Active          | Deployment target for all provisioned resources | [Azure Portal](https://portal.azure.com)                                                           |
| 🔑 Azure CLI           | 2.60.0+         | Azure resource management and authentication    | [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)                     |
| 🛠️ Azure Developer CLI | 1.11.0+         | `azd up` deployment orchestration and hooks     | [Install guide](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) |
| 🐙 GitHub CLI          | 2.40.0+         | GitHub token and repository secrets integration | [Install guide](https://cli.github.com/)                                                           |
| ⚡ PowerShell          | 5.1+            | Windows deployment scripts (`setUp.ps1`)        | Built-in on Windows                                                                                |
| 🔗 jq                  | 1.6+            | JSON processing inside `setUp.sh` Bash scripts  | [Install guide](https://jqlang.github.io/jq/)                                                      |

> [!NOTE] The GitHub CLI (`gh`) is required only when
> `SOURCE_CONTROL_PLATFORM=github`. For Azure DevOps (`adogit`) deployments it
> can be omitted. If `SOURCE_CONTROL_PLATFORM` is not set, both setup scripts
> default to `github`.

## Quick Start

### Before You Begin

Complete these one-time pre-flight steps before running `azd up`:

**1. Create required Azure AD groups** in your tenant (or record the Object IDs
of existing groups):

| Group                        | Default name in config      | Purpose                                          |
| ---------------------------- | --------------------------- | ------------------------------------------------ |
| 🏢 Platform Engineering Team | `Platform Engineering Team` | Dev Managers — can configure Dev Box definitions |
| 👩‍💻 eShop Developers          | `eShop Developers`          | Dev Box Users for the eShop project              |

Record each group's **Object ID** — you will need them to update
`infra/settings/workload/devcenter.yaml` before deployment.

**2. Generate a GitHub Personal Access Token (PAT)** with `repo` and `workflow`
scopes at [github.com/settings/tokens](https://github.com/settings/tokens). This
token is stored in Key Vault as `gha-token` and used by the Dev Center catalog
and deployment pipelines.

**3. Update Azure AD group IDs** in `infra/settings/workload/devcenter.yaml`:

```yaml
# Dev Manager group — replace with your tenant's Object ID
orgRoleTypes:
  - type: DevManager
    azureADGroupId: '<your-platform-engineering-team-object-id>'
    azureADGroupName: 'Platform Engineering Team'

# eShop project developer group — replace with your tenant's Object ID
projects:
  - name: 'eShop'
    identity:
      roleAssignments:
        - azureADGroupId: '<your-eshop-developers-object-id>'
          azureADGroupName: 'eShop Developers'
```

> [!WARNING] Deploying without updating the Azure AD group Object IDs will cause
> RBAC role assignment failures during provisioning. The default IDs in the
> repository are placeholders for the Contoso demo tenant.

### Deploy (Linux / macOS)

```bash
# 1. Clone the repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# 2. Authenticate
az login
azd auth login

# 3. (Optional) Set source control platform — defaults to 'github'
export SOURCE_CONTROL_PLATFORM="github"

# 4. Provision all resources
azd up
```

### Deploy (Windows PowerShell)

On Windows, `azure-pwh.yaml` provides PowerShell-native hooks. Point `azd` at it
explicitly:

```powershell
# 1. Clone the repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
Set-Location DevExp-DevBox

# 2. Authenticate
az login
azd auth login

# 3. (Optional) Set source control platform
$env:SOURCE_CONTROL_PLATFORM = "github"

# 4. Provision all resources using the PowerShell hooks file
azd up --config azure-pwh.yaml
```

### Prompted Values

When `azd up` runs, it prompts interactively for three parameters:

| Prompt              | Environment variable | Example value      | Notes                                                    |
| ------------------- | -------------------- | ------------------ | -------------------------------------------------------- |
| 🏷️ Environment name | `AZURE_ENV_NAME`     | `dev`              | 2–10 characters; appended to resource group names        |
| 📍 Azure region     | `AZURE_LOCATION`     | `eastus2`          | Must be one of the allowed regions in `infra/main.bicep` |
| 🔑 Key Vault secret | `KEY_VAULT_SECRET`   | `ghp_xxxxxxxxxxxx` | GitHub PAT generated in the pre-flight step              |

### Expected Output

A successful deployment prints:

```text
SUCCESS: Your up workflow to provision and deploy to Azure completed.

Outputs:
  AZURE_DEV_CENTER_NAME                devexp-devcenter
  AZURE_DEV_CENTER_PROJECTS            ["eShop"]
  AZURE_KEY_VAULT_NAME                 contoso
  AZURE_KEY_VAULT_ENDPOINT             https://contoso.vault.azure.net/
  AZURE_LOG_ANALYTICS_WORKSPACE_NAME   logAnalytics-dev-eastus2-RG
  SECURITY_AZURE_RESOURCE_GROUP_NAME   devexp-security-dev-eastus2-RG
  MONITORING_AZURE_RESOURCE_GROUP_NAME devexp-monitoring-dev-eastus2-RG
  WORKLOAD_AZURE_RESOURCE_GROUP_NAME   devexp-workload-dev-eastus2-RG
```

> [!TIP] To use Azure DevOps instead of GitHub, set
> `SOURCE_CONTROL_PLATFORM=adogit` before `azd up`. Supply your Azure DevOps
> Personal Access Token as `KEY_VAULT_SECRET`. The `setUp.sh` and `setUp.ps1`
> scripts detect the platform and configure the appropriate credentials flow
> automatically.

## Configuration

**Overview**

All deployment behavior is controlled through YAML configuration files in
`infra/settings/`. These files define resource group organization, Dev Center
topology, project layouts, pool configurations, and security parameters. No
Bicep changes are required to customize a deployment — only YAML edits are
needed, making the accelerator adaptable to any organization's naming
conventions and tagging policies.

The configuration layer separates concerns cleanly: `azureResources.yaml`
controls landing zone structure, `devcenter.yaml` manages workload topology, and
`security.yaml` governs Key Vault settings. Changes take effect on the next
`azd up`.

### Configuration File Map

| File                                                         | Purpose                                                     | Edit frequency         |
| ------------------------------------------------------------ | ----------------------------------------------------------- | ---------------------- |
| 📁 `infra/settings/resourceOrganization/azureResources.yaml` | Resource group names, tags, and create flags                | Once per environment   |
| ⚙️ `infra/settings/workload/devcenter.yaml`                  | Dev Center, projects, pools, catalogs, RBAC                 | Per project onboarding |
| 🔒 `infra/settings/security/security.yaml`                   | Key Vault name, secret name, soft-delete policy             | Once per deployment    |
| 📋 `infra/main.parameters.json`                              | azd parameter bindings (`AZURE_ENV_NAME`, `AZURE_LOCATION`) | Rarely                 |

### Resource Group Organization

Edit `infra/settings/resourceOrganization/azureResources.yaml` to rename landing
zones or change tagging. Set `create: false` to reuse an existing resource group
instead of creating a new one.

```yaml
workload:
  create: true
  name: devexp-workload # Base name; final name = devexp-workload-<env>-<region>-RG
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: Workload

security:
  create: true
  name: devexp-security

monitoring:
  create: true
  name: devexp-monitoring
```

> [!NOTE] Resource group names are computed at deploy time as
> `<name>-<environmentName>-<location>-RG`. For example, `devexp-workload` with
> `environmentName=dev` and `location=eastus2` becomes
> `devexp-workload-dev-eastus2-RG`.

### Dev Center Core Settings

The top-level block in `infra/settings/workload/devcenter.yaml` controls Dev
Center features and identity:

```yaml
name: 'devexp-devcenter'
catalogItemSyncEnableStatus: 'Enabled' # Auto-sync catalog items
microsoftHostedNetworkEnableStatus: 'Enabled' # Microsoft-hosted network for Dev Boxes
installAzureMonitorAgentEnableStatus: 'Enabled' # Azure Monitor agent on Dev Boxes

identity:
  type: 'SystemAssigned'
  roleAssignments:
    devCenter:
      - id: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        name: 'Contributor'
        scope: 'Subscription'
      - id: '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
        name: 'User Access Administrator'
        scope: 'Subscription'
      - id: '4633458b-17de-408a-b874-0445c86b69e6'
        name: 'Key Vault Secrets User'
        scope: 'ResourceGroup'
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: '<your-platform-engineering-team-object-id>' # ← UPDATE THIS
        azureADGroupName: 'Platform Engineering Team'
        azureRBACRoles:
          - name: 'DevCenter Project Admin'
            id: '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
            scope: ResourceGroup
```

### Catalogs

The global Dev Center catalog in `infra/settings/workload/devcenter.yaml` points
to the Microsoft-managed tasks catalog:

```yaml
catalogs:
  - name: 'customTasks'
    type: gitHub
    visibility: public
    uri: 'https://github.com/microsoft/devcenter-catalog.git'
    branch: 'main'
    path: './Tasks'
```

Each project can also declare its own catalogs for environment definitions and
Dev Box image definitions:

```yaml
projects:
  - name: 'eShop'
    catalogs:
      - name: 'environments'
        type: environmentDefinition
        sourceControl: gitHub
        visibility: private
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/.devcenter/environments'
      - name: 'devboxImages'
        type: imageDefinition
        sourceControl: gitHub
        visibility: private
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/.devcenter/imageDefinitions'
```

### Projects, Pools, and RBAC

Each project entry in `infra/settings/workload/devcenter.yaml` defines its own
pools, environment types, networking, and role assignments:

```yaml
projects:
  - name: 'eShop'
    description: 'eShop project.'

    # Networking — Managed uses Microsoft-hosted network; Unmanaged attaches a customer VNet
    network:
      name: eShop
      create: true
      resourceGroupName: 'eShop-connectivity-RG'
      virtualNetworkType: Managed # or Unmanaged (requires addressPrefixes/subnets)
      addressPrefixes:
        - 10.0.0.0/16
      subnets:
        - name: eShop-subnet
          properties:
            addressPrefix: 10.0.1.0/24

    # Identity and RBAC — update azureADGroupId to your tenant's group
    identity:
      type: SystemAssigned
      roleAssignments:
        - azureADGroupId: '<your-eshop-developers-object-id>' # ← UPDATE THIS
          azureADGroupName: 'eShop Developers'
          azureRBACRoles:
            - name: 'Dev Box User'
              id: '45d50f46-0b78-4001-a660-4198cbe8cd05'
              scope: Project
            - name: 'Deployment Environment User'
              id: '18e40d4e-8d2e-438d-97e1-9528336e149c'
              scope: Project
            - name: 'Key Vault Secrets User'
              id: '4633458b-17de-408a-b874-0445c86b69e6'
              scope: ResourceGroup

    # Dev Box pools — each pool is a role-specific VM configuration
    pools:
      - name: 'backend-engineer'
        imageDefinitionName: 'eShop-backend-engineer'
        vmSku: general_i_32c128gb512ssd_v2 # 32 vCPU, 128 GB RAM, 512 GB SSD
      - name: 'frontend-engineer'
        imageDefinitionName: 'eShop-frontend-engineer'
        vmSku: general_i_16c64gb256ssd_v2 # 16 vCPU, 64 GB RAM, 256 GB SSD

    # Environment types available to the project
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: '' # Empty = deploy to the default subscription
      - name: 'staging'
        deploymentTargetId: ''
      - name: 'UAT'
        deploymentTargetId: ''
```

### Key Vault and Security

Configure secrets management in `infra/settings/security/security.yaml`.

> [!NOTE] The Key Vault name must be **globally unique** across all Azure
> tenants. Change `keyVault.name` from the default `contoso` to a unique value
> before deploying to avoid a name collision.

```yaml
create: true # Set to false to reuse an existing Key Vault
keyVault:
  name: contoso # ← Change to a globally unique name
  secretName: gha-token # Name of the secret that stores your PAT
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 7
  enableRbacAuthorization: true
  tags:
    environment: dev
    team: DevExP
    project: Contoso-DevExp-DevBox
```

### Configuration Reference

| Parameter                                 | File                         | Default               | Description                                                      |
| ----------------------------------------- | ---------------------------- | --------------------- | ---------------------------------------------------------------- |
| 📁 `environmentName`                      | `infra/main.parameters.json` | `${AZURE_ENV_NAME}`   | 2–10 char tag appended to resource group names                   |
| 🔒 `secretValue`                          | `infra/main.parameters.json` | `${KEY_VAULT_SECRET}` | GitHub or ADO PAT stored in Key Vault                            |
| ⚙️ `location`                             | `infra/main.parameters.json` | `${AZURE_LOCATION}`   | Azure region — must match the allowed list in `infra/main.bicep` |
| 🌍 `SOURCE_CONTROL_PLATFORM`              | Environment variable         | `github`              | `github` or `adogit`                                             |
| 🔗 `catalogItemSyncEnableStatus`          | `devcenter.yaml`             | `Enabled`             | Auto-sync catalog items in the Dev Center                        |
| 📍 `microsoftHostedNetworkEnableStatus`   | `devcenter.yaml`             | `Enabled`             | Microsoft-hosted network for Dev Boxes                           |
| 📈 `installAzureMonitorAgentEnableStatus` | `devcenter.yaml`             | `Enabled`             | Azure Monitor agent installed on each Dev Box                    |
| 🔑 `keyVault.name`                        | `security.yaml`              | `contoso`             | Globally unique Key Vault name — **must be changed**             |
| 🗓️ `softDeleteRetentionInDays`            | `security.yaml`              | `7`                   | Secret soft-delete retention (7–90 days)                         |

## Deployment

### Step 1: Authenticate

```bash
az login
azd auth login
```

### Step 2: Configure Environment Variables

```bash
# Linux/macOS
export AZURE_ENV_NAME="dev"
export AZURE_LOCATION="eastus2"
export KEY_VAULT_SECRET="<your-github-pat>"
export SOURCE_CONTROL_PLATFORM="github"
```

```powershell
# Windows PowerShell
$env:AZURE_ENV_NAME = "dev"
$env:AZURE_LOCATION = "eastus2"
$env:KEY_VAULT_SECRET = "<your-github-pat>"
$env:SOURCE_CONTROL_PLATFORM = "github"
```

### Step 3: Provision Infrastructure

```bash
azd up
```

The `preprovision` hook in `azure.yaml` (Linux/macOS) or `azure-pwh.yaml`
(Windows) invokes `setUp.sh` or `setUp.ps1`, which:

1. Validates required tools (`az`, `azd`, `gh`, `jq`)
2. Creates the `azd` environment and sets parameters
3. Configures source control platform authentication
4. Seeds Key Vault with the provided secret

### Step 4: Verify the Deployment

```bash
azd show
```

Confirm that all three resource groups appear in the
[Azure Portal](https://portal.azure.com) and that the Dev Center is accessible
under the Workload resource group.

### Cleanup

To remove all provisioned resources:

```powershell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

> [!WARNING] Running `cleanSetUp.ps1` permanently deletes all provisioned Azure
> resource groups, service principals, and GitHub secrets for the specified
> environment. Ensure all workloads are quiesced before proceeding.

## Usage

### Request a Dev Box as a Developer

Once the Dev Center is deployed and your Azure AD account is a member of the
`eShop Developers` group:

1. Navigate to the **Microsoft Dev Box developer portal**:
   [https://devbox.microsoft.com](https://devbox.microsoft.com)
2. Sign in with your organizational Azure AD account.
3. Select **+ New Dev Box**.
4. Choose your **project** (e.g., `eShop`), **pool** (e.g., `backend-engineer`),
   and **environment type** (e.g., `dev`).
5. Click **Create**. Provisioning typically takes 15–30 minutes.

Once ready, connect via **Remote Desktop** directly from the portal or via the
Windows App.

### Verify the Deployment

After `azd up` completes, confirm all resources are healthy:

```bash
# List all outputs from the last deployment
azd show

# Check the Dev Center resource directly
az devcenter admin devcenter show \
  --name devexp-devcenter \
  --resource-group devexp-workload-dev-eastus2-RG

# Verify Key Vault is accessible
az keyvault show --name contoso --query properties.provisioningState

# Confirm the Log Analytics Workspace is active
az monitor log-analytics workspace show \
  --resource-group devexp-monitoring-dev-eastus2-RG \
  --workspace-name logAnalytics-dev-eastus2-RG \
  --query provisioningState
```

All three commands should return `"Succeeded"`.

### Assign Developers to a Project

Add members to the Azure AD group referenced in
`infra/settings/workload/devcenter.yaml` for the target project. For the `eShop`
project, any user in the `eShop Developers` group automatically receives
`Dev Box User` and `Deployment Environment User` roles at the project scope
after deployment.

To add members using the Azure CLI:

```bash
# Add a user to the eShop Developers group
az ad group member add \
  --group "<your-eshop-developers-object-id>" \
  --member-id "$(az ad user show --id user@contoso.com --query id -o tsv)"
```

> [!NOTE] Azure AD group membership changes propagate to Dev Box access within a
> few minutes. Users do not need to redeploy the infrastructure — RBAC is
> evaluated at Dev Box creation time via the group membership.

### Add a New Project

Append a new entry under `projects:` in
`infra/settings/workload/devcenter.yaml`, then run `azd up`. Bicep reconciles
changes idempotently without modifying existing projects.

```yaml
projects:
  - name: 'MyNewProject'
    description: 'Dev Box project for Team X.'
    network:
      name: myproject
      create: true
      resourceGroupName: 'myproject-connectivity-RG'
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.1.0.0/16
      subnets:
        - name: myproject-subnet
          properties:
            addressPrefix: 10.1.1.0/24
      tags:
        environment: dev
        team: TeamX
    identity:
      type: SystemAssigned
      roleAssignments:
        - azureADGroupId: '<your-teamx-group-object-id>'
          azureADGroupName: 'Team X Developers'
          azureRBACRoles:
            - name: 'Dev Box User'
              id: '45d50f46-0b78-4001-a660-4198cbe8cd05'
              scope: Project
            - name: 'Deployment Environment User'
              id: '18e40d4e-8d2e-438d-97e1-9528336e149c'
              scope: Project
    pools:
      - name: 'developer'
        imageDefinitionName: 'myproject-developer'
        vmSku: general_i_16c64gb256ssd_v2
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: ''
    catalogs: []
    tags:
      environment: dev
      team: TeamX
      project: MyNewProject
      costCenter: IT
      owner: Contoso
      resources: Project
```

### Monitor the Dev Center

The Log Analytics Workspace receives diagnostic logs from the Dev Center
automatically. Query usage and health in the
[Azure Portal](https://portal.azure.com) or with the Azure CLI:

```bash
# Open the Log Analytics Workspace in the portal
az monitor log-analytics workspace show \
  --resource-group devexp-monitoring-dev-eastus2-RG \
  --workspace-name logAnalytics-dev-eastus2-RG \
  --query id -o tsv
```

Navigate to **Logs** in that workspace and run queries against the
`DevCenterDiagnosticLogs` table to audit Dev Box provisioning events and
environment deployments.

### Tear Down the Environment

To destroy all provisioned resources for a given environment:

```powershell
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

Alternatively, use `azd down` to remove only the Azure resources while
preserving the `azd` environment configuration:

```bash
azd down --force --purge
```

## Contributing

**Overview**

DevExp-DevBox follows a product-oriented contribution model with structured
Issue tracking, branch naming conventions, and mandatory PR reviews. Whether
adding a new pool configuration template, fixing a Bicep parameter constraint,
or improving documentation, the same lightweight governance process applies
across all contribution types.

Contributions are organized as **Epics → Features → Tasks** using GitHub Issue
Forms. This hierarchy ensures every change is traceable to a measurable outcome,
making it straightforward to understand the impact and context of any PR before
reviewing it.

### Issue Types

| Type       | Template                             | Description                                     |
| ---------- | ------------------------------------ | ----------------------------------------------- |
| 🏔️ Epic    | `.github/ISSUE_TEMPLATE/epic.yml`    | Deliverable outcome spanning multiple features  |
| 🧩 Feature | `.github/ISSUE_TEMPLATE/feature.yml` | Concrete, testable deliverable within an Epic   |
| ✅ Task    | `.github/ISSUE_TEMPLATE/task.yml`    | Small, verifiable unit of work within a Feature |

Every issue **must** carry labels for type, area (`area:dev-box`,
`area:dev-center`, `area:networking`, etc.), priority, and status.

### Branch Naming

| Pattern                   | Example                           |
| ------------------------- | --------------------------------- |
| 🌱 `feature/<short-name>` | `feature/123-dev-center-baseline` |
| 🔧 `fix/<short-name>`     | `fix/456-keyvault-rbac`           |
| 📝 `docs/<short-name>`    | `docs/789-readme-update`          |
| ⚙️ `task/<short-name>`    | `task/012-pool-config`            |

### Pull Request Guidelines

- Every PR must reference a parent Issue number in the description
- Feature branches target `main`; Task branches target their parent Feature
  branch
- All Bicep changes must pass `az bicep lint` before requesting review
- Every **Feature** must link its parent Epic; every **Task** must link its
  parent Feature

## License

This project is licensed under the [MIT License](LICENSE) — Copyright © 2025
[Evilázaro Alves](https://github.com/Evilazaro).

See the `LICENSE` file for full license text.
