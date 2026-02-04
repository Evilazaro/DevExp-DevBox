# Azure Dev Center Infrastructure

![License](https://img.shields.io/github/license/Evilazaro/DevExp-DevBox)
![Bicep](https://img.shields.io/badge/IaC-Bicep-blue)
![Azure](https://img.shields.io/badge/cloud-Azure-blue)

Enterprise-ready Infrastructure-as-Code for deploying Azure Dev Center with Dev
Box, enabling self-service developer workstations with role-based access control
and integrated security.

## 🚀 Quick Start

Deploy the infrastructure using Azure Developer CLI:

```bash
azd up
```

This provisions all resources including Dev Center, security controls,
monitoring, and networking.

## 📦 Installation

> ⚠️ **Prerequisites**: Ensure you have Azure CLI (2.50+), Azure Developer CLI
> (1.5+), and an active Azure subscription with Contributor access.

Clone the repository and authenticate:

```bash
git clone https://github.com/Evilazaro/DevExp-DevBox.git
cd DevExp-DevBox
az login
azd auth login
```

Configure your environment:

```bash
./setUp.sh -e "prod" -s "github"
```

This creates an Azure environment with GitHub integration for Dev Center
catalogs.

> 💡 **Tip**: Use `./setUp.ps1` on Windows or `./setUp.sh` on Linux/macOS for
> platform-specific setup scripts.

Deploy the infrastructure:

```bash
azd provision
```

Expected deployment time: 5-10 minutes for a complete environment.

## 💻 Usage

The infrastructure deploys a complete Azure Dev Center environment with three
landing zones:

**Security Landing Zone**: Key Vault stores GitHub tokens and secrets referenced
by Dev Center catalogs.

**Monitoring Landing Zone**: Log Analytics workspace collects diagnostics from
all Dev Center resources.

**Workload Landing Zone**: Dev Center manages projects, dev box pools, and
environment types.

Customize the deployment by editing configuration files in
[`infra/settings/`](infra/settings/):

```bash
# Edit Dev Center configuration
code infra/settings/workload/devcenter.yaml

# Modify resource organization
code infra/settings/resourceOrganization/azureResources.yaml

# Update security settings
code infra/settings/security/security.yaml
```

> ℹ️ **Important**: After modifying settings, run `azd provision` to apply
> changes to your Azure resources.

## 🏗️ Architecture

The infrastructure uses a modular Bicep architecture with separated concerns
across landing zones:

```mermaid
%%{init: {"flowchart": {"htmlLabels": false}} }%%
flowchart TB
    %% ============================================
    %% Azure Dev Center Infrastructure Architecture
    %% Purpose: Infrastructure-as-Code deployment for Azure Dev Box
    %% Assumptions: Bicep templates, Azure subscriptions pre-configured
    %% Last Updated: 2026-02-03
    %% ============================================
    %% STANDARD COLOR SCHEME - MANDATORY
    %% ============================================
    classDef mainGroup fill:#E8EAF6,stroke:#3F51B5,stroke-width:3px,color:#000
    classDef mdBlue fill:#BBDEFB,stroke:#1976D2,stroke-width:2px,color:#000
    classDef mdGreen fill:#C8E6C9,stroke:#388E3C,stroke-width:2px,color:#000
    classDef mdOrange fill:#FFE0B2,stroke:#E64A19,stroke-width:2px,color:#000
    classDef mdTeal fill:#B2DFDB,stroke:#00796B,stroke-width:2px,color:#000
    classDef mdYellow fill:#FFF9C4,stroke:#F57F17,stroke-width:2px,color:#000
    %% ============================================

    subgraph system["Azure Dev Center Infrastructure"]
        direction TB

        subgraph deployment["Deployment Layer"]
            direction LR
            azd["Azure Developer CLI"]:::mdBlue
            bicep["Bicep Templates"]:::mdBlue
        end

        subgraph security["Security Landing Zone"]
            direction TB
            kv["Key Vault"]:::mdOrange
            secrets["Secrets & Tokens"]:::mdOrange
        end

        subgraph monitoring["Monitoring Landing Zone"]
            direction TB
            logs["Log Analytics"]:::mdYellow
        end

        subgraph workload["Workload Landing Zone"]
            direction TB
            dc["Dev Center"]:::mdGreen
            projects["Projects"]:::mdGreen
            pools["Dev Box Pools"]:::mdGreen
            catalogs["Environment Catalogs"]:::mdGreen
        end

        subgraph connectivity["Connectivity"]
            direction TB
            vnet["Virtual Network"]:::mdTeal
            subnet["Subnet"]:::mdTeal
            connection["Network Connection"]:::mdTeal
        end

        azd -->|"Provision Resources"| bicep
        bicep -->|"Create"| security
        bicep -->|"Create"| monitoring
        bicep -->|"Create"| workload
        bicep -->|"Create"| connectivity

        dc -->|"Access Secrets"| kv
        dc -->|"Logs & Metrics"| logs
        dc -->|"Contains"| projects
        projects -->|"Deploy"| pools
        projects -->|"Reference"| catalogs
        pools -->|"Network Access"| vnet
        vnet -->|"Managed By"| connection
        connection -->|"Used By"| dc
    end

    class system mainGroup
```

### Key Components

**Deployment Layer**: Azure Developer CLI orchestrates Bicep template deployment
across subscription scope.

**Security Layer**: Key Vault manages GitHub tokens for catalog synchronization
with RBAC controls.

**Monitoring Layer**: Centralized Log Analytics workspace tracks Dev Center
operations and compliance.

**Workload Layer**: Dev Center resources include projects, dev box pools, and
environment catalogs with role assignments.

**Connectivity Layer**: Virtual networks with network connections enable managed
dev box networking.

## 🤝 Contributing

Contributions are welcome. Please follow these guidelines:

- Submit pull requests against the `main` branch
- Include tests for infrastructure changes
- Update documentation for new features
- Follow Bicep best practices and linting rules

## 📝 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for
details.
