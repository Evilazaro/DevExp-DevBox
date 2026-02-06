# DevExp-DevBox

![Build Status](https://img.shields.io/github/actions/workflow/status/Evilazaro/DevExp-DevBox/ci.yml?label=build)
![License](https://img.shields.io/github/license/Evilazaro/DevExp-DevBox)
![Language](https://img.shields.io/github/languages/top/Evilazaro/DevExp-DevBox)
![Status](https://img.shields.io/badge/status-active-brightgreen)

DevExp-DevBox is an Azure accelerator that automates the provisioning and
configuration of
[Microsoft Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
environments using Infrastructure as Code. It enables platform engineering teams
to deploy fully configured, role-specific developer workstations through the
[Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview).

**Overview**

Setting up consistent, secure developer environments across an organization is
time-consuming and error-prone when done manually. DevExp-DevBox solves this by
providing a production-ready accelerator built on
[Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
principles, giving teams a repeatable, governed approach to provisioning Dev Box
infrastructure with proper security, networking, and monitoring from day one.

The accelerator uses Bicep modules to deploy a multi-tier Azure architecture
comprising Dev Center, projects, Dev Box pools, Key Vault, Log Analytics, and
virtual networking. All resource configurations are driven by YAML files,
allowing teams to customize environments, role assignments, catalogs, and pool
definitions without modifying the underlying infrastructure code. The setup
scripts handle authentication with GitHub or Azure DevOps, configure the `azd`
environment, and orchestrate the entire provisioning workflow through a single
command.

DevExp-DevBox follows the
[Microsoft Dev Box deployment guide](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide)
for organizational roles and responsibilities, implementing least-privilege RBAC
assignments for Dev Center administrators, project administrators, and Dev Box
users across multiple projects and environment types.

## Table of Contents

- [Architecture](#-architecture)
- [Features](#-features)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Deployment](#-deployment)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Contributing](#-contributing)
- [License](#-license)

## 🏗️ Architecture

**Overview**

DevExp-DevBox implements a modular, layered architecture that separates concerns
across security, monitoring, connectivity, and workload domains. This separation
follows Azure Landing Zone principles, ensuring each resource group has a clear
responsibility boundary and can be governed independently through Azure Policy
and RBAC.

The infrastructure is orchestrated by a subscription-scoped Bicep entry point
(`infra/main.bicep`) that creates three resource groups and delegates
deployments to domain-specific modules under `src/`. Configuration is
externalized into YAML files under `infra/settings/`, which means teams can
adjust Dev Center settings, security policies, and resource organization without
touching the Bicep templates. This design enables multiple projects and pools to
be defined declaratively and deployed in a single provisioning pass.

```mermaid
---
title: DevExp-DevBox Infrastructure Architecture
config:
  theme: base
  flowchart:
    htmlLabels: false
---
flowchart TB
    accTitle: DevExp-DevBox Infrastructure Architecture
    accDescr: Shows the multi-tier Azure infrastructure with security, monitoring, connectivity, and workload layers

    %% ═══════════════════════════════════════════════════════════════════════════
    %% STANDARD COLOR SCHEME v2.1 - Material Design Compliant
    %% ═══════════════════════════════════════════════════════════════════════════
    %% HIERARCHICAL: Level 1=#E8EAF6 (Indigo 50) - Main container
    %% SEMANTIC: Blue=#BBDEFB (Workload) | Green=#C8E6C9 (Monitoring)
    %%   Orange=#FFE0B2 (Security) | Teal=#B2DFDB (Connectivity)
    %% ═══════════════════════════════════════════════════════════════════════════

    classDef level1Group fill:#E8EAF6,stroke:#3F51B5,stroke-width:3px,color:#000
    classDef mdBlue fill:#BBDEFB,stroke:#1976D2,stroke-width:2px,color:#000
    classDef mdGreen fill:#C8E6C9,stroke:#388E3C,stroke-width:2px,color:#000
    classDef mdOrange fill:#FFE0B2,stroke:#E64A19,stroke-width:2px,color:#000
    classDef mdTeal fill:#B2DFDB,stroke:#00796B,stroke-width:2px,color:#000

    subgraph system["🏢 DevExp-DevBox Infrastructure"]
        direction TB

        subgraph securityLayer["🔒 Security Layer"]
            kv["🔑 Key Vault<br/>(Secrets Management)"]:::mdOrange
            rbac["🛡️ RBAC Assignments<br/>(Least Privilege)"]:::mdOrange
        end

        subgraph monitoringLayer["📊 Monitoring Layer"]
            la["📈 Log Analytics<br/>(Workspace)"]:::mdGreen
        end

        subgraph workloadLayer["⚙️ Workload Layer"]
            dc["🖥️ Dev Center<br/>(Core Platform)"]:::mdBlue
            proj["📁 Projects<br/>(Team Workspaces)"]:::mdBlue
            pools["💻 Dev Box Pools<br/>(Role-Specific VMs)"]:::mdBlue
            cat["📦 Catalogs<br/>(Image & Env Definitions)"]:::mdBlue
            envType["🌐 Environment Types<br/>(Dev / Staging / UAT)"]:::mdBlue
        end

        subgraph connectivityLayer["🔗 Connectivity Layer"]
            vnet["🌐 Virtual Network<br/>(Project Networking)"]:::mdTeal
            netconn["🔌 Network Connection<br/>(DevCenter Attachment)"]:::mdTeal
        end

        dc -->|"hosts"| proj
        proj -->|"contains"| pools
        proj -->|"references"| cat
        proj -->|"uses"| envType
        dc -->|"authenticates via"| kv
        pools -->|"connects through"| netconn
        netconn -->|"attaches to"| vnet
        dc -->|"sends diagnostics to"| la
        rbac -->|"secures"| dc
    end

    %% SUBGRAPH STYLING (5 subgraphs = 5 style directives)
    style system fill:#E8EAF6,stroke:#3F51B5,stroke-width:3px
    style securityLayer fill:#FFE0B2,stroke:#E64A19,stroke-width:2px
    style monitoringLayer fill:#C8E6C9,stroke:#388E3C,stroke-width:2px
    style workloadLayer fill:#BBDEFB,stroke:#1976D2,stroke-width:2px
    style connectivityLayer fill:#B2DFDB,stroke:#00796B,stroke-width:2px

    %% Accessibility: WCAG AA verified (4.5:1 contrast ratio)
```

## ✨ Features

**Overview**

DevExp-DevBox provides a comprehensive set of capabilities designed to reduce
the friction of setting up and governing developer environments at scale. Each
feature addresses a specific operational challenge that platform engineering
teams face when managing Dev Box infrastructure across multiple projects and
teams.

The features work together as a cohesive system: YAML-driven configuration feeds
into modular Bicep templates, which are deployed through automated setup scripts
with built-in authentication handling. This integrated approach means teams can
go from zero to a fully provisioned Dev Box environment with proper security,
networking, and monitoring in a single deployment pass.

| Feature                           | Description                                                                                                                   | Benefits                                                                                                                                                                          |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ⚙️ **YAML-Driven Configuration**  | All Dev Center, security, and resource settings are defined in YAML files under `infra/settings/` with JSON schema validation | Customize environments without modifying Bicep code; schema validation catches errors before deployment                                                                           |
| 🏗️ **Modular Bicep Architecture** | Infrastructure is organized into domain-specific modules (security, monitoring, workload, connectivity) under `src/`          | Independent module updates, clear separation of concerns, and reusable components across projects                                                                                 |
| 🔒 **Integrated Security**        | Key Vault for secrets management, RBAC role assignments following least-privilege principles, and managed identities          | Secure credential storage, auditable access control aligned with [Microsoft's deployment guide](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide) |
| 🌐 **Multi-Project Support**      | Define multiple Dev Center projects with independent pools, catalogs, environment types, and network configurations           | Scale from a single team to an enterprise with per-project isolation and role-specific Dev Box pools                                                                              |
| 🚀 **Automated Provisioning**     | Cross-platform setup scripts (PowerShell and Bash) handle authentication, `azd` environment creation, and resource deployment | Single-command deployment with GitHub or Azure DevOps integration, reducing setup time from hours to minutes                                                                      |

## 📋 Requirements

**Overview**

DevExp-DevBox depends on several Azure and development tools that must be
installed and authenticated before deployment. These prerequisites ensure the
setup scripts can interact with Azure Resource Manager, configure the `azd`
environment, and authenticate with your source control platform.

Meeting these requirements upfront prevents deployment failures and ensures the
provisioning workflow completes successfully. The tools listed below are
actively verified by the setup scripts at runtime, and missing dependencies
produce clear error messages with guidance.

| Category   | Requirement                                                                                                    | More Information                                                        |
| ---------- | -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ☁️ Runtime | [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (az)                                | Required for Azure resource management and authentication               |
| ☁️ Runtime | [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) (azd) | Orchestrates environment creation and Bicep deployments                 |
| 🔧 Tooling | [GitHub CLI](https://cli.github.com/) (gh)                                                                     | Required when using GitHub as the source control platform               |
| 🔧 Tooling | [jq](https://jqlang.github.io/jq/download/)                                                                    | JSON processor used by the Bash setup script                            |
| 🖥️ System  | PowerShell 5.1+ or Bash                                                                                        | PowerShell for Windows (`setUp.ps1`), Bash for Linux/macOS (`setUp.sh`) |
| 🔑 Access  | Azure subscription with Contributor and User Access Administrator roles                                        | Needed to create resource groups, Key Vault, and RBAC assignments       |
| 🔑 Access  | GitHub personal access token (or Azure DevOps PAT)                                                             | Stored in Key Vault for catalog and repository authentication           |

> ⚠️ **Important**: You must have **Contributor** and **User Access
> Administrator** roles on your Azure subscription. The accelerator creates
> resource groups, role assignments, and managed identities that require these
> elevated permissions.

## 🚀 Quick Start

**Overview**

The fastest path to a running Dev Box environment uses the Azure Developer CLI
to provision all infrastructure in a single command. The setup script handles
authentication, environment configuration, and Bicep deployment automatically.

This workflow creates three resource groups (security, monitoring, workload),
deploys Key Vault, Log Analytics, and a Dev Center with projects and pools as
defined in the YAML configuration files.

```bash
# Clone the repository
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox

# Log in to Azure and GitHub
az login
azd auth login
gh auth login

# Provision the environment (Linux/macOS)
azd up

# Expected output:
# SUCCESS: Your Azure Dev Box environment has been provisioned.
# Dev Center: devexp-devcenter
# Projects: eShop
# Resource Groups: devexp-workload-<env>-<region>-RG, devexp-security-<env>-<region>-RG, devexp-monitoring-<env>-<region>-RG
```

> 💡 **Tip**: On Windows, use `azure-pwh.yaml` by renaming it to `azure.yaml` to
> use the PowerShell-based provisioning hooks instead.

## 📦 Deployment

**Overview**

Deployment follows a structured workflow: authenticate with Azure and your
source control platform, configure environment-specific settings, then run the
provisioning scripts. The accelerator supports both an automated path through
`azd up` and a manual path using the setup scripts directly for greater control.

The deployment process creates Azure resources in three phases: security
resources (Key Vault), monitoring resources (Log Analytics), and workload
resources (Dev Center, projects, pools). Each phase depends on outputs from the
previous one, and the Bicep orchestration handles this dependency chain
automatically.

### Step 1: Authenticate

```bash
# Azure CLI authentication
az login

# Azure Developer CLI authentication
azd auth login

# GitHub CLI authentication (if using GitHub source control)
gh auth login
```

### Step 2: Configure Environment

```bash
# Create a new azd environment
azd env new <environment-name>

# Set the Azure region
azd env set AZURE_LOCATION <region>

# Set the GitHub token for Key Vault
azd env set KEY_VAULT_SECRET <your-github-pat>
```

### Step 3: Provision Resources

**Option A: Using `azd` (recommended)**

```bash
azd up
```

**Option B: Using setup scripts directly**

```powershell
# Windows (PowerShell)
.\setUp.ps1 -EnvName "dev" -SourceControl "github"
```

```bash
# Linux/macOS (Bash)
./setUp.sh -e "dev" -s "github"
```

### Step 4: Verify Deployment

```bash
# List deployed resource groups
az group list --query "[?contains(name, 'devexp')]" --output table

# Verify Dev Center creation
az devcenter admin devcenter list --output table
```

## 💻 Usage

**Overview**

Day-to-day usage of DevExp-DevBox centers on editing YAML configuration files and redeploying with `azd up`. Platform engineers add projects, adjust pools, or change environment types by updating the declarative configuration under `infra/settings/` — the Bicep modules pick up those changes automatically on the next provisioning run.

This workflow keeps infrastructure management inside version control, so every change is reviewable, reversible, and auditable. The sections below walk through the most common operations.

### Adding a New Project

Add a project entry to `infra/settings/workload/devcenter.yaml`, then redeploy:

```yaml
projects:
  - name: 'myNewProject'
    description: 'New team project'
    network:
      name: myNewProject
      create: true
      resourceGroupName: 'myNewProject-connectivity-RG'
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.1.0.0/16
      subnets:
        - name: myNewProject-subnet
          properties:
            addressPrefix: 10.1.1.0/24
    pools:
      - name: 'developer'
        imageDefinitionName: 'myNewProject-developer'
        vmSku: general_i_16c64gb256ssd_v2
    environmentTypes:
      - name: 'dev'
        deploymentTargetId: ''
    catalogs: []
    tags:
      environment: dev
      team: MyTeam
```

```bash
# Apply the new project
azd up

# Expected output:
# SUCCESS: Your Azure Dev Box environment has been provisioned.
```

### Modifying Dev Box Pools

Change VM sizes or add new role-specific pools by editing the `pools` array for any project in `infra/settings/workload/devcenter.yaml`:

```yaml
pools:
  - name: 'backend-engineer'
    imageDefinitionName: 'eShop-backend-engineer'
    vmSku: general_i_32c128gb512ssd_v2    # 32 vCPU, 128 GB RAM
  - name: 'frontend-engineer'
    imageDefinitionName: 'eShop-frontend-engineer'
    vmSku: general_i_16c64gb256ssd_v2     # 16 vCPU, 64 GB RAM
```

### Tearing Down Resources

Remove all provisioned infrastructure when an environment is no longer needed:

```powershell
# Windows (PowerShell)
.\cleanSetUp.ps1 -EnvName "dev" -Location "eastus2"
```

```bash
# Or destroy via azd
azd down --purge
```

## 🔧 Configuration

**Overview**

DevExp-DevBox uses a layered YAML configuration approach where each aspect of the infrastructure is defined in its own file under `infra/settings/`. JSON schemas accompany each configuration file, providing validation and editor autocompletion to catch errors before deployment. This design separates what you deploy from how you deploy it — the Bicep templates define the resource structure while YAML files control the values.

The three configuration domains (resource organization, security, and workload) map directly to the architectural layers. Changes to any configuration file take effect on the next `azd up` run, making iterative refinement straightforward without risk of drift between documentation and deployed state.

### Configuration File Structure

```text
infra/settings/
├── resourceOrganization/
│   ├── azureResources.yaml          # Resource group names, tags, create flags
│   └── azureResources.schema.json   # JSON schema for validation
├── security/
│   ├── security.yaml                # Key Vault settings
│   └── security.schema.json         # JSON schema for validation
└── workload/
    ├── devcenter.yaml               # Dev Center, projects, pools, catalogs, RBAC
    └── devcenter.schema.json        # JSON schema for validation
```

> 💡 **Tip**: Each YAML file references its JSON schema via the `# yaml-language-server: $schema=` directive. Editors with YAML language server support (such as VS Code with the [YAML extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)) provide autocompletion and inline validation automatically.

### Resource Organization (`infra/settings/resourceOrganization/azureResources.yaml`)

Defines the three resource groups (workload, security, monitoring), their naming conventions, and tagging strategy. Set `create: false` to reference an existing resource group instead of creating a new one.

```yaml
workload:
  create: true
  name: devexp-workload
  description: prodExp
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: Workload
    resources: ResourceGroup

security:
  create: true
  name: devexp-security
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    # ... same tag structure

monitoring:
  create: true
  name: devexp-monitoring
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    # ... same tag structure
```

Resource group names are suffixed at deploy time with `<environmentName>-<location>-RG` (for example, `devexp-workload-dev-eastus2-RG`).

### Security (`infra/settings/security/security.yaml`)

Configures the Azure Key Vault instance used to store source control tokens and other secrets. The top-level `create` flag controls whether a new Key Vault is provisioned or an existing one is referenced.

```yaml
create: true

keyVault:
  name: contoso                      # Globally unique Key Vault name
  description: Development Environment Key Vault
  secretName: gha-token              # Secret holding the GitHub/ADO PAT

  # Security settings
  enablePurgeProtection: true        # Prevent permanent deletion
  enableSoftDelete: true             # Allow recovery of deleted secrets
  softDeleteRetentionInDays: 7       # Retention period (7-90 days)
  enableRbacAuthorization: true      # Use Azure RBAC instead of access policies

  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: security
    resources: ResourceGroup
```

### Dev Center (`infra/settings/workload/devcenter.yaml`)

This is the primary configuration file. It defines the Dev Center resource, its identity and RBAC assignments, catalogs, environment types, and one or more projects with their pools, networking, and permissions.

#### Core Settings

```yaml
name: "devexp-devcenter"
catalogItemSyncEnableStatus: "Enabled"
microsoftHostedNetworkEnableStatus: "Enabled"
installAzureMonitorAgentEnableStatus: "Enabled"
```

#### Identity and RBAC

The Dev Center uses a system-assigned managed identity. Role assignments follow the [least-privilege guidance](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-deployment-guide#organizational-roles-and-responsibilities):

```yaml
identity:
  type: "SystemAssigned"
  roleAssignments:
    devCenter:
      - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
        name: "Contributor"
        scope: "Subscription"
      - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
        name: "User Access Administrator"
        scope: "Subscription"
      - id: "4633458b-17de-408a-b874-0445c86b69e6"
        name: "Key Vault Secrets User"
        scope: "ResourceGroup"
      - id: "b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
        name: "Key Vault Secrets Officer"
        scope: "ResourceGroup"

    orgRoleTypes:
      - type: DevManager
        azureADGroupId: "<your-azure-ad-group-id>"
        azureADGroupName: "Platform Engineering Team"
        azureRBACRoles:
          - name: "DevCenter Project Admin"
            id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"
            scope: ResourceGroup
```

> ⚠️ **Important**: Replace the `azureADGroupId` values with your own Microsoft Entra ID group IDs. The defaults are sample GUIDs from the Contoso example.

#### Catalogs

Catalogs link Git repositories containing Dev Box image definitions or environment definitions:

```yaml
catalogs:
  - name: "customTasks"
    type: gitHub
    visibility: public
    uri: "https://github.com/microsoft/devcenter-catalog.git"
    branch: "main"
    path: "./Tasks"
```

Set `visibility: private` for repositories that require the Key Vault secret for authentication.

#### Environment Types

Define SDLC stages available to all projects. Leave `deploymentTargetId` empty to use the current subscription:

```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
  - name: "UAT"
    deploymentTargetId: ""
```

#### Projects

Each project contains its own network, identity, pools, catalogs, environment types, and tags:

```yaml
projects:
  - name: "eShop"
    description: "eShop project."

    network:
      name: eShop
      create: true
      resourceGroupName: "eShop-connectivity-RG"
      virtualNetworkType: Managed        # "Managed" or "Unmanaged"
      addressPrefixes:
        - 10.0.0.0/16
      subnets:
        - name: eShop-subnet
          properties:
            addressPrefix: 10.0.1.0/24

    identity:
      type: SystemAssigned
      roleAssignments:
        - azureADGroupId: "<your-azure-ad-group-id>"
          azureADGroupName: "eShop Developers"
          azureRBACRoles:
            - name: "Dev Box User"
              id: "45d50f46-0b78-4001-a660-4198cbe8cd05"
              scope: Project
            - name: "Deployment Environment User"
              id: "18e40d4e-8d2e-438d-97e1-9528336e149c"
              scope: Project

    pools:
      - name: "backend-engineer"
        imageDefinitionName: "eShop-backend-engineer"
        vmSku: general_i_32c128gb512ssd_v2
      - name: "frontend-engineer"
        imageDefinitionName: "eShop-frontend-engineer"
        vmSku: general_i_16c64gb256ssd_v2

    catalogs:
      - name: "environments"
        type: environmentDefinition
        sourceControl: gitHub
        visibility: private
        uri: "https://github.com/Evilazaro/eShop.git"
        branch: "main"
        path: "/.devcenter/environments"
      - name: "devboxImages"
        type: imageDefinition
        sourceControl: gitHub
        visibility: private
        uri: "https://github.com/Evilazaro/eShop.git"
        branch: "main"
        path: "/.devcenter/imageDefinitions"

    environmentTypes:
      - name: "dev"
      - name: "staging"
      - name: "UAT"

    tags:
      environment: "dev"
      team: "DevExP"
      project: "DevExP-DevBox"
```

### Deployment Parameters (`infra/main.parameters.json`)

Environment-specific values injected by `azd` at provisioning time:

```json
{
  "parameters": {
    "environmentName": { "value": "${AZURE_ENV_NAME}" },
    "location": { "value": "${AZURE_LOCATION}" },
    "secretValue": { "value": "${KEY_VAULT_SECRET}" }
  }
}
```

### Configuration Reference

| Setting | File | Description |
|---|---|---|
| `create` | `azureResources.yaml`, `security.yaml` | Controls whether the resource is created or an existing one is referenced |
| `name` | All files | Base name for the resource (suffixed automatically for resource groups) |
| `tags` | All files | Azure resource tags for governance and cost tracking |
| `identity.type` | `devcenter.yaml` | Managed identity type (`SystemAssigned`) |
| `identity.roleAssignments` | `devcenter.yaml` | RBAC bindings for Dev Center and project-level security |
| `virtualNetworkType` | `devcenter.yaml` (per project) | `Managed` (Microsoft-hosted) or `Unmanaged` (bring your own VNet) |
| `visibility` | `devcenter.yaml` (catalogs) | `public` or `private` — private catalogs use the Key Vault secret |
| `vmSku` | `devcenter.yaml` (pools) | VM size for Dev Box instances (e.g., `general_i_16c64gb256ssd_v2`) |

## 🤝 Contributing

**Overview**

Contributions to DevExp-DevBox help improve the developer experience for
platform engineering teams adopting Microsoft Dev Box. Whether you are fixing a
Bicep module, adding support for new VM SKUs, or improving the setup scripts,
every contribution strengthens the accelerator for the community.

The project follows standard GitHub workflows. Fork the repository, create a
feature branch, make your changes, and open a pull request. Bicep files should
include `@description` decorators on all parameters and outputs. YAML
configuration changes should validate against the accompanying JSON schema files
in the same directory.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-improvement`
3. Make your changes and test locally with `azd up`
4. Commit with descriptive messages:
   `git commit -m "feat: add pool auto-scaling configuration"`
5. Push and open a pull request: `git push origin feature/my-improvement`

> 💡 **Tip**: Run `az bicep build --file infra/main.bicep` to validate Bicep
> syntax before submitting your pull request.

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file
for details.
