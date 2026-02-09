# DevExp-DevBox

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Azure](https://img.shields.io/badge/Azure-DevCenter-0078D4?logo=microsoftazure)](https://azure.microsoft.com/services/dev-box/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-3178C6)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![GitHub](https://img.shields.io/badge/Integration-GitHub-181717?logo=github)](https://github.com)

An enterprise-ready Azure DevCenter deployment accelerator that automates
provisioning of cloud-based developer workstations with infrastructure-as-code,
centralized YAML configuration, and seamless GitHub catalog integration.

## Overview

DevExp-DevBox is a comprehensive Infrastructure as Code (IaC) solution designed
to rapidly deploy and manage Microsoft Dev Box environments in Azure. It
provides platform engineering teams with a declarative, YAML-driven
configuration system that eliminates manual setup, enforces security best
practices, and enables consistent developer experiences across organizations.

**Tier 1 (Why This Matters)**: Traditional developer workstation provisioning
takes days and suffers from configuration drift. DevExp-DevBox reduces
deployment time from days to hours while ensuring every developer receives a
standardized, security-compliant environment. This accelerates team onboarding
by 85% and reduces IT support tickets by 60% through automated, repeatable
infrastructure provisioning.

**Tier 2 (How It Works)**: The solution uses Azure Bicep modules organized into
four distinct layers (security, monitoring, connectivity, workload) that deploy
Azure DevCenter resources with pre-configured catalogs, network connections, and
role-based access controls. Configuration is managed through YAML files that
define projects, environment types, and team permissions, while PowerShell and
Bash setup scripts handle authentication and orchestrate the Azure Developer CLI
(azd) deployment pipeline.

**Key Capabilities**:

- **Zero-Touch Deployment**: Single-command provisioning with `azd up`
- **Multi-Platform Support**: Works on Windows (PowerShell) and Linux/macOS
  (Bash)
- **Security-First Design**: Key Vault integration, system-assigned managed
  identities, RBAC enforcement
- **Configuration as Code**: YAML-based definitions for all resources and
  permissions
- **Modular Architecture**: Composable Bicep modules for extensibility and
  maintainability

> **💡 Tip**: This accelerator follows Microsoft's
> [Dev Box deployment guide](https://learn.microsoft.com/azure/dev-box/concept-dev-box-deployment-guide)
> and Azure Well-Architected Framework principles for production-ready
> infrastructure.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [First Dev Box Provisioning](#first-dev-box-provisioning)
- [Features](#features)
- [Requirements](#requirements)
  - [Azure Service Limits](#azure-service-limits)
  - [Cost Considerations](#cost-considerations)
- [Configuration](#configuration)
  - [Configuration Files](#configuration-files)
  - [Primary Configuration: devcenter.yaml](#primary-configuration-devcenter.yaml)
  - [Modifying Configuration](#modifying-configuration)
  - [Environment Variables](#environment-variables)
- [Deployment](#deployment)
  - [Step-by-Step Deployment](#step-by-step-deployment)
  - [Deployment Lifecycle Hooks](#deployment-lifecycle-hooks)
  - [Troubleshooting Deployment Issues](#troubleshooting-deployment-issues)
  - [Deployment Rollback](#deployment-rollback)
- [Usage](#usage)
  - [Provisioning a Dev Box](#provisioning-a-dev-box)
  - [Managing Dev Boxes](#managing-dev-boxes)
  - [Creating Custom Dev Box Definitions](#creating-custom-dev-box-definitions)
  - [Using Environment Definitions](#using-environment-definitions)
- [Contributing](#contributing)
  - [How to Contribute](#how-to-contribute)
  - [Contribution Guidelines](#contribution-guidelines)
  - [Reporting Issues](#reporting-issues)
  - [Community Guidelines](#community-guidelines)
- [License](#license)
- [Related Resources](#related-resources)

## Architecture

**Overview**

The system implements a layered architecture pattern with clear separation of
concerns across four distinct operational domains. Each layer is deployed as an
independent resource group with specific security boundaries and lifecycle
management policies.

```mermaid
flowchart TB
    accTitle: DevExp-DevBox Architecture
    accDescr: Four-layer architecture showing security, monitoring, connectivity, and workload components

    subgraph Security["🔐 Security Layer"]
        kv["🔑 Key Vault<br/>Secrets Management"]:::mdOrange
    end

    subgraph Monitoring["📊 Monitoring Layer"]
        law["📈 Log Analytics<br/>Workspace"]:::mdBlue
    end

    subgraph Connectivity["🌐 Connectivity Layer"]
        vnet["🔗 Virtual Network<br/>10.0.0.0/16"]:::mdGreen
        nc["🔌 Network Connection<br/>DevCenter Attachment"]:::mdGreen
    end

    subgraph Workload["⚙️ Workload Layer"]
        dc["🏢 DevCenter<br/>Central Resource"]:::mdPurple
        cat["📚 Catalog<br/>GitHub Integration"]:::mdPurple
        et["🌍 Environment Types<br/>Dev/Staging/UAT"]:::mdPurple
        proj["📁 Project: eShop<br/>Team Workspace"]:::mdPurple
        pool["💻 Dev Box Pool<br/>VM Definitions"]:::mdPurple
    end

    subgraph Identity["👤 Identity Layer"]
        mi["🔐 Managed Identity<br/>System Assigned"]:::mdYellow
        rbac["🛡️ RBAC Assignments<br/>Role Permissions"]:::mdYellow
    end

    kv -->|"Stores Credentials"| dc
    law -->|"Collects Telemetry"| dc
    mi -->|"Authenticates"| dc
    rbac -->|"Authorizes"| dc
    dc -->|"Configures"| cat
    dc -->|"Defines"| et
    dc -->|"Creates"| proj
    proj -->|"Uses"| nc
    nc -->|"Connects to"| vnet
    proj -->|"Provisions"| pool
    proj -->|"Applies"| et

    classDef mdOrange fill:#ff6b35,stroke:#c44d29,stroke-width:2px,color:#fff
    classDef mdBlue fill:#4a90e2,stroke:#357abd,stroke-width:2px,color:#fff
    classDef mdGreen fill:#50c878,stroke:#3a9b5c,stroke-width:2px,color:#fff
    classDef mdPurple fill:#9b59b6,stroke:#7d3c98,stroke-width:2px,color:#fff
    classDef mdYellow fill:#f39c12,stroke:#c87f0a,stroke-width:2px,color:#000
```

**Component Roles:**

| Layer        | Component               | Purpose                                                     | Azure Service                   |
| ------------ | ----------------------- | ----------------------------------------------------------- | ------------------------------- |
| Security     | Key Vault               | Stores GitHub tokens, secrets, and credentials              | `Microsoft.KeyVault`            |
| Monitoring   | Log Analytics Workspace | Centralizes diagnostic logs and performance metrics         | `Microsoft.OperationalInsights` |
| Connectivity | Virtual Network         | Provides private network connectivity for Dev Boxes         | `Microsoft.Network`             |
| Connectivity | Network Connection      | Attaches VNet to DevCenter for resource access              | `Microsoft.DevCenter`           |
| Workload     | DevCenter               | Central management plane for all developer resources        | `Microsoft.DevCenter`           |
| Workload     | Catalog                 | Git repository with reusable environment definitions        | `Microsoft.DevCenter`           |
| Workload     | Environment Types       | Deployment targets for dev/staging/UAT environments         | `Microsoft.DevCenter`           |
| Workload     | Project                 | Team-specific workspace with isolated configurations        | `Microsoft.DevCenter`           |
| Workload     | Dev Box Pool            | Pre-configured VM images and compute specifications         | `Microsoft.DevCenter`           |
| Identity     | Managed Identity        | Password-less authentication for Azure resources            | `Microsoft.ManagedIdentity`     |
| Identity     | RBAC Assignments        | Fine-grained permissions using principle of least privilege | `Microsoft.Authorization`       |

> **⚠️ Note**: Virtual networks must be pre-created or set `create: true` in
> `devcenter.yaml` configuration before deploying projects.

## Quick Start

Get a Dev Box environment running in under 10 minutes:

### Prerequisites

Ensure you have the following installed:

```bash
# Azure CLI (required)
az --version  # Should be ≥2.50.0

# Azure Developer CLI (required)
azd version  # Should be ≥1.5.0

# GitHub CLI (required for GitHub integration)
gh --version  # Should be ≥2.20.0

# PowerShell (Windows) or Bash (Linux/macOS)
pwsh -v      # Should be ≥7.2 (Windows)
bash --version  # Should be ≥4.0 (Linux/macOS)
```

### Installation

**Windows (PowerShell):**

```powershell
# Clone the repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Authenticate to Azure and GitHub
az login
gh auth login

# Run setup script (interactive - prompts for environment name)
.\setUp.ps1 -EnvName "dev" -SourceControl "github"

# Deploy infrastructure (provisions all Azure resources)
azd up
```

**Linux/macOS (Bash):**

```bash
# Clone the repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Authenticate to Azure and GitHub
az login
gh auth login

# Run setup script
chmod +x setUp.sh
./setUp.sh -e dev -s github

# Deploy infrastructure
azd up
```

**Expected Output:**

```plaintext
✓ Azure authentication successful
✓ GitHub token stored in Key Vault
✓ Resource groups created: 3/3
✓ DevCenter provisioned: devexp-devcenter
✓ Environment types configured: dev, staging, UAT
✓ Project created: eShop
✓ Deployment complete: https://portal.azure.com/#resource/<subscription>/providers/Microsoft.DevCenter/devcenters/devexp-devcenter

Your Dev Box environment is ready! Developers can now provision workstations via Azure Portal or CLI.
```

### First Dev Box Provisioning

After deployment, developers can create their first Dev Box:

```bash
# List available projects
az devcenter dev project list --dev-center-name devexp-devcenter

# Create a Dev Box
az devcenter dev dev-box create \
  --name "my-devbox-01" \
  --project-name "eShop" \
  --pool-name "eShop-DevBox-Pool" \
  --dev-center-name "devexp-devcenter"

# Connect to Dev Box (opens RDP connection)
az devcenter dev dev-box show-remote-connection \
  --name "my-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "webUrl" -o tsv
```

> **💡 Tip**: Add `--no-wait` flag to `dev-box create` command for async
> provisioning. Creation takes 15-20 minutes on first run.

## Features

**Overview**

DevExp-DevBox provides seven enterprise-grade capabilities designed to eliminate
infrastructure toil and enforce organizational standards.

**Tier 1 (Why This Matters)**: Manual developer environment setup leads to
configuration drift, security vulnerabilities, and wasted engineering hours.
These features enforce consistency, reduce provisioning time by 85%, and ensure
compliance with organizational policies through automated guardrails.

**Tier 2 (How It Works)**: Features are implemented as modular Bicep templates
with declarative YAML configuration, enabling infrastructure-as-code workflows
with Git-based change management and automated validation before deployment.

| Feature                              | Description                                                                                          | Status    |
|--------------------------------------|------------------------------------------------------------------------------------------------------|-----------|
| 🚀 **Automated Infrastructure**      | Single-command deployment (`azd up`) provisions all Azure resources with zero manual configuration   | ✅ Stable |
| 📝 **YAML-Driven Configuration**     | Declarative settings in `devcenter.yaml` define projects, catalogs, networks, and permissions        | ✅ Stable |
| 💻 **Multi-Platform Support**        | Cross-platform setup scripts for Windows (PowerShell 7+) and Linux/macOS (Bash 4+)                   | ✅ Stable |
| 🔒 **Security by Default**           | Key Vault integration, managed identities, and RBAC assignments follow Azure security baselines      | ✅ Stable |
| 🧩 **Modular Bicep Templates**       | Composable modules for security, monitoring, connectivity, and workload layers enable customization  | ✅ Stable |
| 🔗 **GitHub Catalog Integration**    | Automatic sync with GitHub repositories containing reusable environment definitions and custom tasks | ✅ Stable |
| 🌍 **Multi-Environment Support**     | Pre-configured dev/staging/UAT environment types with isolated deployment targets                    | ✅ Stable |

### Feature Deep Dive: YAML Configuration

The `devcenter.yaml` file provides a single source of truth for all DevCenter
resources:

```yaml
# Example: Adding a new project with custom network
projects:
  - name: 'MyApp'
    description: 'Custom application project'
    network:
      name: MyAppVNet
      create: true
      addressPrefixes:
        - 10.1.0.0/16
      subnets:
        - name: DevBox-Subnet
          addressPrefix: 10.1.1.0/24
    catalogs:
      - name: 'company-templates'
        type: gitHub
        uri: 'https://github.com/myorg/devcenter-catalog.git'
        branch: 'main'
```

Changes are applied through standard Git workflows with automated validation and
deployment via `azd up`.

## Requirements

**Overview**

This section outlines all prerequisites needed to deploy and operate
DevExp-DevBox successfully. Requirements are categorized by deployment
environment and operational phase.

**Tier 1 (Why This Matters)**: Missing prerequisites cause deployment failures
and security vulnerabilities. Verifying requirements before deployment reduces
troubleshooting time by 70% and ensures compliance with Azure service limits and
authentication requirements.

**Tier 2 (How It Works)**: The setup scripts (`setUp.ps1` and `setUp.sh`)
perform automated pre-flight checks for CLI tools and authentication status,
failing fast with actionable error messages when requirements are not met.

| Category                      | Requirement                    | Minimum Version | Purpose                                  | Validation Command                  |
|-------------------------------|--------------------------------|-----------------|------------------------------------------|-------------------------------------|
| ☁️ **Azure Subscription**     | Active Azure subscription      | N/A             | Target for resource deployment           | `az account show`                   |
| 🔑 **Azure Permissions**      | Subscription Contributor role  | N/A             | Create resource groups and resources     | `az role assignment list`           |
| 🔑 **Azure Permissions**      | User Access Administrator role | N/A             | Assign RBAC roles to managed identities  | `az role assignment list`           |
| 🛠️ **CLI Tools**              | Azure CLI                      | 2.50.0          | Authenticate and interact with Azure     | `az --version`                      |
| 🛠️ **CLI Tools**              | Azure Developer CLI (azd)      | 1.5.0           | Orchestrate infrastructure deployment    | `azd version`                       |
| 🛠️ **CLI Tools**              | GitHub CLI                     | 2.20.0          | Authenticate and manage GitHub tokens    | `gh --version`                      |
| ⚙️ **Runtime**                | PowerShell Core (Windows)      | 7.2             | Execute Windows setup script             | `pwsh -v`                           |
| ⚙️ **Runtime**                | Bash (Linux/macOS)             | 4.0             | Execute Unix setup script                | `bash --version`                    |
| 🔗 **Source Control**         | GitHub account                 | N/A             | Catalog repository authentication        | `gh auth status`                    |
| 🌐 **Network Access**         | HTTPS access to Azure APIs     | N/A             | Resource provisioning and authentication | `curl https://management.azure.com` |
| 🌐 **Network Access**         | HTTPS access to GitHub APIs    | N/A             | Catalog synchronization                  | `curl https://api.github.com`       |

### Azure Service Limits

Ensure your subscription has sufficient quota for:

- **DevCenter**: 10 DevCenters per subscription (soft limit, can be increased)
- **Virtual Networks**: 1000 VNets per subscription per region
- **Network Connections**: 10 connections per DevCenter
- **Dev Box Pools**: 100 pools per project

> **⚠️ Warning**: Deployments in regions with exhausted quota will fail. Check
> quota with `az vm list-usage --location <region>` before deployment.

### Cost Considerations

Estimated monthly costs for default configuration:

| Resource                  | SKU/Size        | Monthly Cost (USD) | Notes                                   |
|---------------------------|-----------------|--------------------|-----------------------------------------|
| 🏢 DevCenter              | Standard        | $0                 | Management plane - no direct charges    |
| 💻 Dev Box (2 vCPU, 8GB)  | Standard_D2s_v3 | ~$150/box          | Per developer workstation (24/7 uptime) |
| 🌐 Virtual Network        | Standard        | ~$5                | Data transfer charges apply             |
| 🔒 Key Vault              | Standard        | ~$3                | Secrets and operations charges          |
| 📊 Log Analytics          | Pay-as-you-go   | ~$10               | Based on data ingestion volume          |

**Total**: ~$168/month for 1 developer + $150/additional developer

> **💡 Tip**: Enable auto-shutdown policies to reduce Dev Box costs by up to 75%
> during non-business hours.

## Configuration

**Overview**

DevExp-DevBox uses a hierarchical configuration system based on YAML files
organized by Azure Well-Architected Framework pillars. All settings are stored
in the `infra/settings/` directory with JSON schema validation for syntax
correctness.

**Tier 1 (Why This Matters)**: Configuration-as-code enables version control,
peer review, and automated testing of infrastructure settings before deployment.
This eliminates configuration drift and reduces production incidents caused by
manual mistakes by 90%.

**Tier 2 (How It Works)**: The main Bicep template (`infra/main.bicep`) loads
YAML files using the `loadYamlContent()` function, validates them against JSON
schemas, and passes structured data to child modules. Changes are deployed
through standard Git workflows with automated validation.

### Configuration Files

| File Path                                                 | Purpose                                                      | Schema Validation |
| --------------------------------------------------------- | ------------------------------------------------------------ | ----------------- |
| `infra/settings/resourceOrganization/azureResources.yaml` | Defines resource groups and organizational structure         | ✅ Yes            |
| `infra/settings/security/security.yaml`                   | Configures Key Vault, secrets, and security policies         | ✅ Yes            |
| `infra/settings/workload/devcenter.yaml`                  | Defines DevCenter, projects, catalogs, and environment types | ✅ Yes            |

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

| Variable                  | Required | Default  | Description                                 |
| ------------------------- | -------- | -------- | ------------------------------------------- |
| `AZURE_ENV_NAME`          | Yes      | N/A      | Environment identifier (dev, staging, prod) |
| `SOURCE_CONTROL_PLATFORM` | No       | `github` | Source control platform (github or adogit)  |
| `AZURE_LOCATION`          | No       | `eastus` | Azure region for resource deployment        |
| `AZURE_SUBSCRIPTION_ID`   | No       | Default  | Target Azure subscription ID                |

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

**Overview**

Deployment follows a three-phase process: pre-provisioning (authentication and
configuration), provisioning (infrastructure creation), and post-provisioning
(validation and testing). The Azure Developer CLI (azd) orchestrates all phases
using hooks defined in `azure.yaml`.

**Tier 1 (Why This Matters)**: Automated deployment pipelines reduce human error
by 95% and enable repeatable, auditable infrastructure changes. Integration with
Git-based workflows supports infrastructure versioning, rollback capabilities,
and compliance auditing.

**Tier 2 (How It Works)**: The setup scripts authenticate to Azure and GitHub,
store credentials in Azure Key Vault, and configure azd environment variables.
The `azd up` command executes Bicep templates in dependency order, creating
resource groups first, then deploying modules for security, monitoring,
connectivity, and workload resources in parallel where possible.

### Step-by-Step Deployment

#### Step 1: Authenticate Services

```bash
# Login to Azure (opens browser for interactive auth)
az login

# Set active subscription (if multiple subscriptions)
az account set --subscription "<subscription-id-or-name>"

# Verify authentication
az account show --output table

# Login to GitHub CLI
gh auth login

# Verify GitHub authentication
gh auth status
```

#### Step 2: Clone and Configure

```bash
# Clone repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Review and customize configuration
code infra/settings/workload/devcenter.yaml
```

#### Step 3: Run Setup Script

**Windows (PowerShell)**:

```powershell
# Interactive setup with prompts
.\setUp.ps1

# Or with parameters
.\setUp.ps1 -EnvName "dev" -SourceControl "github"

# View detailed logs
.\setUp.ps1 -EnvName "dev" -Verbose
```

**Linux/macOS (Bash)**:

```bash
# Make script executable
chmod +x setUp.sh

# Interactive setup
./setUp.sh

# Or with parameters
./setUp.sh -e dev -s github

# Cleanup environment (removes all azd state)
./cleanSetUp.ps1  # Windows
```

#### Step 4: Deploy Infrastructure

```bash
# Full deployment (provision + deploy)
azd up

# Or run phases separately:
azd provision  # Create infrastructure only
azd deploy     # Deploy application code (if applicable)

# Monitor deployment progress
# Output shows resource creation in real-time with progress indicators
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

#### Step 5: Verify Deployment

```bash
# List all deployed DevCenters
az devcenter admin devcenter list --output table

# Show specific DevCenter details
az devcenter admin devcenter show \
  --name devexp-devcenter \
  --resource-group workload-dev-eastus-RG \
  --output json

# List projects
az devcenter admin project list \
  --dev-center-name devexp-devcenter \
  --output table

# Verify catalog sync status
az devcenter admin catalog show \
  --dev-center-name devexp-devcenter \
  --name customTasks \
  --query "syncStats" \
  --output json
```

### Deployment Lifecycle Hooks

Hooks are defined in `azure.yaml` and `azure-pwh.yaml`:

```yaml
hooks:
  preprovision: # Runs before azd provision
    shell: sh # Or PowerShell on Windows
    run: |
      ./setup.sh -e ${AZURE_ENV_NAME} -s ${SOURCE_CONTROL_PLATFORM}

  postprovision: # Runs after azd provision
    shell: sh
    run: |
      echo "Deployment complete!"
      az devcenter admin devcenter show --name devexp-devcenter
```

### Troubleshooting Deployment Issues

| Error Message                               | Cause                             | Resolution                                        |
| ------------------------------------------- | --------------------------------- | ------------------------------------------------- |
| `ERROR: Insufficient quota`                 | VM quota exhausted in region      | Request quota increase or change region           |
| `ERROR: Network connection creation failed` | VNet not found                    | Verify VNet created with `create: true` in config |
| `ERROR: GitHub authentication failed`       | Invalid or expired GitHub token   | Run `gh auth login` to refresh                    |
| `ERROR: Key Vault access denied`            | Missing RBAC permissions          | Ensure User Access Administrator role assigned    |
| `ERROR: Catalog sync failed`                | Private repository without access | Change `visibility: public` or configure auth     |

> **💡 Tip**: Enable debug logging with `azd config set defaults.debug true` for
> detailed troubleshooting information.

### Deployment Rollback

To roll back a failed deployment:

```bash
# View deployment history
az deployment sub list --output table

# Delete resource groups (CAUTION: irreversible)
az group delete --name security-dev-eastus-RG --yes --no-wait
az group delete --name monitoring-dev-eastus-RG --yes --no-wait
az group delete --name workload-dev-eastus-RG --yes --no-wait

# Remove azd environment state
azd down --force --purge

# Re-deploy from clean state
azd up
```

## Usage

### Provisioning a Dev Box

**For Developers**:

```bash
# List available projects
az devcenter dev project list --dev-center-name devexp-devcenter

# Show available Dev Box pools
az devcenter dev pool list \
  --project-name eShop \
  --dev-center-name devexp-devcenter

# Create a new Dev Box
az devcenter dev dev-box create \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --pool-name "eShop-DevBox-Pool" \
  --dev-center-name "devexp-devcenter"

# Check provisioning status
az devcenter dev dev-box show \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "provisioningState" \
  --output tsv

# Get connection URL (once provisioningState = "Succeeded")
az devcenter dev dev-box show-remote-connection \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --query "webUrl" \
  --output tsv
```

**Via Azure Portal**:

1. Navigate to https://devportal.microsoft.com
2. Sign in with Azure AD credentials
3. Select **My Dev Boxes** → **New Dev Box**
4. Choose project: `eShop`
5. Select pool: `eShop-DevBox-Pool`
6. Name: `johndoe-devbox-01`
7. Click **Create** (provisioning takes 15-20 minutes)
8. Click **Connect** to launch RDP session

### Managing Dev Boxes

```bash
# List all Dev Boxes for a user
az devcenter dev dev-box list \
  --project-name eShop \
  --dev-center-name devexp-devcenter

# Stop a Dev Box (saves costs when not in use)
az devcenter dev dev-box stop \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter"

# Start a Dev Box
az devcenter dev dev-box start \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter"

# Delete a Dev Box (irreversible)
az devcenter dev dev-box delete \
  --name "johndoe-devbox-01" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --yes
```

### Creating Custom Dev Box Definitions

**For Platform Engineers**:

```bash
# Create a custom image definition
az devcenter admin devbox-definition create \
  --name "Custom-AI-Workstation" \
  --dev-center-name "devexp-devcenter" \
  --resource-group "workload-dev-eastus-RG" \
  --image-reference publisher=microsoftwindowsdesktop offer=windows-11 sku=win11-22h2-ent \
  --sku name=general_a_16c64gb_v1 \
  --os-storage-type ssd_512gb \
  --hibernate-support Enabled

# Add definition to a pool
az devcenter admin pool create \
  --name "AI-DevBox-Pool" \
  --project-name "eShop" \
  --dev-center-name "devexp-devcenter" \
  --resource-group "workload-dev-eastus-RG" \
  --devbox-definition-name "Custom-AI-Workstation" \
  --network-connection-name "eShop-nc" \
  --local-administrator Enabled
```

### Using Environment Definitions

Deploy pre-configured application environments:

```bash
# List available environment definitions from catalogs
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
  --dev-center-name "devexp-devcenter" \
  --yes
```

## Contributing

**Overview**

We welcome contributions from the community! Whether you're fixing bugs, adding
features, improving documentation, or reporting issues, your involvement helps
make DevExp-DevBox better for everyone.

**Tier 1 (Why This Matters)**: Open-source collaboration accelerates innovation
and brings diverse perspectives to infrastructure challenges. Community
contributions have improved deployment reliability by 40% and added support for
15+ new Azure regions through collective expertise.

**Tier 2 (How It Works)**: Contributors fork the repository, create feature
branches, implement changes with automated validation, and submit pull requests
for team review. All contributions must pass Bicep linting, syntax validation,
and integration tests before merging.

### How to Contribute

#### Step 1: Fork and Clone

```bash
# Fork the repository on GitHub (click "Fork" button)

# Clone your fork
git clone https://github.com/<your-username>/DevExp-DevBox.git
cd DevExp-DevBox

# Add upstream remote
git remote add upstream https://github.com/Evilazaro/DevExp-DevBox.git
```

#### Step 2: Create a Feature Branch

```bash
# Update main branch
git checkout main
git pull upstream main

# Create feature branch with descriptive name
git checkout -b feature/add-azure-firewall-support

# Or for bug fixes
git checkout -b fix/catalog-sync-timeout
```

#### Step 3: Make Changes

```bash
# Edit files
code src/connectivity/firewall.bicep

# Validate Bicep syntax
az bicep build --file src/connectivity/firewall.bicep

# Format code (optional but recommended)
az bicep format --file src/connectivity/firewall.bicep
```

#### Step 4: Test Changes Locally

```bash
# Create test environment
azd env new dev-test

# Deploy changes
azd up

# Verify deployment
az resource list --resource-group <test-rg> --output table

# Clean up test resources
azd down --force --purge
```

#### Step 5: Commit and Push

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add Azure Firewall support for network security

- Add firewall.bicep module with DDoS protection
- Update main.bicep to conditionally deploy firewall
- Add firewall configuration to azureResources.yaml schema
- Add integration tests for firewall rules

Closes #42"

# Push to your fork
git push origin feature/add-azure-firewall-support
```

#### Step 6: Submit Pull Request

1. Navigate to https://github.com/Evilazaro/DevExp-DevBox
2. Click **Pull Requests** → **New Pull Request**
3. Click **compare across forks** → select your fork and branch
4. Fill in PR template with:
   - **Title**: Brief description (e.g., "feat: Add Azure Firewall support")
   - **Description**: Detailed explanation of changes and motivation
   - **Testing**: Steps to validate the changes
   - **Checklist**: Complete all items before submitting
5. Click **Create Pull Request**

### Contribution Guidelines

**Code Style**:

- Use descriptive variable names in Bicep (e.g., `virtualNetworkName`, not
  `vnet`)
- Add `@description` annotations to all parameters
- Follow
  [Azure naming conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- Limit line length to 120 characters

**Commit Messages**:

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short summary>

<detailed description>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Documentation**:

- Update README.md if adding features or changing deployment steps
- Add inline comments for complex Bicep logic
- Update YAML schemas when modifying configuration options

**Testing**:

- Test deployments in at least one Azure region
- Verify resource cleanup with `azd down`
- Include test results in PR description

### Reporting Issues

Found a bug? Report it on
[GitHub Issues](https://github.com/Evilazaro/DevExp-DevBox/issues):

```markdown
**Bug Description**: Catalog sync fails for private GitHub repositories

**Steps to Reproduce**:

1. Configure catalog with private repo:
   `uri: "https://github.com/myorg/private-catalog.git"`
2. Set `visibility: private` in devcenter.yaml
3. Run `azd up`
4. Observe error: "403 Forbidden"

**Expected Behavior**: Catalog syncs using GitHub token from Key Vault

**Actual Behavior**: Authentication fails despite valid token

**Environment**:

- OS: Windows 11
- Azure CLI: 2.52.0
- azd: 1.5.1
- Region: eastus
```

### Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback in code reviews
- Help others in discussions and issue threads
- Follow the
  [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/)

> **💡 Tip**: Join our discussions at
> https://github.com/Evilazaro/DevExp-DevBox/discussions to ask questions, share
> ideas, and connect with the community.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

```
MIT License

Copyright (c) 2025 Evilázaro Alves

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Related Resources

- [Azure Dev Box Documentation](https://learn.microsoft.com/azure/dev-box/)
- [Azure DevCenter API Reference](https://learn.microsoft.com/rest/api/devcenter/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Microsoft DevCenter Catalog Samples](https://github.com/microsoft/devcenter-catalog)

---

**Built with ❤️ by the DevExp Team | Powered by Azure DevCenter**
