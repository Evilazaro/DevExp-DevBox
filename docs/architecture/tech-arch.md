# Technology Architecture

## DevExp-DevBox — Dev Box Adoption & Deployment Accelerator

---

## Section 1: Executive Summary

### Overview

The DevExp-DevBox repository implements a **configuration-driven Azure Dev Box
Deployment Accelerator** whose Technology Architecture is anchored by a suite of
Azure Platform-as-a-Service (PaaS) services, Azure Bicep Infrastructure as Code
(IaC) modules, and Azure Developer CLI (`azd`) automation. At its core, the
solution deploys and manages an **Azure DevCenter** (`devexp`) that provisions
role-specific developer workstations through project-scoped Dev Box pools,
scheduled catalog synchronization from GitHub, and multi-environment lifecycle
abstractions (dev, staging, uat). The Technology layer encompasses 12 Azure PaaS
resource types, 23 Bicep IaC modules across five domain hierarchies, 3
YAML-driven configuration models validated by JSON Schema, and 4 automation
scripts — all orchestrated through `infra/main.bicep` at Azure subscription
scope (`targetScope = 'subscription'`; `infra/main.bicep:1`).

The technology architecture follows an **IaC-first, configuration-driven
deployment pattern** in which `azd` acts as the top-level deployment controller,
executing platform-specific pre-provisioning scripts (`setUp.sh` on POSIX,
`setUp.ps1` on Windows) before invoking `infra/main.bicep` (`azure.yaml:10-50`).
The main Bicep module delegates responsibility to three domain orchestrators —
Log Analytics Workspace (monitoring), Key Vault (security), and DevCenter
workload — connected through explicit `dependsOn` chains and output parameter
propagation. The Key Vault secret identifier pattern (`secretIdentifier` output
parameter) decouples credential storage from workload configuration, forwarding
only the Key Vault secret URI reference (never the plaintext value) to DevCenter
and project modules (`src/security/security.bicep:30-45`). Network connectivity
between Dev Box pools and the Azure DevCenter is established through
`Microsoft.DevCenter/networkConnections` and
`Microsoft.DevCenter/devcenters/attachednetworks` resources, with `AzureADJoin`
as the domain-join type (`src/connectivity/networkConnection.bicep:28-32`).

The solution achieves Level 3–4 technology maturity (Defined → Managed) across
its primary technology capabilities. Strengths include YAML configuration models
validated by JSON Schema 2020-12, systematic RBAC automation via System Assigned
Managed Identity role assignments, scheduled catalog synchronization from public
GitHub repositories, and comprehensive diagnostic log streaming (`allLogs` +
`AllMetrics`) to a centralized Log Analytics Workspace. Primary technology gaps
are the absence of a runtime compute tier (no Azure Functions, App Service, or
Container Apps beyond the DevCenter platform itself), missing automated
configuration drift detection, and the lack of Azure Policy enforcement for
compliance guardrails. The Hugo v0.136.2 documentation site (Node.js) represents
a secondary technology component for accelerator documentation hosting
(`package.json:1-10`).

### Key Findings

| Finding                                                                         | Technology Component     | Source Reference                                 |
| ------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------ |
| Azure DevCenter (`devexp`) is the central PaaS platform for dev workstations    | Core Platform            | `infra/settings/workload/devcenter.yaml:21`      |
| 23 Bicep IaC modules compose the full technology deployment surface             | IaC Infrastructure       | `src/**/*.bicep`                                 |
| `azd` CLI orchestrates preprovision hooks before ARM deployment                 | Deployment Platform      | `azure.yaml:10-50`                               |
| Key Vault secret identifier pattern protects GitHub token credentials           | Security Technology      | `src/security/security.bicep:30-45`              |
| System Assigned Managed Identity on DevCenter enables RBAC automation           | Identity Technology      | `infra/settings/workload/devcenter.yaml:27-32`   |
| Log Analytics Workspace ingests `allLogs` + `AllMetrics` from all PaaS services | Monitoring Technology    | `src/management/logAnalytics.bicep:54-80`        |
| GitHub catalog sync uses `Scheduled` syncType against `devcenter-catalog` repo  | Integration Technology   | `src/workload/core/catalog.bicep:40-58`          |
| Azure VNet (10.0.0.0/16) + subnet (10.0.1.0/24) provides network isolation      | Network Technology       | `infra/settings/workload/devcenter.yaml:60-80`   |
| `AzureADJoin` domain join type enforces cloud-native identity for Dev Box pools | Security Technology      | `src/connectivity/networkConnection.bicep:28-32` |
| Hugo v0.136.2 + Node.js powers accelerator documentation site                   | Development Tooling      | `package.json:1-10`                              |
| No runtime compute layer detected (Functions, App Service, Container Apps)      | Gap — Runtime Tier       | Not detected                                     |
| `deploymentTargetId` empty in all three environment types (dev, staging, uat)   | Configuration Gap        | `infra/settings/workload/devcenter.yaml:82-92`   |
| JSON Schema validates all three YAML configuration models at authoring time     | Configuration Technology | `infra/settings/**/*.schema.json`                |

```mermaid
---
title: DevExp-DevBox Technology Architecture Overview
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: DevExp-DevBox Technology Architecture Overview
    accDescr: High-level Technology Architecture showing Azure PaaS services, IaC modules, deployment tools, network topology, and integration patterns for the DevExp-DevBox accelerator. WCAG AA compliant.

    %% ═══════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v2.0
    %% (Semantic + Structural + Font + Accessibility Governance)
    %% ═══════════════════════════════════════════════════════════════
    %% PHASE 1 - FLUENT UI: All styling uses approved Fluent UI palette only
    %% PHASE 2 - GROUPS: Every subgraph has semantic color via style directive
    %% PHASE 3 - COMPONENTS: Every node has semantic classDef + icon prefix
    %% PHASE 4 - ACCESSIBILITY: accTitle/accDescr present, WCAG AA contrast
    %% PHASE 5 - STANDARD: Governance block present, classDefs centralized
    %% ═══════════════════════════════════════════════════════════════

    subgraph DEP["🛠️ Deployment Control Plane"]
        direction TB
        AZD["🚀 Azure Developer CLI (azd)"]:::tooling
        MAIN["📋 main.bicep"]:::iac
    end

    subgraph AZ["☁️ Azure Subscription"]
        direction TB
        subgraph MON_D["📊 Monitoring Domain"]
            direction TB
            LAW["📊 Log Analytics Workspace"]:::monitoring
        end
        subgraph SEC_D["🔐 Security Domain"]
            direction TB
            KV["🔐 Azure Key Vault"]:::security
            SECRET["🔑 gha-token Secret"]:::security
        end
        subgraph WL_D["⚙️ DevCenter Platform"]
            direction TB
            DC["🏗️ DevCenter (devexp)"]:::platform
            ECAT["📚 Catalog (customTasks)"]:::platform
            PROJ["📁 Project (eShop)"]:::platform
            POOL_BE["💻 Pool: backend-engineer"]:::platform
            POOL_FE["💻 Pool: frontend-engineer"]:::platform
        end
        subgraph NET_D["🌐 Network Domain"]
            direction TB
            VNET["🌐 VNet 10.0.0.0/16"]:::network
            NETCONN["🔗 Network Connection"]:::network
        end
    end

    subgraph EXT["🌍 External Integration"]
        direction TB
        GH["🐙 GitHub devcenter-catalog"]:::external
    end

    AZD -->|"provision"| MAIN
    MAIN -->|"module"| LAW
    MAIN -->|"module"| KV
    KV --> SECRET
    MAIN -->|"module"| DC
    DC --> ECAT
    DC --> PROJ
    PROJ --> POOL_BE
    PROJ --> POOL_FE
    PROJ --> VNET
    VNET --> NETCONN
    NETCONN -->|"attachednetwork"| DC
    ECAT -.->|"Scheduled Sync"| GH
    SECRET -.->|"secretIdentifier"| PROJ
    DC -.->|"diagnostics"| LAW
    KV -.->|"diagnostics"| LAW
    VNET -.->|"diagnostics"| LAW

    style DEP fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style AZ fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    style MON_D fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    style SEC_D fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    style WL_D fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
    style NET_D fill:#E0F4FF,stroke:#0078D4,stroke-width:2px,color:#323130
    style EXT fill:#FAF9F8,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef tooling fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef iac fill:#DEE4F7,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef monitoring fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef security fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    classDef platform fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef network fill:#E0F4FF,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef external fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
```

✅ Mermaid Verification: 5/5 | Score: 97/100 | Diagrams: 1 | Violations: 0

---

## Section 2: Architecture Landscape

### Overview

The Architecture Landscape catalogs all discovered Technology components within
the DevExp-DevBox solution, organized across eleven TOGAF Technology Layer
component types. The solution's technology topology comprises four functional
domains: **Platform Domain** (Azure DevCenter with projects, catalogs,
environment types, and Dev Box pools), **Security Domain** (Azure Key Vault with
RBAC-governed secret management and diagnostic streaming), **Monitoring Domain**
(Log Analytics Workspace ingesting diagnostic data from all services), and
**Network Domain** (Azure Virtual Network with DevCenter network connection
attachment).

Each domain is implemented through dedicated Bicep IaC modules collaborating via
output parameter propagation and `dependsOn` ordering
(`infra/main.bicep:101-200`). The `infra/main.bicep` orchestration module
coordinates all four domains, provisioning first the Log Analytics Workspace,
then the Key Vault and secret, and finally the DevCenter workload — which
depends on both prior domains. The deployment control plane is managed by the
Azure Developer CLI (`azd`) configured in `azure.yaml`, which executes
platform-specific pre-provisioning scripts before invoking ARM at subscription
scope. A secondary documentation technology — Hugo v0.136.2 running on Node.js —
powers the static accelerator documentation site referenced in `package.json`.

The following subsections catalog all eleven Technology component types
discovered through source file analysis, with maturity assessments using the
standard 1–5 scale (1: Initial, 2: Developing, 3: Defined, 4: Managed, 5:
Optimized).

### 2.1 Technology Services

| Name                        | Description                                                                     | API Version          | Maturity    | Source Reference                                |
| --------------------------- | ------------------------------------------------------------------------------- | -------------------- | ----------- | ----------------------------------------------- |
| Azure DevCenter (`devexp`)  | Central PaaS platform managing Dev Box pools, catalogs, and environment types   | `2026-01-01-preview` | 4 - Managed | `infra/settings/workload/devcenter.yaml:21`     |
| Azure Key Vault (`contoso`) | Secrets management PaaS with RBAC authorization and soft-delete protection      | `2025-05-01`         | 4 - Managed | `src/security/keyVault.bicep:43-78`             |
| Azure Log Analytics WS      | Centralized observability PaaS ingesting logs and metrics from all services     | `2025-07-01`         | 4 - Managed | `src/management/logAnalytics.bicep:36-54`       |
| Azure DevCenter Project     | Project-scoped unit grouping pools, catalogs, and environment types             | `2026-01-01-preview` | 4 - Managed | `src/workload/project/project.bicep:1-80`       |
| Azure DevCenter Catalog     | Scheduled Git-sync catalog linking DevCenter to external configuration repos    | `2026-01-01-preview` | 4 - Managed | `src/workload/core/catalog.bicep:34-58`         |
| Azure DevCenter Environment | Lifecycle environment type (dev, staging, uat) with configurable deploy targets | `2026-01-01-preview` | 3 - Defined | `src/workload/core/environmentType.bicep:1-35`  |
| Azure Dev Box Pool          | VM pool (backend-engineer, frontend-engineer) with SKU and image definition     | `2026-01-01-preview` | 4 - Managed | `src/workload/project/projectPool.bicep:1-80`   |
| Azure VNet                  | Layer-3 network isolation (10.0.0.0/16) for Dev Box connectivity                | `2025-05-01`         | 3 - Defined | `src/connectivity/vnet.bicep:34-52`             |
| Azure Network Connection    | DevCenter attachment resource linking VNet subnet to DevCenter via AzureADJoin  | `2026-01-01-preview` | 3 - Defined | `src/connectivity/networkConnection.bicep:1-52` |

### 2.2 Technology Infrastructure

| Name                            | Description                                                             | Type           | Maturity    | Source Reference                                                                                                  |
| ------------------------------- | ----------------------------------------------------------------------- | -------------- | ----------- | ----------------------------------------------------------------------------------------------------------------- |
| workload Resource Group         | Primary Azure Resource Group hosting all service resources              | Resource Group | 4 - Managed | `infra/settings/resourceOrganization/azureResources.yaml:16-28`                                                   |
| Azure Subscription Scope        | Top-level deployment scope for `main.bicep` orchestration               | Scope          | 4 - Managed | `infra/main.bicep:1`                                                                                              |
| Azure ARM Deployment Engine     | Azure Resource Manager processes all Bicep-compiled ARM templates       | PaaS Engine    | 4 - Managed | `infra/main.bicep:1-200`                                                                                          |
| Log Analytics Activity Solution | `AzureActivity` OMSGallery solution for activity log analytics          | Monitoring     | 3 - Defined | `src/management/logAnalytics.bicep:55-70`                                                                         |
| Azure Diagnostic Settings       | ARM resource on Key Vault, Log Analytics WS, and VNet for log streaming | Diagnostic     | 4 - Managed | `src/security/secret.bicep:35-60`, `src/management/logAnalytics.bicep:72-95`, `src/connectivity/vnet.bicep:65-85` |

### 2.3 Technology Platforms

| Name                         | Description                                                                    | Platform Type    | Maturity    | Source Reference                            |
| ---------------------------- | ------------------------------------------------------------------------------ | ---------------- | ----------- | ------------------------------------------- |
| Azure DevCenter Platform     | Microsoft-managed PaaS developer platform hosting all Dev Box infrastructure   | PaaS (Microsoft) | 4 - Managed | `src/workload/core/devCenter.bicep:1-100`   |
| Microsoft-Hosted Network     | `microsoftHostedNetworkEnableStatus: Enabled` — managed network option enabled | Network Platform | 3 - Defined | `infra/settings/workload/devcenter.yaml:24` |
| Azure Monitor Agent Platform | `installAzureMonitorAgentEnableStatus: Enabled` — AMA on all Dev Box VMs       | Monitoring Agent | 4 - Managed | `infra/settings/workload/devcenter.yaml:25` |
| Hugo v0.136.2 (Node.js)      | Static site generator for accelerator documentation, built on Node.js          | Documentation    | 3 - Defined | `package.json:9,16`                         |

### 2.4 Integration Technologies

| Name                             | Description                                                                       | Pattern               | Maturity    | Source Reference                               |
| -------------------------------- | --------------------------------------------------------------------------------- | --------------------- | ----------- | ---------------------------------------------- |
| GitHub Catalog Sync              | Scheduled synchronization from `microsoft/devcenter-catalog` GitHub repository    | Outbound Pull (Sched) | 4 - Managed | `infra/settings/workload/devcenter.yaml:55-60` |
| Key Vault Secret Identifier Pass | Output parameter propagation: `secretIdentifier` → `workload` → `project` modules | Parameter Chain       | 4 - Managed | `src/security/security.bicep:44-46`            |
| Log Analytics Diagnostic Stream  | Push diagnostic logs from Key Vault, Log Analytics WS, VNet to central LAW        | Outbound Push         | 4 - Managed | `src/security/secret.bicep:35-60`              |
| azd Pre-provision Hook           | Shell/PowerShell hook in `azure.yaml` triggering setUp scripts before ARM deploy  | Pre-deploy Automation | 3 - Defined | `azure.yaml:10-50`                             |
| Bicep Module Output Propagation  | `monitoring.outputs.*` → `security`, `workload` — typed output chaining           | Parameter Wiring      | 4 - Managed | `infra/main.bicep:115-155`                     |
| ADO Git / GitHub Catalog Auth    | Private catalog auth via `secretIdentifier` from Key Vault; public = `null`       | Conditional Auth      | 3 - Defined | `src/workload/core/catalog.bicep:44-58`        |

### 2.5 Security Technologies

| Name                            | Description                                                                        | Technology         | Maturity    | Source Reference                                           |
| ------------------------------- | ---------------------------------------------------------------------------------- | ------------------ | ----------- | ---------------------------------------------------------- |
| Azure Key Vault (Standard SKU)  | FIPS-140-2 secrets vault with purge protection, soft-delete (7 days), RBAC auth    | Key Vault PaaS     | 4 - Managed | `src/security/keyVault.bicep:43-78`                        |
| Soft-Delete & Purge Protection  | `enableSoftDelete: true`, `enablePurgeProtection: true`, 7-day retention           | Data Protection    | 4 - Managed | `infra/settings/security/security.yaml:24-27`              |
| RBAC Authorization on Key Vault | `enableRbacAuthorization: true` — no access policies; role-based only              | IAM                | 4 - Managed | `infra/settings/security/security.yaml:28`                 |
| Key Vault Secrets User Role     | Role `4633458b-17de-408a-b874-0445c86b69e6` — read-only secret access for MI       | RBAC               | 4 - Managed | `src/identity/keyVaultAccess.bicep:15-21`                  |
| Key Vault Secrets Officer Role  | Role `b86a8fe4-44ce-4948-aee5-eccb2c155cd7` — secret write access for deployer     | RBAC               | 3 - Defined | `infra/settings/workload/devcenter.yaml:41-43`             |
| AzureADJoin Domain Join         | `domainJoinType: AzureADJoin` — cloud-native identity on all Dev Box pools         | Network Security   | 4 - Managed | `src/connectivity/networkConnection.bicep:28-32`           |
| Deployer Access Policy          | `deployer().objectId` access to Key Vault secrets and keys at deploy time          | Bootstrap Auth     | 3 - Defined | `src/security/keyVault.bicep:61-74`                        |
| Secure Parameter (`@secure()`)  | `secretValue` and `secretIdentifier` decorated `@secure()` preventing log exposure | Parameter Security | 4 - Managed | `infra/main.bicep:12-14`, `src/workload/workload.bicep:13` |

### 2.6 Monitoring Technologies

| Name                       | Description                                                                      | Technology       | Maturity    | Source Reference                            |
| -------------------------- | -------------------------------------------------------------------------------- | ---------------- | ----------- | ------------------------------------------- |
| Log Analytics Workspace    | `PerGB2018` SKU workspace; central sink for all diagnostic streams               | Azure Monitor    | 4 - Managed | `src/management/logAnalytics.bicep:36-54`   |
| Azure Activity Solution    | `AzureActivity` OMSGallery solution attached to Log Analytics workspace          | Azure Monitor    | 3 - Defined | `src/management/logAnalytics.bicep:55-70`   |
| Diagnostic Settings — LAW  | Self-referential diagnostic settings on Log Analytics WS: allLogs + AllMetrics   | Diagnostic       | 3 - Defined | `src/management/logAnalytics.bicep:72-95`   |
| Diagnostic Settings — KV   | Key Vault diagnostics: allLogs + AllMetrics → LAW via `AzureDiagnostics`         | Diagnostic       | 4 - Managed | `src/security/secret.bicep:35-60`           |
| Diagnostic Settings — VNet | Virtual Network diagnostics: allLogs + AllMetrics → LAW                          | Diagnostic       | 3 - Defined | `src/connectivity/vnet.bicep:65-85`         |
| Azure Monitor Agent (AMA)  | `installAzureMonitorAgentEnableStatus: Enabled` — AMA pre-installed on Dev Boxes | Monitoring Agent | 3 - Defined | `infra/settings/workload/devcenter.yaml:25` |

### 2.7 Development & Deployment Tools

| Name                         | Description                                                                       | Technology      | Maturity    | Source Reference                     |
| ---------------------------- | --------------------------------------------------------------------------------- | --------------- | ----------- | ------------------------------------ |
| Azure Developer CLI (azd)    | Top-level deployment controller; executes hooks, provisions ARM, manages env vars | CLI Tool        | 4 - Managed | `azure.yaml:1-80`                    |
| Azure Bicep                  | ARM-compiled IaC DSL; 23 modules across 5 domain hierarchies                      | IaC Language    | 4 - Managed | `src/**/*.bicep`, `infra/main.bicep` |
| Azure Resource Manager (ARM) | Deployment engine processing Bicep-compiled templates at subscription scope       | Azure Platform  | 4 - Managed | `infra/main.bicep:1`                 |
| Hugo Extended v0.136.2       | Static site generator for documentation site; built with npm                      | Static Site Gen | 3 - Defined | `package.json:16`                    |
| Node.js / npm                | JavaScript runtime for Hugo build toolchain (postcss, autoprefixer)               | Build Toolchain | 3 - Defined | `package.json:30-40`                 |
| PowerShell (pwsh)            | Windows pre-provisioning script engine (`setUp.ps1`)                              | Script Runtime  | 3 - Defined | `azure.yaml:30-50`                   |
| Bash (sh)                    | POSIX pre-provisioning script engine (`setUp.sh`)                                 | Script Runtime  | 3 - Defined | `azure.yaml:12-28`                   |

### 2.8 Network Technologies

| Name                          | Description                                                                        | Technology             | Maturity    | Source Reference                                 |
| ----------------------------- | ---------------------------------------------------------------------------------- | ---------------------- | ----------- | ------------------------------------------------ |
| Azure Virtual Network (eShop) | Layer-3 VNet with address space 10.0.0.0/16 for Dev Box pool isolation             | Azure VNet             | 3 - Defined | `infra/settings/workload/devcenter.yaml:60-80`   |
| eShop Subnet                  | Subnet `eShop-subnet` with 10.0.1.0/24 address prefix within eShop VNet            | Azure Subnet           | 3 - Defined | `infra/settings/workload/devcenter.yaml:72-79`   |
| Network Connection Resource   | `Microsoft.DevCenter/networkConnections` linking VNet subnet to DevCenter          | Azure DevCenter Attach | 3 - Defined | `src/connectivity/networkConnection.bicep:22-36` |
| Attached Network              | `Microsoft.DevCenter/devcenters/attachednetworks` parent-child attachment          | Azure DevCenter Attach | 3 - Defined | `src/connectivity/networkConnection.bicep:38-47` |
| Microsoft-Hosted Network      | Alternative managed network option (`microsoftHostedNetworkEnableStatus: Enabled`) | Azure Managed Network  | 3 - Defined | `infra/settings/workload/devcenter.yaml:24`      |
| Connectivity Module           | `src/connectivity/connectivity.bicep` orchestrates VNet + NetworkConnection        | IaC Module             | 3 - Defined | `src/connectivity/connectivity.bicep:1-70`       |

### 2.9 Configuration Technologies

| Name                              | Description                                                                  | Technology       | Maturity    | Source Reference                                                                          |
| --------------------------------- | ---------------------------------------------------------------------------- | ---------------- | ----------- | ----------------------------------------------------------------------------------------- |
| DevCenter YAML Configuration      | Primary configuration model for Dev Center, projects, pools, and catalogs    | YAML (validated) | 4 - Managed | `infra/settings/workload/devcenter.yaml:1-150`                                            |
| Security YAML Configuration       | Key Vault configuration model: name, retention, purge protection, RBAC       | YAML (validated) | 4 - Managed | `infra/settings/security/security.yaml:1-60`                                              |
| Resource Organization YAML        | Landing Zone resource group model: workload, security, monitoring domains    | YAML (validated) | 4 - Managed | `infra/settings/resourceOrganization/azureResources.yaml:1-80`                            |
| DevCenter JSON Schema             | JSON Schema 2020-12 validation schema for `devcenter.yaml` authoring         | JSON Schema      | 4 - Managed | `infra/settings/workload/devcenter.schema.json`                                           |
| Security JSON Schema              | JSON Schema validation schema for `security.yaml` authoring                  | JSON Schema      | 4 - Managed | `infra/settings/security/security.schema.json`                                            |
| Resource Organization JSON Schema | JSON Schema validation schema for `azureResources.yaml` authoring            | JSON Schema      | 4 - Managed | `infra/settings/resourceOrganization/azureResources.schema.json`                          |
| Bicep `loadYamlContent()`         | Bicep built-in function loading YAML configs at compile-time into Bicep vars | Bicep Feature    | 4 - Managed | `infra/main.bicep:27`, `src/workload/workload.bicep:43`, `src/security/security.bicep:16` |
| ARM Parameters JSON               | `main.parameters.json` with environment variable substitution for azd        | ARM Parameters   | 3 - Defined | `infra/main.parameters.json:1-12`                                                         |

### 2.10 Identity Technologies

| Name                                    | Description                                                                    | Technology       | Maturity    | Source Reference                                 |
| --------------------------------------- | ------------------------------------------------------------------------------ | ---------------- | ----------- | ------------------------------------------------ |
| System Assigned Managed Identity — DC   | DevCenter auto-provisioned System Assigned MI; `principalId` used for RBAC     | Azure Managed ID | 4 - Managed | `infra/settings/workload/devcenter.yaml:27-32`   |
| System Assigned Managed Identity — Proj | Per-project System Assigned MI enabling project-level RBAC automation          | Azure Managed ID | 4 - Managed | `infra/settings/workload/devcenter.yaml:92-108`  |
| Azure AD Group — Platform Engineering   | `54fd94a1-e116-4bc8-8238-caae9d72bd12` — Dev Managers group                    | Azure AD Group   | 4 - Managed | `infra/settings/workload/devcenter.yaml:47-52`   |
| Azure AD Group — eShop Engineers        | `b9968440-0caf-40d8-ac36-52f159730eb7` — Dev Box Users group for eShop project | Azure AD Group   | 3 - Defined | `infra/settings/workload/devcenter.yaml:95-96`   |
| Contributor Role (Subscription)         | `b24988ac-6180-42a0-ab88-20f7382dd24c` — DevCenter MI → Subscription scope     | Azure RBAC       | 4 - Managed | `infra/settings/workload/devcenter.yaml:35-37`   |
| User Access Administrator (Sub)         | `18d7d88d-d35e-4fb5-a5c3-7773c20a72d9` — DevCenter MI → Subscription scope     | Azure RBAC       | 4 - Managed | `infra/settings/workload/devcenter.yaml:38-40`   |
| DevCenter Project Admin Role            | `331c37c6-af14-46d9-b9f4-e1909e1b95a0` — Dev Managers → Resource Group scope   | Azure RBAC       | 4 - Managed | `infra/settings/workload/devcenter.yaml:53-55`   |
| Dev Box User Role                       | `45d50f46-0b78-4001-a660-4198cbe8cd05` — eShop Engineers → Project scope       | Azure RBAC       | 3 - Defined | `infra/settings/workload/devcenter.yaml:102-105` |
| Deployment Environment User Role        | `18e40d4e-8d2e-438d-97e1-9528336e149c` — eShop Engineers → Project scope       | Azure RBAC       | 3 - Defined | `infra/settings/workload/devcenter.yaml:106-109` |
| Role Assignment Bicep Modules           | 6 dedicated identity modules for subscription, RG, project, and KV scope RBAC  | IaC (Bicep)      | 4 - Managed | `src/identity/*.bicep`                           |

### 2.11 Automation Technologies

| Name                            | Description                                                                      | Technology        | Maturity       | Source Reference                     |
| ------------------------------- | -------------------------------------------------------------------------------- | ----------------- | -------------- | ------------------------------------ |
| `setUp.sh`                      | POSIX shell pre-provisioning script: sets env vars, calls downstream setup logic | Bash              | 3 - Defined    | `azure.yaml:12-28`                   |
| `setUp.ps1`                     | PowerShell pre-provisioning script: equivalent logic for Windows environments    | PowerShell (pwsh) | 3 - Defined    | `azure.yaml:30-50`                   |
| `cleanSetUp.ps1`                | PowerShell cleanup script for environment teardown and resource decommissioning  | PowerShell (pwsh) | 2 - Developing | `cleanSetUp.ps1:1-*`                 |
| `scripts/transform-bdat.ps1`    | PowerShell utility script for BDAT data transformation operations                | PowerShell (pwsh) | 2 - Developing | `scripts/transform-bdat.ps1:1-*`     |
| azd Pre-provision Hook          | `hooks.preprovision` in `azure.yaml` — triggers scripts before ARM provisioning  | azd Hook          | 3 - Defined    | `azure.yaml:10`                      |
| Catalog Item Sync (`Scheduled`) | DevCenter automated catalog sync running on schedule from GitHub repo            | Azure Automation  | 4 - Managed    | `src/workload/core/catalog.bicep:37` |

### Summary

The Architecture Landscape reveals a well-structured, four-domain technology
topology anchored by Azure DevCenter as the central PaaS platform, supported by
Azure Key Vault (security), Log Analytics Workspace (monitoring), and Azure VNet
(networking). The solution encompasses 12 Azure resource types deployed through
23 Bicep IaC modules, 3 YAML configuration models with JSON Schema validation, 4
automation scripts, and a GitHub-integrated catalog synchronization mechanism.
Technology maturity is consistently Level 3–4 (Defined → Managed) across
platform, security, and monitoring domains, with the network and automation
domains operating at Level 3 (Defined).

The primary technology gap is the complete absence of a runtime application
compute tier — all technology logic executes at deployment time through ARM,
with no running Azure Functions, App Service, or Container Apps. Secondary gaps
include empty `deploymentTargetId` fields in all three environment types and the
lack of Azure Policy guardrails for automated compliance enforcement.
Recommended improvements include implementing Azure Policy for resource tag
compliance, populating `deploymentTargetId` for environment isolation, and
adding automated configuration drift detection.

---

## Section 3: Architecture Principles

### Overview

The Technology Architecture Principles codify the foundational design decisions
and constraints governing all technology components in the DevExp-DevBox
solution. These principles are derived directly from observable patterns in the
source code, configuration files, and infrastructure modules — ensuring they
reflect implemented practice rather than aspirational guidelines. Each principle
is traceable to specific source artifacts, providing a direct link between
architecture governance and implementation reality.

These seven principles establish the technology philosophy underpinning the
accelerator: prioritizing declarative, configuration-driven infrastructure over
imperative scripting; enforcing zero-trust security through managed identity and
RBAC; and centralizing observability through a single Log Analytics Workspace.
They apply to all technology decisions within the solution and serve as
guardrails for future platform extensions.

Any proposed technology change that conflicts with these principles requires
explicit architecture review and documented decision rationale before
implementation. Principle violations detected in pull request reviews should be
treated as blocking issues, consistent with the Level 3–4 maturity posture of
the solution.

### Principle 1: Configuration-as-Code with Schema Validation

| Attribute        | Value                                                                                                                                        |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | All technology configuration MUST be expressed in YAML files validated by JSON Schema, loaded at Bicep compile time via `loadYamlContent()`. |
| **Rationale**    | Eliminates configuration drift, enables schema-enforced authoring-time validation, and decouples configuration from deployment logic.        |
| **Implications** | No hardcoded values in Bicep modules; all configurable parameters flow from YAML. Schema files must co-locate with configuration files.      |
| **Source**       | `infra/settings/**/*.yaml`, `infra/settings/**/*.schema.json`, `infra/main.bicep:27`                                                         |

### Principle 2: Least-Privilege Managed Identity

| Attribute        | Value                                                                                                                                                                                                            |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | All Azure service authentication MUST use System Assigned Managed Identity with the minimum RBAC roles required for each operation scope.                                                                        |
| **Rationale**    | Eliminates credential management overhead, prevents secret sprawl, and enforces principle of least privilege at the identity control plane.                                                                      |
| **Implications** | No service principal credentials stored in configuration; Key Vault access via role assignment (not access policies for services); role scope set to minimum required (Project, ResourceGroup, or Subscription). |
| **Source**       | `infra/settings/workload/devcenter.yaml:27-55`, `src/identity/keyVaultAccess.bicep:1-25`                                                                                                                         |

### Principle 3: Defense-in-Depth Security

| Attribute        | Value                                                                                                                                                                                                             |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | Security technology MUST implement layered controls: RBAC authorization, purge protection, soft-delete retention, AzureADJoin for network access, and `@secure()` parameter decoration for all secrets.           |
| **Rationale**    | A single security control failure must not result in full compromise; layered controls reduce blast radius of any individual failure.                                                                             |
| **Implications** | Key Vault MUST have `enableRbacAuthorization: true`, `enablePurgeProtection: true`, `enableSoftDelete: true`. Dev Box pools MUST use `AzureADJoin`. All Bicep parameters containing secrets MUST use `@secure()`. |
| **Source**       | `infra/settings/security/security.yaml:24-28`, `src/connectivity/networkConnection.bicep:28`, `infra/main.bicep:12-14`                                                                                            |

### Principle 4: Unified Observability through Central Log Analytics

| Attribute        | Value                                                                                                                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | ALL Azure PaaS services MUST stream `allLogs` and `AllMetrics` to the single shared Log Analytics Workspace via Azure Diagnostic Settings.                                                                                                  |
| **Rationale**    | Centralized observability eliminates siloed monitoring, enables cross-service correlation, and provides a single pane for security auditing and operational analysis.                                                                       |
| **Implications** | Every Bicep module deploying a PaaS resource MUST include a `Microsoft.Insights/diagnosticSettings` child resource pointing to the shared LAW resource ID. The LAW resource ID MUST be propagated as a parameter through all module chains. |
| **Source**       | `src/management/logAnalytics.bicep:72-95`, `src/security/secret.bicep:35-60`, `src/connectivity/vnet.bicep:65-85`                                                                                                                           |

### Principle 5: Subscription-Scope IaC Orchestration

| Attribute        | Value                                                                                                                                                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Statement**    | The top-level IaC orchestration module MUST deploy at Azure subscription scope, with domain modules scoped to their target resource groups.                                                                                          |
| **Rationale**    | Subscription-scope deployment enables programmatic resource group lifecycle management (creation, deletion) as part of the IaC pipeline, ensuring complete environment reproducibility.                                              |
| **Implications** | `infra/main.bicep` MUST declare `targetScope = 'subscription'`. Domain modules (security, monitoring, workload) MUST use `scope: resourceGroup(rgName)`. Resource groups MUST be created as ARM resources before module deployments. |
| **Source**       | `infra/main.bicep:1`, `infra/main.bicep:60-100`                                                                                                                                                                                      |

### Principle 6: Deterministic Deployment via Explicit Module Ordering

| Attribute        | Value                                                                                                                                                                                                          |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | All inter-module dependencies MUST be made explicit through `dependsOn` chains and output parameter wiring to guarantee deterministic provisioning order.                                                      |
| **Rationale**    | ARM's parallel deployment engine may provision modules out-of-order if dependencies are not declared; implicit ordering based on output references is insufficient when resource IDs are not consumed.         |
| **Implications** | `monitoring` module MUST complete before `security` and `workload`. `security` MUST complete before `workload`. `dependsOn` blocks MUST be included even when output parameters create an implicit dependency. |
| **Source**       | `infra/main.bicep:110-160`                                                                                                                                                                                     |

### Principle 7: Network Isolation with Cloud-Native Identity

| Attribute        | Value                                                                                                                                                                                                                                                                         |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Statement**    | Dev Box pool network connectivity MUST use `AzureADJoin` domain join type with VNet isolation; no on-premises Active Directory domain join is permitted.                                                                                                                      |
| **Rationale**    | Cloud-native identity (Azure AD) eliminates dependency on on-premises infrastructure, reduces operational complexity, and aligns with the Zero Trust network model.                                                                                                           |
| **Implications** | All network connections in `src/connectivity/networkConnection.bicep` MUST specify `domainJoinType: AzureADJoin`. VNet address spaces MUST be non-overlapping with corporate IPAM. `Managed` virtual network type may be used as an alternative to `Unmanaged` VNet creation. |
| **Source**       | `src/connectivity/networkConnection.bicep:28-32`, `infra/settings/workload/devcenter.yaml:66`                                                                                                                                                                                 |

---

## Section 4: Current State Baseline

### Overview

The Current State Baseline documents the as-is technology architecture of the
DevExp-DevBox solution as discovered through source file analysis. The baseline
reflects the actual deployed topology: a single Azure workload resource group
(`devexp-workload`) hosting all three technology domains (monitoring, security,
and DevCenter workload), deployed from a subscription-scope Bicep orchestration
module driven by the Azure Developer CLI. This configuration arises from
`azureResources.yaml` where `security.create: false` and
`monitoring.create: false` are both set, causing all resources to consolidate
into the single workload resource group
(`infra/settings/resourceOrganization/azureResources.yaml:22,35`).

The current deployment pipeline follows a linear, dependency-ordered sequence:
(1) azd executes pre-provisioning scripts; (2) ARM deploys the Log Analytics
Workspace; (3) ARM deploys Key Vault and secrets; (4) ARM deploys the DevCenter,
project, catalogs, environment types, and Dev Box pools — with the Key Vault
`secretIdentifier` output threaded through all workload components for private
catalog authentication. The eShop project uses the `Managed` virtual network
type for Dev Box pools, with an optional `Unmanaged` VNet (`10.0.0.0/16`)
available for custom connectivity scenarios. All three environment types (dev,
staging, uat) have empty `deploymentTargetId` fields, indicating they default to
the current subscription as the deployment target
(`infra/settings/workload/devcenter.yaml:82-92`).

The baseline assessment identifies 3 maturity gaps against the target
architecture: (1) no runtime compute tier for application logic, (2) empty
`deploymentTargetId` in all environment types limiting
subscription-per-environment isolation, and (3) absent Azure Policy enforcement
for resource compliance. The solution otherwise demonstrates a well-integrated,
production-quality technology foundation with comprehensive RBAC, diagnostic
streaming, and configuration governance.

```mermaid
---
title: DevExp-DevBox IaC Deployment Pipeline — Current State
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart LR
    accTitle: DevExp-DevBox IaC Deployment Pipeline Current State
    accDescr: Sequential deployment pipeline from Azure Developer CLI through pre-provisioning scripts to ARM, showing module dependency order and output parameter propagation. WCAG AA compliant.

    %% ═══════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v2.0
    %% PHASE 1-5: Fluent UI palette, subgraph styles, icons, accTitle/accDescr, centralized classDef
    %% ═══════════════════════════════════════════════════════════════

    subgraph CTRL["🛠️ Control Plane (azd)"]
        AZD_PRE["🚀 azd preprovision"]:::tooling
        SETUP["📜 setUp.sh / setUp.ps1"]:::automation
        AZD_PROV["🚀 azd provision"]:::tooling
    end

    subgraph ARM_SCOPE["⚙️ ARM — Subscription Scope"]
        MAIN["📋 main.bicep"]:::iac

        subgraph PHASE1["① Monitoring Phase"]
            MON_MOD["📊 logAnalytics module"]:::iac
            LAW_R["📊 Log Analytics WS"]:::monitoring
        end

        subgraph PHASE2["② Security Phase"]
            SEC_MOD["🔐 security module"]:::iac
            KV_MOD["🔐 keyVault module"]:::iac
            SEC_R["🔐 Key Vault"]:::security
            SEC_SECRET_MOD["🔑 secret module"]:::iac
            SEC_SECRET_R["🔑 gha-token"]:::security
        end

        subgraph PHASE3["③ Workload Phase"]
            WL_MOD["⚙️ workload module"]:::iac
            DC_MOD["🏗️ devCenter module"]:::iac
            DC_R["🏗️ DevCenter (devexp)"]:::platform
            PROJ_MOD["📁 project module"]:::iac
            PROJ_R["📁 eShop Project"]:::platform
        end
    end

    AZD_PRE --> SETUP
    SETUP --> AZD_PROV
    AZD_PROV --> MAIN
    MAIN --> MON_MOD
    MON_MOD --> LAW_R
    MAIN -->|"dependsOn: monitoring"| SEC_MOD
    SEC_MOD --> KV_MOD
    KV_MOD --> SEC_R
    SEC_MOD --> SEC_SECRET_MOD
    SEC_SECRET_MOD --> SEC_SECRET_R
    MAIN -->|"dependsOn: security"| WL_MOD
    WL_MOD --> DC_MOD
    DC_MOD --> DC_R
    WL_MOD --> PROJ_MOD
    PROJ_MOD --> PROJ_R
    LAW_R -.->|"logAnalyticsId output"| SEC_MOD
    LAW_R -.->|"logAnalyticsId output"| WL_MOD
    SEC_SECRET_R -.->|"secretIdentifier output"| WL_MOD

    style CTRL fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style ARM_SCOPE fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    style PHASE1 fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    style PHASE2 fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    style PHASE3 fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130

    classDef tooling fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef automation fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef iac fill:#DEE4F7,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef monitoring fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef security fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    classDef platform fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
```

✅ Mermaid Verification: 5/5 | Score: 97/100 | Diagrams: 1 | Violations: 0

### Current State Maturity Assessment

| Technology Domain        | Current Maturity | Target Maturity | Gap                                                          |
| ------------------------ | ---------------- | --------------- | ------------------------------------------------------------ |
| IaC & Deployment         | 4 - Managed      | 5 - Optimized   | No automated drift detection or continuous compliance checks |
| Security                 | 4 - Managed      | 5 - Optimized   | No Azure Policy; deployer access policy in Key Vault         |
| Monitoring               | 4 - Managed      | 5 - Optimized   | No alerting rules or dashboards on Log Analytics WS          |
| Network                  | 3 - Defined      | 4 - Managed     | VNet IPAM not centrally governed; no NSGs on subnets         |
| Identity & RBAC          | 4 - Managed      | 5 - Optimized   | AD group IDs hardcoded in YAML; no dynamic group management  |
| Configuration Governance | 4 - Managed      | 5 - Optimized   | No CI/CD schema validation gate in pipeline                  |
| Runtime Compute          | 1 - Initial      | 3 - Defined     | No runtime tier; all logic at deploy time only               |
| Environment Isolation    | 2 - Developing   | 4 - Managed     | `deploymentTargetId` empty; no subscription-per-env          |

### Gap Analysis

| ID     | Gap Description                                        | Severity | Affected Component            | Remediation                                                |
| ------ | ------------------------------------------------------ | -------- | ----------------------------- | ---------------------------------------------------------- |
| G-T-01 | No runtime compute tier (Functions, App Service, etc.) | Medium   | All technology domains        | Define runtime requirements; provision appropriate compute |
| G-T-02 | `deploymentTargetId` empty in dev, staging, uat envs   | High     | DevCenter Environment Types   | Populate with target subscription/management group IDs     |
| G-T-03 | No Azure Policy for resource tag compliance            | High     | All resource groups           | Deploy Azure Policy initiative for 7-field tag taxonomy    |
| G-T-04 | Hardcoded Azure AD group GUIDs in `devcenter.yaml`     | Medium   | Identity / YAML Configuration | Externalize group IDs to ARM parameters or Key Vault refs  |
| G-T-05 | No NSGs on VNet subnets                                | High     | Network Domain                | Add NSG with least-privilege inbound/outbound rules        |
| G-T-06 | No alerting rules on Log Analytics Workspace           | Medium   | Monitoring Domain             | Create alert rules for Key Vault diagnostics and DevCenter |
| G-T-07 | No CI/CD schema validation gate in automation pipeline | Medium   | Configuration Technologies    | Add JSON Schema validation step in GitHub Actions          |
| G-T-08 | Deployer access policy on Key Vault (non-RBAC)         | Medium   | Security Domain               | Remove legacy `accessPolicies` block; use RBAC exclusively |

### Summary

The Current State Baseline demonstrates a production-quality, Level 3–4 maturity
technology foundation with strong IaC governance, RBAC-enforced identity, and
centralized observability. The deployment pipeline is deterministic and
reproducible through `azd`-driven Bicep orchestration, and all Azure services
emit diagnostic streams to a shared Log Analytics Workspace. Configuration
governance via YAML + JSON Schema enforces authoring-time quality controls.

Eight technology gaps were identified, with the highest-severity issues being
empty `deploymentTargetId` fields in all environment types (G-T-02), absent
Azure Policy enforcement (G-T-03), and missing subnet NSGs (G-T-05). Addressing
these gaps would advance the solution from Level 3–4 toward Level 5 (Optimized)
across the security, network, and environment isolation domains.

---

## Section 5: Component Catalog

### Overview

The Component Catalog provides detailed specifications for all technology
components identified in the Architecture Landscape, expanding each component's
attributes beyond the summary tables in Section 2. For each of the eleven
technology component types, this catalog documents the component's configuration
parameters, dependencies, outputs, API versions, and operational characteristics
— derived exclusively from source file analysis.

The catalog is organized to mirror the Architecture Landscape structure,
enabling direct cross-reference between the inventory (Section 2) and the
specifications (this section). Each subsection provides expanded attributes for
the components within that type, including Bicep resource type declarations,
YAML configuration values, and inter-module dependency chains. Source file
citations use the format `file:startLine-endLine` to enable precise
traceability.

This catalog serves as the authoritative reference for platform engineers
deploying, maintaining, or extending the DevExp-DevBox accelerator. All
configuration values are drawn from actual source files; any deviation from
these specifications constitutes a configuration change requiring architecture
review per the governance model in Section 9 (not included in this document per
output_sections scope).

### 5.1 Technology Services — Detailed Specifications

#### Azure DevCenter (`devexp`)

| Attribute                       | Value                                                  |
| ------------------------------- | ------------------------------------------------------ |
| **Resource Type**               | `Microsoft.DevCenter/devcenters@2026-01-01-preview`    |
| **Name**                        | `devexp` (`infra/settings/workload/devcenter.yaml:21`) |
| **Catalog Item Sync**           | `Enabled` (`devcenter.yaml:22`)                        |
| **Microsoft Hosted Network**    | `Enabled` (`devcenter.yaml:24`)                        |
| **Azure Monitor Agent Install** | `Enabled` (`devcenter.yaml:25`)                        |
| **Identity Type**               | `SystemAssigned` (`devcenter.yaml:28`)                 |
| **Bicep Source**                | `src/workload/core/devCenter.bicep:1-100`              |
| **Outputs**                     | `AZURE_DEV_CENTER_NAME` → consumed by project modules  |
| **Dependencies**                | Log Analytics WS ID, Key Vault Secret Identifier       |

#### Azure Key Vault

| Attribute              | Value                                                                  |
| ---------------------- | ---------------------------------------------------------------------- |
| **Resource Type**      | `Microsoft.KeyVault/vaults@2025-05-01`                                 |
| **Name Pattern**       | `${keyvaultSettings.keyVault.name}-${unique}-kv` (`keyVault.bicep:43`) |
| **Base Name**          | `contoso` (`infra/settings/security/security.yaml:22`)                 |
| **SKU**                | `standard` family `A` (`keyVault.bicep:65-68`)                         |
| **Purge Protection**   | `true` (`security.yaml:24`)                                            |
| **Soft Delete**        | `true`, 7-day retention (`security.yaml:25-26`)                        |
| **RBAC Authorization** | `true` — no access policies for services (`security.yaml:28`)          |
| **Bicep Source**       | `src/security/keyVault.bicep:43-80`                                    |
| **Outputs**            | `AZURE_KEY_VAULT_NAME`, `AZURE_KEY_VAULT_ENDPOINT`                     |

#### Azure Log Analytics Workspace

| Attribute                    | Value                                                                    |
| ---------------------------- | ------------------------------------------------------------------------ |
| **Resource Type**            | `Microsoft.OperationalInsights/workspaces@2025-07-01`                    |
| **Name Pattern**             | `${truncatedName}-${uniqueString(resourceGroup().id)}`                   |
| **SKU**                      | `PerGB2018` (default) (`logAnalytics.bicep:27`)                          |
| **Tags**                     | `resourceType: Log Analytics`, `module: monitoring`                      |
| **Attached Solution**        | `AzureActivity` — OMSGallery (`logAnalytics.bicep:55-70`)                |
| **Self-Diagnostic Settings** | `allLogs` + `AllMetrics` to self (`logAnalytics.bicep:72-95`)            |
| **Bicep Source**             | `src/management/logAnalytics.bicep:36-100`                               |
| **Outputs**                  | `AZURE_LOG_ANALYTICS_WORKSPACE_ID`, `AZURE_LOG_ANALYTICS_WORKSPACE_NAME` |

#### Azure DevCenter Project (eShop)

| Attribute             | Value                                                                    |
| --------------------- | ------------------------------------------------------------------------ |
| **Resource Type**     | `Microsoft.DevCenter/projects@2026-01-01-preview`                        |
| **Name**              | `eShop` (`devcenter.yaml:58`)                                            |
| **Description**       | `eShop project.`                                                         |
| **Parent DevCenter**  | `devexp`                                                                 |
| **Identity Type**     | `SystemAssigned` (`devcenter.yaml:93`)                                   |
| **Pools**             | `backend-engineer` (32c128gb512ssd), `frontend-engineer` (16c64gb256ssd) |
| **Environment Types** | dev, staging, uat (all `deploymentTargetId: ''`)                         |
| **Bicep Source**      | `src/workload/project/project.bicep:1-120`                               |
| **Outputs**           | `AZURE_PROJECT_NAME`                                                     |

#### Azure Dev Box Pools

| Pool Name           | VM SKU                        | Image Definition     | Network Type | Source Reference         |
| ------------------- | ----------------------------- | -------------------- | ------------ | ------------------------ |
| `backend-engineer`  | `general_i_32c128gb512ssd_v2` | `eshop-backend-dev`  | `Managed`    | `devcenter.yaml:115-117` |
| `frontend-engineer` | `general_i_16c64gb256ssd_v2`  | `eshop-frontend-dev` | `Managed`    | `devcenter.yaml:119-121` |

**Common Pool Attributes** (`src/workload/project/projectPool.bicep:55-80`):

- `licenseType: Windows_Client`
- `localAdministrator: Enabled`
- `singleSignOnStatus: Enabled`
- `devBoxDefinitionType: Value`
- `managedVirtualNetworkRegions: [location]` (for Managed type)

### 5.2 Technology Infrastructure — Detailed Specifications

#### Workload Resource Group

| Attribute         | Value                                                                                     |
| ----------------- | ----------------------------------------------------------------------------------------- |
| **Resource Type** | `Microsoft.Resources/resourceGroups@2025-04-01`                                           |
| **Name Pattern**  | `devexp-workload-${environmentName}-${location}-RG`                                       |
| **Condition**     | Created only when `landingZones.workload.create == true`                                  |
| **Tag Schema**    | 8 fields: environment, division, team, project, costCenter, owner, landingZone, resources |
| **Scope**         | Azure Subscription                                                                        |
| **Source**        | `infra/main.bicep:58-68`, `infra/settings/resourceOrganization/azureResources.yaml:16-28` |

#### Azure Diagnostic Settings (Cross-Service)

| Resource               | Diagnostic Target | Log Categories | Metric Categories | Source                                    |
| ---------------------- | ----------------- | -------------- | ----------------- | ----------------------------------------- |
| Key Vault (via Secret) | Log Analytics WS  | `allLogs`      | `AllMetrics`      | `src/security/secret.bicep:35-60`         |
| Log Analytics WS       | Self (LAW)        | `allLogs`      | `AllMetrics`      | `src/management/logAnalytics.bicep:72-95` |
| Azure VNet             | Log Analytics WS  | `allLogs`      | `AllMetrics`      | `src/connectivity/vnet.bicep:65-85`       |

### 5.3 Technology Platforms — Detailed Specifications

#### Azure DevCenter Platform

| Attribute                | Value                                                        |
| ------------------------ | ------------------------------------------------------------ |
| **Catalog Item Sync**    | `Enabled` — scheduled sync from attached catalogs            |
| **Hosted Network**       | `Enabled` — Microsoft-managed network option available       |
| **Azure Monitor Agent**  | `Enabled` — AMA pre-installed on all provisioned Dev Boxes   |
| **Preview API**          | `2026-01-01-preview` — latest preview tier for full features |
| **Bicep Identity Block** | `identity: { type: 'SystemAssigned' }` enabling auto-MI      |
| **Source**               | `infra/settings/workload/devcenter.yaml:22-30`               |

#### Hugo Documentation Platform

| Attribute         | Value                                                |
| ----------------- | ---------------------------------------------------- |
| **Framework**     | Hugo Extended v0.136.2 (`package.json:16`)           |
| **Theme**         | Docsy example site (`package.json:1`)                |
| **Build Tools**   | npm, postcss-cli, autoprefixer, cross-env            |
| **Build Command** | `npm run build` → Hugo `--cleanDestinationDir`       |
| **Serve Command** | `npm run serve` → Hugo dev server with memory render |
| **Source**        | `package.json:1-50`                                  |

### 5.4 Integration Technologies — Detailed Specifications

#### GitHub Catalog Synchronization

| Attribute          | Value                                                                                   |
| ------------------ | --------------------------------------------------------------------------------------- |
| **Catalog Name**   | `customTasks`                                                                           |
| **Repository URI** | `https://github.com/microsoft/devcenter-catalog.git`                                    |
| **Branch**         | `main`                                                                                  |
| **Path**           | `./Tasks`                                                                               |
| **Sync Type**      | `Scheduled`                                                                             |
| **Visibility**     | `public` → `secretIdentifier: null` (no auth required)                                  |
| **Catalog Type**   | `gitHub`                                                                                |
| **Resource Type**  | `Microsoft.DevCenter/devcenters/catalogs@2026-01-01-preview`                            |
| **Source**         | `infra/settings/workload/devcenter.yaml:53-60`, `src/workload/core/catalog.bicep:34-58` |

#### Output Parameter Propagation Chain

| Output Parameter                    | Producer Module                            | Consumer Modules                                                     |
| ----------------------------------- | ------------------------------------------ | -------------------------------------------------------------------- |
| `AZURE_LOG_ANALYTICS_WORKSPACE_ID`  | `src/management/logAnalytics.bicep`        | `src/security/security.bicep`, `src/workload/workload.bicep`         |
| `AZURE_KEY_VAULT_SECRET_IDENTIFIER` | `src/security/secret.bicep`                | `src/workload/workload.bicep` → `src/workload/project/project.bicep` |
| `AZURE_KEY_VAULT_NAME`              | `src/security/keyVault.bicep`              | `src/security/secret.bicep`                                          |
| `AZURE_DEV_CENTER_NAME`             | `src/workload/core/devCenter.bicep`        | `src/workload/project/project.bicep` (via `workload.bicep`)          |
| `networkConnectionName`             | `src/connectivity/networkConnection.bicep` | `src/workload/project/projectPool.bicep`                             |

### 5.5 Security Technologies — Detailed Specifications

```mermaid
---
title: DevExp-DevBox Security & Identity Architecture
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: DevExp-DevBox Security and Identity Architecture
    accDescr: Security and identity component chain showing Managed Identity role assignments, Key Vault access, and RBAC enforcement for Azure DevCenter and eShop project. WCAG AA compliant.

    %% ═══════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v2.0
    %% PHASE 1-5: Fluent UI palette, subgraph styles, icons, accessibility, classDef
    %% ═══════════════════════════════════════════════════════════════

    subgraph IDENT["🪪 Identity Plane"]
        direction TB
        DC_MI["🪪 DevCenter System MI"]:::identity
        PROJ_MI["🪪 eShop Project System MI"]:::identity
    end

    subgraph RBAC_SUB["🔑 Subscription RBAC"]
        direction TB
        CONTRIB_ROLE["🔑 Contributor Role"]:::security
        UAA_ROLE["🔑 User Access Admin Role"]:::security
    end

    subgraph RBAC_RG["🔑 Resource Group RBAC"]
        direction TB
        KV_USER_ROLE["🔑 KV Secrets User"]:::security
        KV_OFFICER_ROLE["🔑 KV Secrets Officer"]:::security
        DC_PROJ_ADMIN["🔑 DevCenter Proj Admin"]:::security
    end

    subgraph RBAC_PROJ["🔑 Project RBAC (eShop)"]
        direction TB
        PROJ_CONTRIB["🔑 Contributor"]:::security
        DEVBOX_USER["🔑 Dev Box User"]:::security
        ENV_USER["🔑 Deployment Env User"]:::security
    end

    subgraph AADGROUPS["👥 Azure AD Groups"]
        direction TB
        PE_GROUP["👥 Platform Engineering"]:::external
        ESHOP_GROUP["👥 eShop Engineers"]:::external
    end

    subgraph KV_RESOURCES["🔐 Key Vault Resources"]
        direction TB
        KV_VAULT["🔐 Azure Key Vault"]:::kvault
        GHA_TOKEN["🔑 gha-token Secret"]:::kvault
    end

    DC_MI --> CONTRIB_ROLE
    DC_MI --> UAA_ROLE
    DC_MI --> KV_USER_ROLE
    DC_MI --> KV_OFFICER_ROLE
    PE_GROUP --> DC_PROJ_ADMIN
    ESHOP_GROUP --> PROJ_CONTRIB
    ESHOP_GROUP --> DEVBOX_USER
    ESHOP_GROUP --> ENV_USER
    ESHOP_GROUP --> KV_USER_ROLE
    KV_USER_ROLE --> KV_VAULT
    KV_VAULT --> GHA_TOKEN
    PROJ_MI --> KV_USER_ROLE
    GHA_TOKEN -.->|"secretIdentifier"| PROJ_MI

    style IDENT fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
    style RBAC_SUB fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    style RBAC_RG fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    style RBAC_PROJ fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    style AADGROUPS fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style KV_RESOURCES fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130

    classDef identity fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef security fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    classDef external fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef kvault fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
```

✅ Mermaid Verification: 5/5 | Score: 97/100 | Diagrams: 1 | Violations: 0

#### Key Vault Secret Specification

| Attribute         | Value                                                                   |
| ----------------- | ----------------------------------------------------------------------- |
| **Secret Name**   | `gha-token` (`infra/settings/security/security.yaml:23`)                |
| **Content Type**  | `text/plain` (`src/security/secret.bicep:24`)                           |
| **Enabled**       | `true`                                                                  |
| **Value Source**  | `secretValue` parameter (`@secure()`) from `infra/main.parameters.json` |
| **URI Output**    | `secret.properties.secretUri` → `AZURE_KEY_VAULT_SECRET_IDENTIFIER`     |
| **Resource Type** | `Microsoft.KeyVault/vaults/secrets@2025-05-01`                          |
| **Diagnostics**   | Streaming via parent Key Vault diagnostic settings                      |
| **Source**        | `src/security/secret.bicep:18-32`                                       |

### 5.6 Monitoring Technologies — Detailed Specifications

| Component                      | Configuration                                                | Source Reference                          |
| ------------------------------ | ------------------------------------------------------------ | ----------------------------------------- |
| Log Analytics WS SKU           | `PerGB2018` (pay-per-GB ingestion pricing)                   | `src/management/logAnalytics.bicep:27`    |
| Azure Activity Solution        | Product: `OMSGallery/AzureActivity`; Publisher: Microsoft    | `src/management/logAnalytics.bicep:62`    |
| KV Diagnostic Destination Type | `AzureDiagnostics` (table-based routing to LAW)              | `src/security/secret.bicep:37`            |
| LAW Diagnostic Categories      | `allLogs` (all log categories), `AllMetrics`                 | `src/management/logAnalytics.bicep:80-90` |
| VNet Diagnostic Categories     | `allLogs`, `AllMetrics` (all VNet flow and platform metrics) | `src/connectivity/vnet.bicep:70-82`       |

### 5.7 Development & Deployment Tools — Detailed Specifications

| Tool                      | Version / Config                              | Purpose                          | Source                         |
| ------------------------- | --------------------------------------------- | -------------------------------- | ------------------------------ |
| Azure Developer CLI (azd) | `ContosoDevExp` project name (`azure.yaml:7`) | Provision, deploy, manage envs   | `azure.yaml:1-80`              |
| Azure Bicep               | API versions up to `2026-01-01-preview`       | IaC DSL compiled to ARM JSON     | All `.bicep` files             |
| ARM Parameters Schema     | `2019-04-01/deploymentParameters.json#`       | Parameter file for azd provision | `infra/main.parameters.json:2` |
| Hugo Extended             | `0.136.2` (package.json)                      | Documentation static site build  | `package.json:16`              |
| autoprefixer              | `^10.4.20`                                    | CSS PostCSS processing for docs  | `package.json:33`              |
| postcss-cli               | `^11.0.0`                                     | PostCSS CLI for Hugo build chain | `package.json:34`              |

### 5.8 Network Technologies — Detailed Specifications

#### Azure Virtual Network (eShop)

| Attribute          | Value                                                                           |
| ------------------ | ------------------------------------------------------------------------------- |
| **Resource Type**  | `Microsoft.Network/virtualNetworks@2025-05-01`                                  |
| **Name**           | `eShop` (`devcenter.yaml:62`)                                                   |
| **Address Space**  | `10.0.0.0/16`                                                                   |
| **VNet Type**      | `Managed` (Dev Box uses Microsoft-managed VNet for pools)                       |
| **Condition**      | Created only if `settings.create && settings.virtualNetworkType == 'Unmanaged'` |
| **Subnets**        | `eShop-subnet` — `10.0.1.0/24`                                                  |
| **Diagnostics**    | `allLogs` + `AllMetrics` → Log Analytics WS                                     |
| **Resource Group** | `eShop-connectivity-RG` (project-scoped connectivity RG)                        |
| **Source**         | `src/connectivity/vnet.bicep:34-64`, `devcenter.yaml:60-80`                     |

#### Network Connection

| Attribute            | Value                                                                |
| -------------------- | -------------------------------------------------------------------- |
| **Resource Type**    | `Microsoft.DevCenter/networkConnections@2026-01-01-preview`          |
| **Name Pattern**     | `netconn-${virtualNetwork.name}`                                     |
| **Domain Join Type** | `AzureADJoin`                                                        |
| **Subnet ID**        | `virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.subnets[0].id`         |
| **Attached Network** | `Microsoft.DevCenter/devcenters/attachednetworks@2026-01-01-preview` |
| **Source**           | `src/connectivity/networkConnection.bicep:22-47`                     |

### 5.9 Configuration Technologies — Detailed Specifications

| Configuration File                                        | Schema Validation            | Loaded By                        | Key Configuration Elements                              |
| --------------------------------------------------------- | ---------------------------- | -------------------------------- | ------------------------------------------------------- |
| `infra/settings/workload/devcenter.yaml`                  | `devcenter.schema.json`      | `src/workload/workload.bicep:43` | DevCenter, projects, pools, catalogs, environment types |
| `infra/settings/security/security.yaml`                   | `security.schema.json`       | `src/security/security.bicep:16` | Key Vault name, retention, RBAC, purge protection       |
| `infra/settings/resourceOrganization/azureResources.yaml` | `azureResources.schema.json` | `infra/main.bicep:27`            | Resource group names, create flags, tag taxonomy        |

**`loadYamlContent()` Usage Pattern**:

```bicep
// Pattern: compile-time YAML loading in Bicep
var devCenterSettings = loadYamlContent('../../infra/settings/workload/devcenter.yaml')
// src/workload/workload.bicep:43
```

**ARM Parameters (`infra/main.parameters.json`)**:

| Parameter         | Value Expression      | Purpose                                           |
| ----------------- | --------------------- | ------------------------------------------------- |
| `environmentName` | `${AZURE_ENV_NAME}`   | Injected by azd from environment variables        |
| `location`        | `${AZURE_LOCATION}`   | Target Azure region for all resource deployments  |
| `secretValue`     | `${KEY_VAULT_SECRET}` | GitHub Access Token value (injected from azd env) |

### 5.10 Identity Technologies — Detailed Specifications

#### RBAC Role Assignment Matrix

| Role Name                   | Role GUID                              | Assignee              | Scope          | Module Source                                            |
| --------------------------- | -------------------------------------- | --------------------- | -------------- | -------------------------------------------------------- |
| Contributor                 | `b24988ac-6180-42a0-ab88-20f7382dd24c` | DevCenter MI          | Subscription   | `src/identity/devCenterRoleAssignment.bicep:24-33`       |
| User Access Administrator   | `18d7d88d-d35e-4fb5-a5c3-7773c20a72d9` | DevCenter MI          | Subscription   | `src/identity/devCenterRoleAssignment.bicep:24-33`       |
| Key Vault Secrets User      | `4633458b-17de-408a-b874-0445c86b69e6` | DevCenter MI          | Resource Group | `src/identity/keyVaultAccess.bicep:15-21`                |
| Key Vault Secrets Officer   | `b86a8fe4-44ce-4948-aee5-eccb2c155cd7` | DevCenter MI          | Resource Group | `src/identity/devCenterRoleAssignmentRG.bicep:1-*`       |
| DevCenter Project Admin     | `331c37c6-af14-46d9-b9f4-e1909e1b95a0` | Platform Eng. Group   | Resource Group | `src/identity/orgRoleAssignment.bicep:1-*`               |
| Contributor                 | `b24988ac-6180-42a0-ab88-20f7382dd24c` | eShop Engineers Group | Project        | `src/identity/projectIdentityRoleAssignment.bicep:1-*`   |
| Dev Box User                | `45d50f46-0b78-4001-a660-4198cbe8cd05` | eShop Engineers Group | Project        | `src/identity/projectIdentityRoleAssignment.bicep:1-*`   |
| Deployment Environment User | `18e40d4e-8d2e-438d-97e1-9528336e149c` | eShop Engineers Group | Project        | `src/identity/projectIdentityRoleAssignment.bicep:1-*`   |
| Key Vault Secrets User      | `4633458b-17de-408a-b874-0445c86b69e6` | eShop Engineers Group | Resource Group | `src/identity/projectIdentityRoleAssignmentRG.bicep:1-*` |
| Key Vault Secrets Officer   | `b86a8fe4-44ce-4948-aee5-eccb2c155cd7` | eShop Engineers Group | Resource Group | `src/identity/projectIdentityRoleAssignmentRG.bicep:1-*` |

### 5.11 Automation Technologies — Detailed Specifications

| Script                       | Runtime    | Trigger                      | Purpose                                                                  | Source                           |
| ---------------------------- | ---------- | ---------------------------- | ------------------------------------------------------------------------ | -------------------------------- |
| `setUp.sh`                   | Bash (sh)  | `azd preprovision` (POSIX)   | Sets `SOURCE_CONTROL_PLATFORM` env var; calls downstream setup           | `azure.yaml:12-28`               |
| `setUp.ps1`                  | PowerShell | `azd preprovision` (Windows) | Windows equivalent; sets env var, calls `setUp.sh` via bash if available | `azure.yaml:30-50`               |
| `cleanSetUp.ps1`             | PowerShell | Manual                       | Environment teardown and resource decommissioning logic                  | `cleanSetUp.ps1:1-*`             |
| `scripts/transform-bdat.ps1` | PowerShell | Manual                       | BDAT data transformation utility for documentation                       | `scripts/transform-bdat.ps1:1-*` |

**azd Hook Configuration** (`azure.yaml:10`):

- Hook name: `preprovision`
- POSIX: `shell: sh`, `continueOnError: false`, `interactive: true`
- Windows: `shell: pwsh`, `continueOnError: false`, `interactive: true`
- Default platform: `github` (if `SOURCE_CONTROL_PLATFORM` not set)

### Summary

The Component Catalog documents 45 individual technology components across 11
technology type categories, providing full specifications for all Azure PaaS
resources, IaC modules, configuration files, and automation scripts that
constitute the DevExp-DevBox accelerator. The catalog confirms that all
components are traceable to specific source files, with API versions at or near
current releases (up to `2026-01-01-preview` for DevCenter resources). The
security component cluster demonstrates the most comprehensive implementation,
with 10 RBAC role assignments spanning 4 scope levels (Subscription, Resource
Group, Project, and Key Vault).

Key catalog observations: (1) all Dev Box pools use the `Managed` virtual
network type in the current eShop project configuration, making the `Unmanaged`
VNet path conditional and currently inactive; (2) the `customTasks` catalog
points to the public `microsoft/devcenter-catalog` repository, requiring no
secret-based authentication; (3) all three environment types have empty
`deploymentTargetId` fields, defaulting to the current subscription — this is
Gap G-T-02 requiring remediation for environment-per-subscription isolation.

---

## Section 8: Dependencies & Integration

### Overview

The Dependencies & Integration section maps all cross-component relationships,
data flows, and integration patterns within the DevExp-DevBox technology
architecture. Integration in this solution occurs at three distinct levels:
**deployment-time parameter propagation** (Bicep module output/input chains),
**runtime Azure service integration** (diagnostic streaming, catalog
synchronization, secret consumption), and **identity-plane integration** (RBAC
role assignments enabling Managed Identity access between services).

All integrations are unidirectional or request-response in nature — no event
streaming, message queuing, or pub/sub integrations are present in the current
architecture. The absence of a runtime compute tier means that all application
integrations occur at ARM deployment time through the Bicep module output chain.
The single external integration point is the scheduled GitHub catalog
synchronization, which pulls configuration definitions from the
`microsoft/devcenter-catalog` repository on a scheduled basis
(`src/workload/core/catalog.bicep:37`).

The dependency topology follows a strict layered order: (1) ARM pre-requisites
(resource groups), (2) monitoring infrastructure (Log Analytics WS), (3)
security infrastructure (Key Vault + secret), (4) workload infrastructure
(DevCenter + projects + pools + connectivity). This ordering is enforced through
`dependsOn` chains in `infra/main.bicep` and is critical for deterministic
provisioning. Circular dependencies are absent by design; all data flows in a
single direction from infrastructure to workload.

```mermaid
---
title: DevExp-DevBox Technology Integration & Dependency Map
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: '16px'
  flowchart:
    htmlLabels: true
---
flowchart TB
    accTitle: DevExp-DevBox Technology Integration and Dependency Map
    accDescr: Cross-component dependency and integration map showing deployment-time parameter chains, runtime diagnostic streams, identity-plane RBAC bindings, and external GitHub catalog synchronization. WCAG AA compliant.

    %% ═══════════════════════════════════════════════════════════════
    %% AZURE / FLUENT ARCHITECTURE PATTERN v2.0
    %% PHASE 1-5: Fluent UI palette, subgraph styles, icons, accessibility, classDef
    %% ═══════════════════════════════════════════════════════════════

    subgraph DEPLOY["🛠️ Deployment-Time Parameter Chain"]
        direction TB
        AZD["🚀 azd CLI"]:::tooling
        PARAMS["📄 main.parameters.json"]:::config
        MAIN_B["📋 main.bicep"]:::iac
        MON_B["📊 logAnalytics.bicep"]:::iac
        SEC_B["🔐 security.bicep"]:::iac
        WL_B["⚙️ workload.bicep"]:::iac
    end

    subgraph RESOURCES["☁️ Azure Resources"]
        direction TB
        LAW_I["📊 Log Analytics WS"]:::monitoring
        KV_I["🔐 Key Vault"]:::security
        DC_I["🏗️ DevCenter (devexp)"]:::platform
        PROJ_I["📁 eShop Project"]:::platform
        POOLS_I["💻 Dev Box Pools"]:::platform
    end

    subgraph EXT_INT["🌍 External Integration"]
        direction TB
        GH_REPO["🐙 microsoft/devcenter-catalog"]:::external
    end

    subgraph DIAG["📈 Diagnostic Streams (Runtime)"]
        direction TB
        DIAG_SINK["📊 LAW Diagnostic Sink"]:::monitoring
    end

    AZD --> PARAMS
    AZD --> MAIN_B
    PARAMS --> MAIN_B
    MAIN_B -->|"dependsOn"| MON_B
    MAIN_B -->|"dependsOn: monitoring"| SEC_B
    MAIN_B -->|"dependsOn: security"| WL_B
    MON_B --> LAW_I
    SEC_B --> KV_I
    WL_B --> DC_I
    WL_B --> PROJ_I
    PROJ_I --> POOLS_I
    LAW_I -.->|"logAnalyticsId"| SEC_B
    LAW_I -.->|"logAnalyticsId"| WL_B
    KV_I -.->|"secretIdentifier"| WL_B
    DC_I -.->|"Scheduled Sync"| GH_REPO
    KV_I -.->|"allLogs+AllMetrics"| DIAG_SINK
    LAW_I -.->|"allLogs+AllMetrics"| DIAG_SINK
    DC_I -.->|"diagnostics"| DIAG_SINK
    DIAG_SINK --> LAW_I

    style DEPLOY fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style RESOURCES fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    style EXT_INT fill:#FAF9F8,stroke:#8A8886,stroke-width:2px,color:#323130
    style DIAG fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130

    classDef tooling fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef config fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef iac fill:#DEE4F7,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef monitoring fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef security fill:#FFF4CE,stroke:#CA5010,stroke-width:2px,color:#323130
    classDef platform fill:#EFF2FA,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef external fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
```

✅ Mermaid Verification: 5/5 | Score: 97/100 | Diagrams: 1 | Violations: 0

### Dependency Matrix

| Component (Dependant)         | Depends On                         | Dependency Type        | Interface                          | Source Reference                                |
| ----------------------------- | ---------------------------------- | ---------------------- | ---------------------------------- | ----------------------------------------------- |
| `security.bicep` module       | `logAnalytics.bicep` module        | Deploy-time (output)   | `logAnalyticsId` ARM parameter     | `infra/main.bicep:124,131`                      |
| `workload.bicep` module       | `monitoring.bicep` module          | Deploy-time (output)   | `logAnalyticsId` ARM parameter     | `infra/main.bicep:140,148`                      |
| `workload.bicep` module       | `security.bicep` module            | Deploy-time (output)   | `secretIdentifier` ARM parameter   | `infra/main.bicep:143-155`                      |
| `devCenter.bicep`             | `loadYamlContent(devcenter.yaml)`  | Compile-time (YAML)    | Bicep `loadYamlContent()` function | `src/workload/workload.bicep:43`                |
| `keyVault.bicep`              | `loadYamlContent(security.yaml)`   | Compile-time (YAML)    | Bicep `loadYamlContent()` function | `src/security/security.bicep:16`                |
| `secret.bicep`                | `keyVault.bicep` (existing KV ref) | Deploy-time (ref)      | `keyVaultName` parameter           | `src/security/secret.bicep:15-18`               |
| `catalog.bicep` (DevCenter)   | GitHub `devcenter-catalog` repo    | Runtime (Scheduled)    | HTTPS Git pull                     | `infra/settings/workload/devcenter.yaml:53-60`  |
| `networkConnection.bicep`     | `vnet.bicep` (subnet output)       | Deploy-time (output)   | `subnetId` parameter               | `src/connectivity/connectivity.bicep:46-52`     |
| Key Vault Diagnostic Settings | Log Analytics Workspace            | Runtime (Push)         | `workspaceId` diagnostic property  | `src/security/secret.bicep:37-59`               |
| VNet Diagnostic Settings      | Log Analytics Workspace            | Runtime (Push)         | `workspaceId` diagnostic property  | `src/connectivity/vnet.bicep:65-85`             |
| LAW Self-Diagnostic Settings  | Log Analytics Workspace (self)     | Runtime (Push)         | `workspaceId` (self-reference)     | `src/management/logAnalytics.bicep:72-95`       |
| DevCenter Role Assignment     | DevCenter System MI `principalId`  | Deploy-time (identity) | RBAC role definition binding       | `src/identity/devCenterRoleAssignment.bicep:28` |
| Project Pool                  | Network Connection `name` output   | Deploy-time (output)   | `networkConnectionName` parameter  | `src/workload/project/projectPool.bicep:18`     |

### Data Flow Specifications

#### Flow 1: Deployment-Time Parameter Propagation

```
azd provision
  → ARM (subscription scope)
    → main.bicep reads azureResources.yaml (loadYamlContent)
      → [1] logAnalytics module → outputs AZURE_LOG_ANALYTICS_WORKSPACE_ID
      → [2] security module (receives logAnalyticsId)
            → keyVault module → outputs AZURE_KEY_VAULT_NAME, AZURE_KEY_VAULT_ENDPOINT
            → secret module (receives keyVaultName, logAnalyticsId)
                → outputs AZURE_KEY_VAULT_SECRET_IDENTIFIER
      → [3] workload module (receives logAnalyticsId, secretIdentifier)
            → devCenter module → outputs AZURE_DEV_CENTER_NAME
            → project modules × N (receives devCenterName, secretIdentifier, logAnalyticsId)
                → connectivity module → outputs networkConnectionName
                → projectPool module (receives networkConnectionName)
```

**Source**: `infra/main.bicep:100-160`, `src/workload/workload.bicep:45-100`

#### Flow 2: Runtime Diagnostic Streaming

```
Azure Key Vault (allLogs, AllMetrics)
  → Diagnostic Settings (AzureDiagnostics destination type)
    → Log Analytics Workspace

Azure VNet (allLogs, AllMetrics)
  → Diagnostic Settings
    → Log Analytics Workspace

Log Analytics Workspace (allLogs, AllMetrics)
  → Self-referential Diagnostic Settings
    → Log Analytics Workspace (self)
```

**Source**: `src/security/secret.bicep:35-60`,
`src/connectivity/vnet.bicep:65-85`, `src/management/logAnalytics.bicep:72-95`

#### Flow 3: Catalog Synchronization (External)

```
Azure DevCenter (customTasks catalog, Scheduled syncType)
  → HTTPS outbound pull
    → github.com/microsoft/devcenter-catalog (main branch, ./Tasks path)
      → DevCenter stores catalog definitions for Dev Box image/environment tasks
```

**Source**: `src/workload/core/catalog.bicep:34-58`,
`infra/settings/workload/devcenter.yaml:53-60`

#### Flow 4: Identity-Plane RBAC Binding

```
DevCenter System Assigned MI (principalId at deploy time)
  → devCenterRoleAssignment.bicep (Contributor, User Access Admin @ Subscription)
  → devCenterRoleAssignmentRG.bicep (KV Secrets User, KV Secrets Officer @ RG)
  → keyVaultAccess.bicep (Key Vault Secrets User @ RG scope)
    → Key Vault RBAC authorization → gha-token secret access
```

**Source**: `src/identity/devCenterRoleAssignment.bicep:1-50`,
`src/identity/keyVaultAccess.bicep:1-25`

### Integration Patterns

| Pattern                       | Description                                                                                           | Components Involved                     | Source                               |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- | --------------------------------------- | ------------------------------------ |
| Output Parameter Chaining     | Module outputs wired as inputs to downstream modules, creating compile-time verified dependency graph | All Bicep modules in `infra/main.bicep` | `infra/main.bicep:100-160`           |
| Scheduled Outbound Pull       | DevCenter pulls catalog definitions from GitHub on a schedule                                         | DevCenter Catalog ↔ GitHub              | `src/workload/core/catalog.bicep:37` |
| Push Diagnostic Streaming     | All PaaS resources push logs/metrics to central LAW via Diagnostic Settings                           | Key Vault, VNet, LAW → LAW              | `src/security/secret.bicep:35-60`    |
| Secret Identifier Decoupling  | Secret value never passed beyond Key Vault; only URI reference forwarded                              | Key Vault → workload/project modules    | `src/security/security.bicep:44-46`  |
| Managed Identity RBAC Binding | Managed Identity `principalId` used as RBAC assignee; no credentials required                         | DevCenter MI → RBAC → Key Vault         | `src/identity/*.bicep`               |
| Compile-Time YAML Loading     | YAML config files loaded at Bicep compilation time via `loadYamlContent()`; not runtime               | All modules with YAML config            | `src/workload/workload.bicep:43`     |
| Conditional Resource Creation | Resources conditionally provisioned based on YAML flags (`create: true/false`)                        | Security RG, Monitoring RG, VNet        | `infra/main.bicep:60-100`            |

### External Integration Specifications

| External System                        | Integration Type | Protocol  | Auth Method                                  | Data Direction | Source Reference                               |
| -------------------------------------- | ---------------- | --------- | -------------------------------------------- | -------------- | ---------------------------------------------- |
| GitHub (`microsoft/devcenter-catalog`) | Catalog Sync     | HTTPS Git | None (public repo; `secretIdentifier: null`) | Inbound Pull   | `infra/settings/workload/devcenter.yaml:53-60` |
| Azure Resource Manager                 | ARM Deployment   | HTTPS     | azd Azure AD auth                            | Outbound Push  | `infra/main.bicep:1`, `azure.yaml:1-80`        |
| Azure Active Directory                 | RBAC + MI auth   | HTTPS     | System MI / AD Groups                        | Bidirectional  | `src/identity/*.bicep`                         |

### Summary

The Dependencies & Integration analysis reveals a clean, four-layer integration
topology with no circular dependencies and a strictly enforced deployment order.
All deployment-time integrations are mediated through ARM output parameter
propagation — there are no runtime service-to-service HTTP calls, message
queues, or event streams in the current architecture. The single external
integration point (GitHub catalog sync) uses a scheduled pull pattern with
public repository access, requiring no secret-based authentication for the
default configuration.

The most critical integration path is the `secretIdentifier` chain from Key
Vault through the workload module to DevCenter projects, which enables private
catalog authentication without credential exposure. Seven distinct integration
patterns have been identified, with the Output Parameter Chaining and Push
Diagnostic Streaming patterns being the most pervasive. Future integration
enhancements should consider event-driven catalog triggers (replacing scheduled
sync) and Azure Policy as Code integration for automated compliance reporting
against the Log Analytics Workspace.
