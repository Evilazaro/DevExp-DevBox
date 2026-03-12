# Application Architecture - DevExp-DevBox

**Generated**: 2026-03-12T00:00:00Z **Target Layer**: Application **Quality
Level**: Comprehensive **Repository**: Evilazaro/DevExp-DevBox **Components
Found**: 29 **Average Confidence**: 0.93 **Maturity Level**: Level 2 — Managed

---

## Section 1: Executive Summary

### Overview

The DevExp-DevBox repository implements a Developer Experience Platform built on
Azure DevCenter using Infrastructure as Code (Bicep). The Application layer
encompasses 29 identified components distributed across all 11 TOGAF Application
Architecture component types. The platform provisions self-service developer
workstations (Dev Boxes) with managed networking, identity governance, secrets
management, and centralized monitoring. The architecture follows a modular Bicep
composition pattern where a subscription-scoped orchestrator
(`infra/main.bicep`) delegates to domain-specific modules organized into five
functional layers: Workload, Security, Connectivity, Identity, and Management.

Component analysis reveals strong architectural coverage with an average
confidence score of 0.93 across all classified components. The four primary
Application Services — DevCenter Core, Workload Orchestrator, Security
Orchestrator, and Connectivity Orchestrator — coordinate 11 modular Application
Components through well-defined Bicep module interfaces. Configuration is driven
by three YAML files validated against companion JSON Schemas, implementing a
Configuration-as-Code integration pattern. Identity and access management is
handled through six specialized RBAC modules supporting both SystemAssigned
managed identities and Azure AD group assignments at subscription, resource
group, and project scopes.

The platform demonstrates Level 2 (Managed) maturity: CI/CD hooks are present
via Azure Developer CLI (`azd`), structured setup scripts validate
prerequisites, and deployment targets are schema-validated. Gaps include the
absence of automated integration tests, formal SLO definitions, and distributed
tracing, which would be required for Level 3 (Defined) maturity.

---

## Section 2: Architecture Landscape

### Overview

This section catalogs all Application layer components identified through
pattern-based scanning of the repository root folder. Components are classified
into 11 TOGAF-aligned subsections. The DevExp-DevBox platform is an Azure
DevCenter-based Infrastructure as Code system composed of Bicep modules, YAML
configuration files, JSON validation schemas, and deployment automation scripts.
Source traceability is provided for every component with file path and
line-range references.

```mermaid
---
title: DevExp-DevBox System Context
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
    accTitle: DevExp-DevBox System Context Diagram
    accDescr: Shows the DevExp-DevBox platform boundary with external actors and systems including platform engineers, developers, Azure Resource Manager, GitHub repositories, and Azure AD

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

    PlatEng("👤 Platform Engineer") --> AZD("⚙️ Azure Developer CLI"):::core
    Dev("👤 Developer") --> DevBox("🖥️ Dev Box Portal"):::core
    AZD --> Orchestrator("📦 IaC Orchestrator"):::core

    subgraph platform["DevExp-DevBox Platform"]
        Orchestrator --> Workload("⚙️ Workload Module"):::core
        Orchestrator --> Security("🔒 Security Module"):::neutral
        Orchestrator --> Monitoring("📊 Monitoring Module"):::neutral
        Workload --> DevCenter("🏗️ DevCenter"):::core
        DevCenter --> Projects("📁 Projects"):::core
        Projects --> Pools("🖥️ Dev Box Pools"):::neutral
    end

    DevCenter --> ARM("☁️ Azure Resource Manager"):::external
    Security --> KV("🔑 Azure Key Vault"):::data
    Monitoring --> LA("📊 Log Analytics"):::data
    DevCenter --> GitHub("🐙 GitHub Repos"):::external
    DevCenter --> AAD("🔐 Microsoft Entra ID"):::external

    style platform fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef external fill:#E0F7F7,stroke:#038387,stroke-width:2px,color:#323130
```

```mermaid
---
title: Application Service Ecosystem Map
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
    accTitle: Application Service Ecosystem Map
    accDescr: Shows all application components grouped by functional domain including workload, security, connectivity, identity, and management layers

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

    Main("📦 Main Orchestrator"):::core

    subgraph workloadLayer["Workload Domain"]
        WL("⚙️ Workload Service"):::core
        DC("🏗️ DevCenter"):::core
        CAT("📚 Catalog"):::neutral
        ET("🏷️ Environment Type"):::neutral
        PROJ("📁 Project"):::core
        PCAT("📚 Project Catalog"):::neutral
        PET("🏷️ Project Env Type"):::neutral
        POOL("🖥️ Project Pool"):::neutral
    end

    subgraph securityLayer["Security Domain"]
        SEC("🔒 Security Service"):::core
        KV("🔑 Key Vault"):::data
        SECRET("🔐 Secret"):::data
    end

    subgraph connectivityLayer["Connectivity Domain"]
        CONN("🌐 Connectivity Service"):::core
        VNET("🔌 Virtual Network"):::neutral
        NETCONN("🔌 Network Connection"):::neutral
    end

    subgraph identityLayer["Identity Domain"]
        DCRA("🛡️ DevCenter RBAC"):::neutral
        ORA("🛡️ Org Role Assignment"):::neutral
        PIRA("🛡️ Project Identity RBAC"):::neutral
        KVA("🛡️ Key Vault Access"):::neutral
    end

    subgraph mgmtLayer["Management Domain"]
        LA("📊 Log Analytics"):::data
    end

    Main --> WL
    Main --> SEC
    Main --> LA
    WL --> DC
    DC --> CAT
    DC --> ET
    DC --> DCRA
    DC --> ORA
    WL --> PROJ
    PROJ --> PCAT
    PROJ --> PET
    PROJ --> POOL
    PROJ --> PIRA
    PROJ --> CONN
    CONN --> VNET
    CONN --> NETCONN
    SEC --> KV
    SEC --> SECRET
    KV --> KVA

    style workloadLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style securityLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style connectivityLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style identityLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style mgmtLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
```

### 2.1 Application Services

| Name                   | Description                                                                                                              | Source                                  | Confidence | Service Type     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------------- | ---------- | ---------------- |
| Main Orchestrator      | Subscription-scoped entry point that creates resource groups and delegates to monitoring, security, and workload modules | infra/main.bicep:1-168                  | 0.92       | Orchestrator     |
| DevCenter Core Service | Provisions the Azure DevCenter instance with identity, catalogs, environment types, diagnostics, and RBAC assignments    | src/workload/core/devCenter.bicep:1-236 | 0.91       | PaaS Provisioner |
| Workload Service       | Loads DevCenter YAML configuration and orchestrates core DevCenter and project deployments                               | src/workload/workload.bicep:1-84        | 0.94       | Orchestrator     |
| Security Service       | Orchestrates Key Vault creation and secret provisioning using security YAML configuration                                | src/security/security.bicep:1-47        | 0.94       | Orchestrator     |

### 2.2 Application Components

| Name                    | Description                                                                                       | Source                                        | Confidence | Service Type     |
| ----------------------- | ------------------------------------------------------------------------------------------------- | --------------------------------------------- | ---------- | ---------------- |
| Key Vault               | Provisions Azure Key Vault with purge protection, soft delete, and RBAC authorization             | src/security/keyVault.bicep:1-73              | 0.97       | PaaS             |
| Log Analytics Workspace | Deploys centralized Log Analytics workspace with AzureActivity solution and self-diagnostics      | src/management/logAnalytics.bicep:1-98        | 0.97       | PaaS             |
| Virtual Network         | Creates or references virtual networks with diagnostic settings for DevCenter connectivity        | src/connectivity/vnet.bicep:1-89              | 0.94       | PaaS             |
| Network Connection      | Creates DevCenter network connections with AzureADJoin domain join and subnet attachment          | src/connectivity/networkConnection.bicep:1-47 | 0.97       | PaaS             |
| Project                 | Provisions DevCenter projects with identity, catalogs, environment types, pools, and connectivity | src/workload/project/project.bicep:1-197      | 0.97       | PaaS Provisioner |
| Project Pool            | Creates Dev Box pools with VM SKU configuration and image definition catalog references           | src/workload/project/projectPool.bicep:1-92   | 0.97       | PaaS             |
| Secret                  | Stores secrets in Key Vault with diagnostic logging to Log Analytics                              | src/security/secret.bicep:1-45                | 0.94       | PaaS             |

### 2.3 Application Interfaces

| Name                        | Description                                                                                   | Source                                    | Confidence | Service Type |
| --------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------- | ---------- | ------------ |
| DevCenter ARM Interface     | Azure Resource Manager API contract for DevCenter resource provisioning at 2026-01-01-preview | src/workload/core/devCenter.bicep:159-176 | 0.88       | ARM API      |
| Key Vault ARM Interface     | Azure Resource Manager API contract for Key Vault provisioning at 2025-05-01                  | src/security/keyVault.bicep:47-73         | 0.88       | ARM API      |
| Log Analytics ARM Interface | Azure Resource Manager API contract for Log Analytics workspace at 2025-07-01                 | src/management/logAnalytics.bicep:38-50   | 0.85       | ARM API      |

### 2.4 Application Collaborations

| Name                       | Description                                                                              | Source                                   | Confidence | Service Type          |
| -------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------- | ---------- | --------------------- |
| Workload Deployment Chain  | Sequential orchestration: Main → Monitoring → Security → Workload → Projects → Pools     | src/workload/workload.bicep:44-84        | 0.91       | Service Orchestration |
| Connectivity Orchestration | Coordinates VNet provisioning, resource group creation, and DevCenter network attachment | src/connectivity/connectivity.bicep:1-65 | 0.91       | Service Orchestration |

### 2.5 Application Functions

| Name                             | Description                                                                                | Source                                                 | Confidence | Service Type  |
| -------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------ | ---------- | ------------- |
| DevCenter RBAC Assignment        | Assigns subscription-scoped roles to DevCenter managed identity                            | src/identity/devCenterRoleAssignment.bicep:1-42        | 0.91       | Authorization |
| Organization Role Assignment     | Assigns resource-group-scoped roles to Azure AD groups via looped role definitions         | src/identity/orgRoleAssignment.bicep:1-50              | 0.91       | Authorization |
| Project Identity RBAC            | Assigns project-scoped and RG-scoped roles to project managed identities                   | src/identity/projectIdentityRoleAssignment.bicep:1-54  | 0.91       | Authorization |
| Key Vault Access                 | Assigns Key Vault Secrets User role to service principals for secret access                | src/identity/keyVaultAccess.bicep:1-21                 | 0.91       | Authorization |
| Catalog Management               | Registers GitHub and Azure DevOps Git catalogs with scheduled sync on DevCenter            | src/workload/core/catalog.bicep:1-68                   | 0.88       | Configuration |
| Environment Type Management      | Creates named environment types (dev, staging, UAT) on DevCenter                           | src/workload/core/environmentType.bicep:1-36           | 0.88       | Configuration |
| Project Catalog Registration     | Registers project-level catalogs for environment and image definitions                     | src/workload/project/projectCatalog.bicep:1-59         | 0.88       | Configuration |
| Project Environment Provisioning | Creates project-scoped environment types with SystemAssigned identity and Contributor role | src/workload/project/projectEnvironmentType.bicep:1-50 | 0.88       | Configuration |

### 2.6 Application Interactions

| Name                    | Description                                                                                           | Source                                    | Confidence | Service Type     |
| ----------------------- | ----------------------------------------------------------------------------------------------------- | ----------------------------------------- | ---------- | ---------------- |
| Bicep Module Invocation | Module-to-module communication via Bicep module references with parameter passing and output chaining | infra/main.bicep:89-168                   | 0.88       | Module Reference |
| ARM API Deployment      | Bicep-to-ARM REST API interaction for all Azure resource provisioning operations                      | src/workload/core/devCenter.bicep:159-176 | 0.85       | Request/Response |

### 2.7 Application Events

| Name                           | Description                                                                            | Source                                    | Confidence | Service Type     |
| ------------------------------ | -------------------------------------------------------------------------------------- | ----------------------------------------- | ---------- | ---------------- |
| DevCenter Diagnostic Streaming | Streams allLogs and AllMetrics from DevCenter to Log Analytics via diagnostic settings | src/workload/core/devCenter.bicep:178-199 | 0.88       | Diagnostic Event |
| Key Vault Diagnostic Streaming | Streams allLogs and AllMetrics from Key Vault to Log Analytics via diagnostic settings | src/security/secret.bicep:34-45           | 0.85       | Diagnostic Event |
| VNet Diagnostic Streaming      | Streams allLogs and AllMetrics from Virtual Network to Log Analytics                   | src/connectivity/vnet.bicep:63-82         | 0.85       | Diagnostic Event |
| Log Analytics Self-Diagnostics | Self-referencing diagnostic settings for Log Analytics workspace monitoring            | src/management/logAnalytics.bicep:72-91   | 0.85       | Diagnostic Event |

### 2.8 Application Data Objects

| Name             | Description                                                                                | Source                                     | Confidence | Service Type    |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------ | ---------- | --------------- |
| DevCenterConfig  | Typed configuration object for DevCenter name, identity, feature toggles, and tags         | src/workload/core/devCenter.bicep:30-65    | 0.91       | Type Definition |
| KeyVaultSettings | Typed configuration for Key Vault name, purge protection, soft delete, and RBAC settings   | src/security/keyVault.bicep:13-35          | 0.91       | Type Definition |
| NetworkSettings  | Typed configuration for VNet name, type, addressing, and subnet definitions                | src/connectivity/vnet.bicep:14-36          | 0.88       | Type Definition |
| ProjectNetwork   | Typed configuration for project network including VNet type, address prefixes, and subnets | src/workload/project/project.bicep:41-60   | 0.88       | Type Definition |
| PoolConfig       | Typed configuration for Dev Box pool name, image definition, and VM SKU                    | src/workload/project/project.bicep:128-139 | 0.85       | Type Definition |

### 2.9 Integration Patterns

| Name                  | Description                                                                                             | Source                            | Confidence | Service Type          |
| --------------------- | ------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------- | --------------------- |
| Configuration-as-Code | YAML config files loaded via loadYamlContent() and validated against JSON Schemas before ARM deployment | src/workload/workload.bicep:41-42 | 0.94       | Config Integration    |
| Module Composition    | Hierarchical Bicep module orchestration with explicit dependency ordering via dependsOn                 | infra/main.bicep:89-168           | 0.94       | Orchestration Pattern |

### 2.10 Service Contracts

| Name                           | Description                                                                                      | Source                                                            | Confidence | Service Type |
| ------------------------------ | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- | ---------- | ------------ |
| DevCenter Configuration Schema | JSON Schema draft-07 validating DevCenter, projects, catalogs, pools, and RBAC configuration     | infra/settings/workload/devcenter.schema.json:\*                  | 0.94       | JSON Schema  |
| Security Configuration Schema  | JSON Schema draft-07 validating Key Vault name, soft delete, purge protection, and RBAC settings | infra/settings/security/security.schema.json:\*                   | 0.94       | JSON Schema  |
| Resource Organization Schema   | JSON Schema draft-07 validating resource group names, create flags, and required tags            | infra/settings/resourceOrganization/azureResources.schema.json:\* | 0.94       | JSON Schema  |

### 2.11 Application Dependencies

| Name                         | Description                                                                                   | Source                                    | Confidence | Service Type   |
| ---------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------- | ---------- | -------------- |
| Azure Developer CLI          | Deployment orchestration via azd with preprovision hooks for environment setup and validation | azure.yaml:1-38                           | 0.94       | CLI Framework  |
| Hugo Documentation Framework | Static site generation using Docsy theme v0.10.0 with Hugo Extended 0.136.2                   | package.json:1-50                         | 0.82       | Documentation  |
| ARM API 2026-01-01-preview   | Azure Resource Manager API version for DevCenter, projects, pools, and catalogs               | src/workload/core/devCenter.bicep:159-176 | 0.88       | API Dependency |
| ARM API 2025-05-01           | Azure Resource Manager API version for Key Vault and Virtual Network resources                | src/security/keyVault.bicep:47-48         | 0.85       | API Dependency |

### Summary

The Architecture Landscape reveals a well-structured IaC platform with 29
components distributed across all 11 TOGAF Application Architecture types. The
Workload domain contains the highest concentration of components (12), followed
by Identity (4) and Security (3). All components demonstrate confidence scores
above the 0.7 threshold, with an average of 0.93 indicating strong source
traceability.

The platform follows a clear separation of concerns: workload provisioning,
security management, network connectivity, identity governance, and operational
monitoring are each isolated into dedicated Bicep module directories.
Cross-cutting concerns such as diagnostic logging and RBAC assignment are
implemented as reusable modules referenced across multiple domains.

---

## Section 3: Architecture Principles

### Overview

The following design principles were observed in the source code through static
analysis of the Bicep module structure, configuration patterns, and deployment
automation. Each principle is supported by direct evidence from source files.
Five principles meet the comprehensive quality threshold.

#### Principle 1: Modular Composition

**Description**: The platform decomposes infrastructure into
single-responsibility Bicep modules that can be composed, versioned, and tested
independently.

**Evidence**: infra/main.bicep:89-168 — The main orchestrator delegates to three
domain modules (monitoring, security, workload) via Bicep module references with
explicit scope isolation and dependency ordering.

**Compliance**: Full — Every resource type is encapsulated in a dedicated module
file; no resource definitions appear in the orchestrator.

#### Principle 2: Configuration-as-Code

**Description**: All environment-specific settings are externalized into YAML
configuration files validated against JSON Schemas, ensuring that infrastructure
intent is declarative, auditable, and version-controlled.

**Evidence**: src/workload/workload.bicep:41-42 — `loadYamlContent()` loads
devcenter.yaml; src/security/security.bicep:17-17 — `loadYamlContent()` loads
security.yaml; infra/main.bicep:33-33 — `loadYamlContent()` loads
azureResources.yaml.

**Compliance**: Full — All three configuration domains (workload, security,
resource organization) use YAML with companion JSON Schemas.

#### Principle 3: Least-Privilege Access

**Description**: Identity and RBAC assignments follow the principle of least
privilege, with scoped role assignments at the narrowest applicable scope
(project, resource group, or subscription).

**Evidence**: src/identity/projectIdentityRoleAssignment.bicep:37-54 — Roles are
conditionally assigned at Project scope only when `role.scope == 'Project'`;
src/identity/keyVaultAccess.bicep:11-17 — Key Vault Secrets User (read-only)
role assigned instead of broader Key Vault Administrator.

**Compliance**: Full — Role assignments are scoped per resource level; no
wildcard or Owner role assignments are present.

#### Principle 4: Separation of Resource Groups

**Description**: Resources are organized into purpose-specific resource groups
(workload, security, monitoring) to enforce blast-radius isolation and enable
independent lifecycle management.

**Evidence**: infra/main.bicep:56-82 — Three distinct resource groups are
created: security RG, monitoring RG, and workload RG, each with
component-specific tags.

**Compliance**: Full — All resource group boundaries are enforced via Bicep
scoping (`scope: resourceGroup()`).

#### Principle 5: Diagnostic Observability

**Description**: Every provisioned Azure resource emits diagnostic telemetry
(logs and metrics) to a centralized Log Analytics workspace for operational
visibility.

**Evidence**: src/workload/core/devCenter.bicep:178-199 — DevCenter diagnostic
settings; src/connectivity/vnet.bicep:63-82 — VNet diagnostic settings;
src/management/logAnalytics.bicep:72-91 — Log Analytics self-diagnostics;
src/security/secret.bicep:34-45 — Key Vault diagnostics.

**Compliance**: Full — All primary resources include
`Microsoft.Insights/diagnosticSettings` resources with allLogs and AllMetrics
categories enabled.

---

## Section 4: Current State Baseline

### Overview

The DevExp-DevBox platform is currently deployed as a single-subscription Azure
landing zone using the Azure Developer CLI (`azd`) for provisioning
orchestration. The deployment follows a sequential dependency chain: Monitoring
→ Security → Workload. All resources target the `2025-05-01` or
`2026-01-01-preview` ARM API versions. The platform supports both Linux/macOS
(`setUp.sh`) and Windows (`setUp.ps1`) deployment environments.

#### Service Topology

| Service            | Deployment Target         | Protocol     | Status                      |
| ------------------ | ------------------------- | ------------ | --------------------------- |
| DevCenter          | Workload Resource Group   | ARM REST API | Active (2026-01-01-preview) |
| Projects (eShop)   | Workload Resource Group   | ARM REST API | Active (2026-01-01-preview) |
| Dev Box Pools      | Workload Resource Group   | ARM REST API | Active (2026-01-01-preview) |
| Key Vault          | Security Resource Group   | ARM REST API | Active (2025-05-01)         |
| Log Analytics      | Monitoring Resource Group | ARM REST API | Active (2025-07-01)         |
| Virtual Network    | Workload Resource Group   | ARM REST API | Active (2025-05-01)         |
| Network Connection | Workload Resource Group   | ARM REST API | Active (2026-01-01-preview) |

#### Deployment State

| Attribute                | Value                                                                       |
| ------------------------ | --------------------------------------------------------------------------- |
| Deployment Method        | Azure Developer CLI (azd)                                                   |
| Provisioning Scope       | Subscription                                                                |
| Shell Support            | Bash (setUp.sh), PowerShell (setUp.ps1)                                     |
| Pre-provision Hooks      | Source control validation, Azure authentication, environment variable setup |
| Configuration Validation | JSON Schema validation against 3 schema files                               |
| Cleanup Automation       | cleanSetUp.ps1 — removes subscription deployments                           |

#### Protocol Inventory

| Protocol               | Usage                           | Components                                           |
| ---------------------- | ------------------------------- | ---------------------------------------------------- |
| ARM REST API           | All Azure resource provisioning | All 23 Bicep modules                                 |
| Bicep Module Reference | Inter-module communication      | infra/main.bicep, workload.bicep, connectivity.bicep |
| YAML Configuration     | Declarative settings input      | devcenter.yaml, security.yaml, azureResources.yaml   |
| JSON Schema            | Configuration validation        | 3 schema files validating YAML inputs                |
| Git (HTTPS)            | Catalog synchronization         | GitHub and Azure DevOps Git repositories             |

```mermaid
---
title: Current State Baseline Architecture
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
    accTitle: Current State Baseline Architecture Diagram
    accDescr: Shows the current Azure subscription layout with three resource groups containing workload, security, and monitoring resources with their dependency relationships

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
        subgraph monRG["📊 Monitoring Resource Group"]
            LA("📊 Log Analytics Workspace"):::data
            SOL("📊 AzureActivity Solution"):::data
        end

        subgraph secRG["🔒 Security Resource Group"]
            KV("🔑 Key Vault"):::core
            SEC("🔐 Secret: gha-token"):::data
        end

        subgraph wlRG["⚙️ Workload Resource Group"]
            DC("🏗️ DevCenter"):::core
            PROJ("📁 Project: eShop"):::core
            POOLBE("🖥️ Pool: backend-engineer"):::neutral
            POOLFE("🖥️ Pool: frontend-engineer"):::neutral
            VNET("🔌 Managed VNet 10.0.0.0/16"):::neutral
            NETCONN("🔌 Network Connection"):::neutral
        end
    end

    LA --> KV
    LA --> DC
    KV --> DC
    DC --> PROJ
    PROJ --> POOLBE
    PROJ --> POOLFE
    PROJ --> VNET
    VNET --> NETCONN

    style sub fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style monRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style secRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style wlRG fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
```

### Summary

The platform is in the Active deployment state with all core resources
provisioned via ARM API versions ranging from 2025-05-01 to 2026-01-01-preview.
The deployment chain follows a strict sequential ordering (Monitoring → Security
→ Workload) enforced through Bicep `dependsOn` declarations. Pre-provision hooks
validate Azure CLI authentication, source control platform configuration, and
environment variable availability before deployment begins.

The current baseline supports a single project (eShop) with two Dev Box pools
(backend-engineer, frontend-engineer) connected via a Managed VNet. Environment
types (dev, staging, UAT) are provisioned at both DevCenter and project scopes.
The platform is ready for multi-project expansion through the existing
array-based project iteration pattern in workload.bicep.

---

## Section 5: Component Catalog

### Overview

This section provides detailed specifications for all 29 Application layer
components organized into 11 TOGAF-aligned subsections. Each component includes
the six mandatory sub-attributes: Service Type, API Surface, Dependencies,
Resilience, Scaling, and Health. Components deployed as Azure PaaS services use
the platform-managed template for resilience, scaling, and health attributes.

### 5.1 Application Services

#### 5.1.1 Main Orchestrator

| Attribute          | Value                  |
| ------------------ | ---------------------- |
| **Component Name** | Main Orchestrator      |
| **Service Type**   | Orchestrator           |
| **Source**         | infra/main.bicep:1-168 |
| **Confidence**     | 0.92                   |

**API Surface:**

| Endpoint Type    | Count | Protocol | Description                                                           |
| ---------------- | ----- | -------- | --------------------------------------------------------------------- |
| Bicep Parameters | 3     | Bicep    | location, secretValue, environmentName                                |
| Bicep Outputs    | 8     | Bicep    | Resource group names, Key Vault, Log Analytics, DevCenter identifiers |

**Dependencies:**

| Dependency           | Direction  | Protocol         | Purpose                      |
| -------------------- | ---------- | ---------------- | ---------------------------- |
| Log Analytics Module | Downstream | Module Reference | Centralized monitoring       |
| Security Module      | Downstream | Module Reference | Key Vault and secrets        |
| Workload Module      | Downstream | Module Reference | DevCenter provisioning       |
| azureResources.yaml  | Upstream   | loadYamlContent  | Resource group configuration |

**Resilience (Platform-Managed):**

| Aspect           | Configuration           | Notes                    |
| ---------------- | ----------------------- | ------------------------ |
| Retry Policy     | ARM deployment retries  | Platform-managed         |
| Deployment Scope | Subscription            | Single-region deployment |
| Rollback         | ARM deployment rollback | Automatic on failure     |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration               |
| ---------- | -------------- | --------------------------- |
| Horizontal | Not applicable | Single deployment operation |
| Vertical   | Not applicable | IaC orchestration module    |

**Health (Platform-Managed):**

| Probe Type            | Configuration                   | Source              |
| --------------------- | ------------------------------- | ------------------- |
| ARM Deployment Status | Provisioning state tracking     | Azure Portal        |
| azd Status            | Deployment lifecycle monitoring | Azure Developer CLI |

#### 5.1.2 DevCenter Core Service

| Attribute          | Value                                   |
| ------------------ | --------------------------------------- |
| **Component Name** | DevCenter Core Service                  |
| **Service Type**   | PaaS Provisioner                        |
| **Source**         | src/workload/core/devCenter.bicep:1-236 |
| **Confidence**     | 0.91                                    |

**API Surface:**

| Endpoint Type     | Count | Protocol         | Description                                                                                               |
| ----------------- | ----- | ---------------- | --------------------------------------------------------------------------------------------------------- |
| Bicep Parameters  | 7     | Bicep            | config, catalogs, environmentTypes, logAnalyticsId, secretIdentifier, securityResourceGroupName, location |
| Bicep Outputs     | 1     | Bicep            | AZURE_DEV_CENTER_NAME                                                                                     |
| ARM Resources     | 2     | ARM REST API     | Microsoft.DevCenter/devcenters, Microsoft.Insights/diagnosticSettings                                     |
| Module References | 4     | Module Reference | devCenterRoleAssignment, devCenterRoleAssignmentRG, orgRoleAssignment, catalog, environmentType           |

**Dependencies:**

| Dependency                 | Direction  | Protocol         | Purpose                          |
| -------------------------- | ---------- | ---------------- | -------------------------------- |
| Log Analytics Workspace    | Upstream   | Resource ID      | Diagnostic telemetry destination |
| Key Vault Secret           | Upstream   | Secret URI       | Private catalog authentication   |
| Security Resource Group    | Upstream   | Scope Reference  | RG-scoped RBAC assignment        |
| DevCenter RBAC Module      | Downstream | Module Reference | Identity role assignments        |
| Org Role Assignment Module | Downstream | Module Reference | AD group role assignments        |
| Catalog Module             | Downstream | Module Reference | Catalog registration             |
| Environment Type Module    | Downstream | Module Reference | Environment type creation        |

**Resilience (Platform-Managed):**

| Aspect          | Configuration           | Notes             |
| --------------- | ----------------------- | ----------------- |
| Retry Policy    | ARM SDK defaults        | Platform-managed  |
| Circuit Breaker | Not applicable          | PaaS service      |
| Failover        | Azure region redundancy | Per SKU selection |

**Scaling (Platform-Managed):**

| Dimension  | Strategy          | Configuration    |
| ---------- | ----------------- | ---------------- |
| Horizontal | PaaS auto-scaling | Per pricing tier |
| Vertical   | SKU upgrade       | Manual selection |

**Health (Platform-Managed):**

| Probe Type            | Configuration                         | Source                                    |
| --------------------- | ------------------------------------- | ----------------------------------------- |
| Azure Resource Health | Platform-managed                      | Azure Portal                              |
| Diagnostic Settings   | allLogs + AllMetrics to Log Analytics | src/workload/core/devCenter.bicep:178-199 |

#### 5.1.3 Workload Service

| Attribute          | Value                            |
| ------------------ | -------------------------------- |
| **Component Name** | Workload Service                 |
| **Service Type**   | Orchestrator                     |
| **Source**         | src/workload/workload.bicep:1-84 |
| **Confidence**     | 0.94                             |

**API Surface:**

| Endpoint Type     | Count | Protocol         | Description                                                 |
| ----------------- | ----- | ---------------- | ----------------------------------------------------------- |
| Bicep Parameters  | 3     | Bicep            | logAnalyticsId, secretIdentifier, securityResourceGroupName |
| Bicep Outputs     | 2     | Bicep            | AZURE_DEV_CENTER_NAME, AZURE_DEV_CENTER_PROJECTS            |
| Module References | 2     | Module Reference | devCenter, projects (looped)                                |

**Dependencies:**

| Dependency       | Direction  | Protocol         | Purpose                     |
| ---------------- | ---------- | ---------------- | --------------------------- |
| DevCenter Module | Downstream | Module Reference | Core DevCenter provisioning |
| Project Module   | Downstream | Module Reference | Project deployment (looped) |
| devcenter.yaml   | Upstream   | loadYamlContent  | Full workload configuration |

**Resilience (Platform-Managed):**

| Aspect           | Configuration          | Notes                 |
| ---------------- | ---------------------- | --------------------- |
| Retry Policy     | ARM deployment retries | Platform-managed      |
| Deployment Scope | Resource Group         | Scoped to workload RG |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                      | Configuration             |
| ---------- | ----------------------------- | ------------------------- |
| Horizontal | Array-based project iteration | Projects deployed in loop |

**Health (Platform-Managed):**

| Probe Type            | Configuration               | Source       |
| --------------------- | --------------------------- | ------------ |
| ARM Deployment Status | Provisioning state tracking | Azure Portal |

#### 5.1.4 Security Service

| Attribute          | Value                            |
| ------------------ | -------------------------------- |
| **Component Name** | Security Service                 |
| **Service Type**   | Orchestrator                     |
| **Source**         | src/security/security.bicep:1-47 |
| **Confidence**     | 0.94                             |

**API Surface:**

| Endpoint Type     | Count | Protocol         | Description                                                                       |
| ----------------- | ----- | ---------------- | --------------------------------------------------------------------------------- |
| Bicep Parameters  | 3     | Bicep            | tags, secretValue, logAnalyticsId                                                 |
| Bicep Outputs     | 3     | Bicep            | AZURE_KEY_VAULT_NAME, AZURE_KEY_VAULT_SECRET_IDENTIFIER, AZURE_KEY_VAULT_ENDPOINT |
| Module References | 2     | Module Reference | keyVault (conditional), secret                                                    |

**Dependencies:**

| Dependency       | Direction  | Protocol         | Purpose                |
| ---------------- | ---------- | ---------------- | ---------------------- |
| Key Vault Module | Downstream | Module Reference | Key Vault provisioning |
| Secret Module    | Downstream | Module Reference | Secret storage         |
| security.yaml    | Upstream   | loadYamlContent  | Security configuration |

**Resilience (Platform-Managed):**

| Aspect                   | Configuration                         | Notes                                 |
| ------------------------ | ------------------------------------- | ------------------------------------- |
| Create/Reference Pattern | Conditional (securitySettings.create) | Supports existing Key Vault reference |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration             |
| ---------- | -------------- | ------------------------- |
| Horizontal | Not applicable | Single Key Vault instance |

**Health (Platform-Managed):**

| Probe Type            | Configuration               | Source       |
| --------------------- | --------------------------- | ------------ |
| ARM Deployment Status | Provisioning state tracking | Azure Portal |

### 5.2 Application Components

#### 5.2.1 Key Vault

| Attribute          | Value                            |
| ------------------ | -------------------------------- |
| **Component Name** | Key Vault                        |
| **Service Type**   | PaaS                             |
| **Source**         | src/security/keyVault.bicep:1-73 |
| **Confidence**     | 0.97                             |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                    |
| ------------- | ----- | ------------ | ---------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.KeyVault/vaults@2025-05-01           |
| Bicep Outputs | 2     | Bicep        | AZURE_KEY_VAULT_NAME, AZURE_KEY_VAULT_ENDPOINT |

**Dependencies:**

| Dependency    | Direction | Protocol      | Purpose                                     |
| ------------- | --------- | ------------- | ------------------------------------------- |
| security.yaml | Upstream  | Configuration | Key Vault settings (name, protection, RBAC) |

**Resilience (Platform-Managed):**

| Aspect             | Configuration    | Notes                       |
| ------------------ | ---------------- | --------------------------- |
| Purge Protection   | Enabled          | Prevents permanent deletion |
| Soft Delete        | Enabled (7 days) | Recoverable deletion window |
| RBAC Authorization | Enabled          | Role-based access control   |

**Scaling (Platform-Managed):**

| Dimension  | Strategy          | Configuration               |
| ---------- | ----------------- | --------------------------- |
| Horizontal | PaaS auto-scaling | Per pricing tier (Standard) |
| Vertical   | SKU upgrade       | Standard SKU                |

**Health (Platform-Managed):**

| Probe Type            | Configuration                          | Source                          |
| --------------------- | -------------------------------------- | ------------------------------- |
| Azure Resource Health | Platform-managed                       | Azure Portal                    |
| Diagnostic Logging    | allLogs + AllMetrics via Secret module | src/security/secret.bicep:34-45 |

#### 5.2.2 Log Analytics Workspace

| Attribute          | Value                                  |
| ------------------ | -------------------------------------- |
| **Component Name** | Log Analytics Workspace                |
| **Service Type**   | PaaS                                   |
| **Source**         | src/management/logAnalytics.bicep:1-98 |
| **Confidence**     | 0.97                                   |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                                                     |
| ------------- | ----- | ------------ | ----------------------------------------------------------------------------------------------- |
| ARM Resources | 3     | ARM REST API | Workspace (2025-07-01), Solutions (2015-11-01-preview), DiagnosticSettings (2021-05-01-preview) |
| Bicep Outputs | 2     | Bicep        | AZURE_LOG_ANALYTICS_WORKSPACE_ID, AZURE_LOG_ANALYTICS_WORKSPACE_NAME                            |

**Dependencies:**

| Dependency             | Direction             | Protocol    | Purpose                     |
| ---------------------- | --------------------- | ----------- | --------------------------- |
| AzureActivity Solution | Downstream            | ARM API     | Activity log collection     |
| DevCenter              | Downstream (consumer) | Resource ID | Diagnostic telemetry source |
| Key Vault              | Downstream (consumer) | Resource ID | Diagnostic telemetry source |
| VNet                   | Downstream (consumer) | Resource ID | Diagnostic telemetry source |

**Resilience (Platform-Managed):**

| Aspect           | Configuration     | Notes               |
| ---------------- | ----------------- | ------------------- |
| Data Retention   | Default (30 days) | PerGB2018 SKU       |
| Self-Diagnostics | Enabled           | Logs own operations |

**Scaling (Platform-Managed):**

| Dimension  | Strategy          | Configuration              |
| ---------- | ----------------- | -------------------------- |
| Horizontal | PaaS auto-scaling | PerGB2018 pricing tier     |
| Vertical   | SKU upgrade       | Configurable via parameter |

**Health (Platform-Managed):**

| Probe Type               | Configuration        | Source                                  |
| ------------------------ | -------------------- | --------------------------------------- |
| Azure Resource Health    | Platform-managed     | Azure Portal                            |
| Self-Diagnostic Settings | allLogs + AllMetrics | src/management/logAnalytics.bicep:72-91 |

#### 5.2.3 Virtual Network

| Attribute          | Value                            |
| ------------------ | -------------------------------- |
| **Component Name** | Virtual Network                  |
| **Service Type**   | PaaS                             |
| **Source**         | src/connectivity/vnet.bicep:1-89 |
| **Confidence**     | 0.94                             |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                 |
| ------------- | ----- | ------------ | ----------------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.Network/virtualNetworks@2025-05-01                |
| Bicep Outputs | 1     | Bicep        | AZURE_VIRTUAL_NETWORK (object with name, RG, type, subnets) |

**Dependencies:**

| Dependency         | Direction  | Protocol    | Purpose                          |
| ------------------ | ---------- | ----------- | -------------------------------- |
| Log Analytics      | Upstream   | Resource ID | Diagnostic telemetry destination |
| Network Connection | Downstream | Subnet ID   | DevCenter network attachment     |

**Resilience (Platform-Managed):**

| Aspect           | Configuration                 | Notes                            |
| ---------------- | ----------------------------- | -------------------------------- |
| Create/Reference | Conditional (settings.create) | Supports existing VNet reference |
| Network Type     | Managed or Unmanaged          | Configurable via YAML            |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                | Configuration          |
| ---------- | ----------------------- | ---------------------- |
| Horizontal | Address space expansion | Per CIDR configuration |

**Health (Platform-Managed):**

| Probe Type            | Configuration        | Source                            |
| --------------------- | -------------------- | --------------------------------- |
| Azure Resource Health | Platform-managed     | Azure Portal                      |
| Diagnostic Settings   | allLogs + AllMetrics | src/connectivity/vnet.bicep:63-82 |

#### 5.2.4 Network Connection

| Attribute          | Value                                         |
| ------------------ | --------------------------------------------- |
| **Component Name** | Network Connection                            |
| **Service Type**   | PaaS                                          |
| **Source**         | src/connectivity/networkConnection.bicep:1-47 |
| **Confidence**     | 0.97                                          |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                                |
| ------------- | ----- | ------------ | -------------------------------------------------------------------------- |
| ARM Resources | 2     | ARM REST API | networkConnections@2026-01-01-preview, attachednetworks@2026-01-01-preview |
| Bicep Outputs | 3     | Bicep        | vnetAttachmentName, networkConnectionId, attachedNetworkId                 |

**Dependencies:**

| Dependency             | Direction | Protocol           | Purpose                        |
| ---------------------- | --------- | ------------------ | ------------------------------ |
| DevCenter              | Upstream  | Resource Reference | Parent resource for attachment |
| Virtual Network Subnet | Upstream  | Resource ID        | Subnet to connect              |

**Resilience (Platform-Managed):**

| Aspect      | Configuration | Notes                          |
| ----------- | ------------- | ------------------------------ |
| Domain Join | AzureADJoin   | Microsoft Entra ID integration |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration           |
| ---------- | -------------- | ----------------------- |
| Horizontal | Not applicable | One connection per VNet |

**Health (Platform-Managed):**

| Probe Type            | Configuration    | Source       |
| --------------------- | ---------------- | ------------ |
| Azure Resource Health | Platform-managed | Azure Portal |

#### 5.2.5 Project

| Attribute          | Value                                    |
| ------------------ | ---------------------------------------- |
| **Component Name** | Project                                  |
| **Service Type**   | PaaS Provisioner                         |
| **Source**         | src/workload/project/project.bicep:1-197 |
| **Confidence**     | 0.97                                     |

**API Surface:**

| Endpoint Type     | Count | Protocol         | Description                                                                                                |
| ----------------- | ----- | ---------------- | ---------------------------------------------------------------------------------------------------------- |
| Bicep Parameters  | 11    | Bicep            | name, logAnalyticsId, devCenterName, catalogs, pools, network, identity, tags, and others                  |
| ARM Resource      | 1     | ARM REST API     | Microsoft.DevCenter/projects@2026-01-01-preview                                                            |
| Bicep Outputs     | 2     | Bicep            | AZURE_PROJECT_NAME, AZURE_PROJECT_ID                                                                       |
| Module References | 6     | Module Reference | projectIdentity, projectIdentityRG, projectADGroup, projectCatalogs, environmentTypes, connectivity, pools |

**Dependencies:**

| Dependency               | Direction  | Protocol           | Purpose                           |
| ------------------------ | ---------- | ------------------ | --------------------------------- |
| DevCenter                | Upstream   | Resource Reference | Parent DevCenter                  |
| Project Identity RBAC    | Downstream | Module Reference   | Managed identity role assignments |
| Project Catalog          | Downstream | Module Reference   | Catalog registration              |
| Project Environment Type | Downstream | Module Reference   | Environment type creation         |
| Connectivity             | Downstream | Module Reference   | Network provisioning              |
| Project Pool             | Downstream | Module Reference   | Dev Box pool creation             |

**Resilience (Platform-Managed):**

| Aspect       | Configuration                           | Notes                             |
| ------------ | --------------------------------------- | --------------------------------- |
| Identity     | SystemAssigned                          | Managed identity auto-provisioned |
| Catalog Sync | EnvironmentDefinition + ImageDefinition | Dual sync type                    |

**Scaling (Platform-Managed):**

| Dimension  | Strategy              | Configuration                                |
| ---------- | --------------------- | -------------------------------------------- |
| Horizontal | Array-based iteration | Multiple projects via loop in workload.bicep |

**Health (Platform-Managed):**

| Probe Type            | Configuration    | Source       |
| --------------------- | ---------------- | ------------ |
| Azure Resource Health | Platform-managed | Azure Portal |

#### 5.2.6 Project Pool

| Attribute          | Value                                       |
| ------------------ | ------------------------------------------- |
| **Component Name** | Project Pool                                |
| **Service Type**   | PaaS                                        |
| **Source**         | src/workload/project/projectPool.bicep:1-92 |
| **Confidence**     | 0.97                                        |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                           |
| ------------- | ----- | ------------ | ----------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.DevCenter/projects/pools@2026-01-01-preview |
| Bicep Outputs | 1     | Bicep        | poolNames (array)                                     |

**Dependencies:**

| Dependency         | Direction | Protocol           | Purpose                      |
| ------------------ | --------- | ------------------ | ---------------------------- |
| Project            | Upstream  | Resource Reference | Parent project               |
| Catalog            | Upstream  | Image Reference    | Image definition for Dev Box |
| Network Connection | Upstream  | Connection Name    | Network connectivity         |

**Resilience (Platform-Managed):**

| Aspect      | Configuration  | Notes                        |
| ----------- | -------------- | ---------------------------- |
| License     | Windows_Client | Included licensing           |
| Local Admin | Enabled        | Developer workstation access |
| SSO         | Enabled        | Single sign-on via Entra ID  |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                                                | Configuration                   |
| ---------- | ------------------------------------------------------- | ------------------------------- |
| Horizontal | Array-based iteration                                   | Multiple pools via catalog loop |
| VM SKUs    | general_i_32c128gb512ssd_v2, general_i_16c64gb256ssd_v2 | Per pool configuration          |

**Health (Platform-Managed):**

| Probe Type            | Configuration           | Source                 |
| --------------------- | ----------------------- | ---------------------- |
| Azure Resource Health | Platform-managed        | Azure Portal           |
| Pool Health           | DevCenter health checks | Azure DevCenter Portal |

#### 5.2.7 Secret

| Attribute          | Value                          |
| ------------------ | ------------------------------ |
| **Component Name** | Secret                         |
| **Service Type**   | PaaS                           |
| **Source**         | src/security/secret.bicep:1-45 |
| **Confidence**     | 0.94                           |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                  |
| ------------- | ----- | ------------ | -------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.KeyVault/vaults/secrets@2025-05-01 |
| Bicep Outputs | 1     | Bicep        | AZURE_KEY_VAULT_SECRET_IDENTIFIER            |

**Dependencies:**

| Dependency    | Direction | Protocol           | Purpose                          |
| ------------- | --------- | ------------------ | -------------------------------- |
| Key Vault     | Upstream  | Resource Reference | Parent vault for secret storage  |
| Log Analytics | Upstream  | Resource ID        | Diagnostic telemetry destination |

**Resilience (Platform-Managed):**

| Aspect       | Configuration | Notes            |
| ------------ | ------------- | ---------------- |
| Content Type | text/plain    | Secret attribute |
| Enabled      | true          | Active secret    |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration           |
| ---------- | -------------- | ----------------------- |
| Horizontal | Not applicable | Single secret per vault |

**Health (Platform-Managed):**

| Probe Type            | Configuration                         | Source                          |
| --------------------- | ------------------------------------- | ------------------------------- |
| Key Vault Diagnostics | allLogs + AllMetrics to Log Analytics | src/security/secret.bicep:34-45 |

### 5.3 Application Interfaces

#### 5.3.1 DevCenter ARM Interface

| Attribute          | Value                                     |
| ------------------ | ----------------------------------------- |
| **Component Name** | DevCenter ARM Interface                   |
| **Service Type**   | ARM API                                   |
| **Source**         | src/workload/core/devCenter.bicep:159-176 |
| **Confidence**     | 0.88                                      |

**API Surface:**

| Endpoint Type     | Count | Protocol   | Description                                       |
| ----------------- | ----- | ---------- | ------------------------------------------------- |
| ARM Resource Type | 1     | REST (ARM) | Microsoft.DevCenter/devcenters@2026-01-01-preview |

**Dependencies:**

| Dependency             | Direction | Protocol | Purpose                    |
| ---------------------- | --------- | -------- | -------------------------- |
| Azure Resource Manager | Upstream  | REST API | Resource deployment engine |

**Resilience (Platform-Managed):**

| Aspect      | Configuration      | Notes                                     |
| ----------- | ------------------ | ----------------------------------------- |
| API Version | 2026-01-01-preview | Preview API — subject to breaking changes |

**Scaling (Platform-Managed):**

| Dimension  | Strategy              | Configuration           |
| ---------- | --------------------- | ----------------------- |
| Horizontal | ARM throttling limits | Per-subscription limits |

**Health (Platform-Managed):**

| Probe Type         | Configuration    | Source       |
| ------------------ | ---------------- | ------------ |
| ARM Service Health | Platform-managed | Azure Status |

#### 5.3.2 Key Vault ARM Interface

| Attribute          | Value                             |
| ------------------ | --------------------------------- |
| **Component Name** | Key Vault ARM Interface           |
| **Service Type**   | ARM API                           |
| **Source**         | src/security/keyVault.bicep:47-73 |
| **Confidence**     | 0.88                              |

**API Surface:**

| Endpoint Type     | Count | Protocol   | Description                          |
| ----------------- | ----- | ---------- | ------------------------------------ |
| ARM Resource Type | 1     | REST (ARM) | Microsoft.KeyVault/vaults@2025-05-01 |

**Dependencies:**

| Dependency             | Direction | Protocol | Purpose                    |
| ---------------------- | --------- | -------- | -------------------------- |
| Azure Resource Manager | Upstream  | REST API | Resource deployment engine |

**Resilience (Platform-Managed):**

| Aspect      | Configuration | Notes               |
| ----------- | ------------- | ------------------- |
| API Version | 2025-05-01    | Generally Available |

**Scaling (Platform-Managed):**

| Dimension  | Strategy              | Configuration           |
| ---------- | --------------------- | ----------------------- |
| Horizontal | ARM throttling limits | Per-subscription limits |

**Health (Platform-Managed):**

| Probe Type         | Configuration    | Source       |
| ------------------ | ---------------- | ------------ |
| ARM Service Health | Platform-managed | Azure Status |

#### 5.3.3 Log Analytics ARM Interface

| Attribute          | Value                                   |
| ------------------ | --------------------------------------- |
| **Component Name** | Log Analytics ARM Interface             |
| **Service Type**   | ARM API                                 |
| **Source**         | src/management/logAnalytics.bicep:38-50 |
| **Confidence**     | 0.85                                    |

**API Surface:**

| Endpoint Type     | Count | Protocol   | Description                                         |
| ----------------- | ----- | ---------- | --------------------------------------------------- |
| ARM Resource Type | 1     | REST (ARM) | Microsoft.OperationalInsights/workspaces@2025-07-01 |

**Dependencies:**

| Dependency             | Direction | Protocol | Purpose                    |
| ---------------------- | --------- | -------- | -------------------------- |
| Azure Resource Manager | Upstream  | REST API | Resource deployment engine |

**Resilience (Platform-Managed):**

| Aspect      | Configuration | Notes               |
| ----------- | ------------- | ------------------- |
| API Version | 2025-07-01    | Generally Available |

**Scaling (Platform-Managed):**

| Dimension  | Strategy              | Configuration           |
| ---------- | --------------------- | ----------------------- |
| Horizontal | ARM throttling limits | Per-subscription limits |

**Health (Platform-Managed):**

| Probe Type         | Configuration    | Source       |
| ------------------ | ---------------- | ------------ |
| ARM Service Health | Platform-managed | Azure Status |

### 5.4 Application Collaborations

#### 5.4.1 Workload Deployment Chain

| Attribute          | Value                             |
| ------------------ | --------------------------------- |
| **Component Name** | Workload Deployment Chain         |
| **Service Type**   | Service Orchestration             |
| **Source**         | src/workload/workload.bicep:44-84 |
| **Confidence**     | 0.91                              |

**API Surface:**

| Endpoint Type     | Count | Protocol | Description                        |
| ----------------- | ----- | -------- | ---------------------------------- |
| Module References | 2     | Bicep    | DevCenter core + Projects (looped) |

**Dependencies:**

| Dependency       | Direction  | Protocol         | Purpose                                          |
| ---------------- | ---------- | ---------------- | ------------------------------------------------ |
| DevCenter Module | Downstream | Module Reference | Core infrastructure provisioning                 |
| Project Module   | Downstream | Module Reference | Project deployment (depends on DevCenter output) |
| devcenter.yaml   | Upstream   | loadYamlContent  | Configuration source                             |

**Resilience (Platform-Managed):**

| Aspect              | Configuration                | Notes                               |
| ------------------- | ---------------------------- | ----------------------------------- |
| Dependency Ordering | Implicit via output chaining | Projects depend on DevCenter output |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                | Configuration       |
| ---------- | ----------------------- | ------------------- |
| Horizontal | Project array iteration | Supports N projects |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Deployment Status | Provisioning state per module | Azure Portal |

#### 5.4.2 Connectivity Orchestration

| Attribute          | Value                                    |
| ------------------ | ---------------------------------------- |
| **Component Name** | Connectivity Orchestration               |
| **Service Type**   | Service Orchestration                    |
| **Source**         | src/connectivity/connectivity.bicep:1-65 |
| **Confidence**     | 0.91                                     |

**API Surface:**

| Endpoint Type     | Count | Protocol | Description                                      |
| ----------------- | ----- | -------- | ------------------------------------------------ |
| Module References | 3     | Bicep    | resourceGroup, virtualNetwork, networkConnection |
| Bicep Outputs     | 2     | Bicep    | networkConnectionName, networkType               |

**Dependencies:**

| Dependency                | Direction  | Protocol         | Purpose                            |
| ------------------------- | ---------- | ---------------- | ---------------------------------- |
| Resource Group Module     | Downstream | Module Reference | Network RG creation                |
| VNet Module               | Downstream | Module Reference | Virtual network provisioning       |
| Network Connection Module | Downstream | Module Reference | DevCenter attachment (conditional) |

**Resilience (Platform-Managed):**

| Aspect               | Configuration                      | Notes                                |
| -------------------- | ---------------------------------- | ------------------------------------ |
| Conditional Creation | networkConnectivityCreate variable | Only creates for Unmanaged VNet type |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration                    |
| ---------- | -------------- | -------------------------------- |
| Horizontal | Not applicable | One connectivity set per project |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Deployment Status | Provisioning state per module | Azure Portal |

### 5.5 Application Functions

#### 5.5.1 DevCenter RBAC Assignment

| Attribute          | Value                                           |
| ------------------ | ----------------------------------------------- |
| **Component Name** | DevCenter RBAC Assignment                       |
| **Service Type**   | Authorization                                   |
| **Source**         | src/identity/devCenterRoleAssignment.bicep:1-42 |
| **Confidence**     | 0.91                                            |

**API Surface:**

| Endpoint Type    | Count | Protocol     | Description                                        |
| ---------------- | ----- | ------------ | -------------------------------------------------- |
| ARM Resource     | 1     | ARM REST API | Microsoft.Authorization/roleAssignments@2022-04-01 |
| Bicep Parameters | 4     | Bicep        | id, principalId, principalType, scope              |
| Bicep Outputs    | 2     | Bicep        | roleAssignmentId, scope                            |

**Dependencies:**

| Dependency         | Direction | Protocol           | Purpose                             |
| ------------------ | --------- | ------------------ | ----------------------------------- |
| DevCenter Identity | Upstream  | Principal ID       | Managed identity to assign roles to |
| Role Definition    | Upstream  | Resource Reference | Existing role definition lookup     |

**Resilience (Platform-Managed):**

| Aspect      | Configuration                           | Notes                          |
| ----------- | --------------------------------------- | ------------------------------ |
| Scope Guard | Conditional (`scope == 'Subscription'`) | Only assigns at matching scope |
| Idempotency | GUID-based assignment ID                | Prevents duplicate assignments |

**Scaling (Platform-Managed):**

| Dimension  | Strategy      | Configuration                                        |
| ---------- | ------------- | ---------------------------------------------------- |
| Horizontal | Loop per role | Iterated in devCenter.bicep for each configured role |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Assignment Status | Assignment provisioning state | Azure Portal |

#### 5.5.2 Organization Role Assignment

| Attribute          | Value                                     |
| ------------------ | ----------------------------------------- |
| **Component Name** | Organization Role Assignment              |
| **Service Type**   | Authorization                             |
| **Source**         | src/identity/orgRoleAssignment.bicep:1-50 |
| **Confidence**     | 0.91                                      |

**API Surface:**

| Endpoint Type    | Count      | Protocol     | Description                                        |
| ---------------- | ---------- | ------------ | -------------------------------------------------- |
| ARM Resource     | 1 (looped) | ARM REST API | Microsoft.Authorization/roleAssignments@2022-04-01 |
| Bicep Parameters | 3          | Bicep        | principalId, roles (array), principalType          |
| Bicep Outputs    | 2          | Bicep        | roleAssignmentIds (array), principalId             |

**Dependencies:**

| Dependency       | Direction | Protocol        | Purpose                              |
| ---------------- | --------- | --------------- | ------------------------------------ |
| Azure AD Group   | Upstream  | Group Object ID | Target principal for role assignment |
| Role Definitions | Upstream  | Role GUIDs      | Roles to assign (array)              |

**Resilience (Platform-Managed):**

| Aspect      | Configuration            | Notes                                |
| ----------- | ------------------------ | ------------------------------------ |
| Idempotency | GUID-based assignment ID | Composite GUID prevents duplicates   |
| Scope       | Resource Group           | Assignments scoped to resource group |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                     | Configuration                  |
| ---------- | ---------------------------- | ------------------------------ |
| Horizontal | Loop per role in roles array | Supports N roles per principal |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Assignment Status | Assignment provisioning state | Azure Portal |

#### 5.5.3 Project Identity RBAC

See Section 2.5. Assigns project-scoped and RG-scoped roles to project managed
identities with conditional scope filtering.

| Attribute          | Value                                                 |
| ------------------ | ----------------------------------------------------- |
| **Component Name** | Project Identity RBAC                                 |
| **Service Type**   | Authorization                                         |
| **Source**         | src/identity/projectIdentityRoleAssignment.bicep:1-54 |
| **Confidence**     | 0.91                                                  |

**API Surface:**

| Endpoint Type | Count      | Protocol     | Description                                        |
| ------------- | ---------- | ------------ | -------------------------------------------------- |
| ARM Resource  | 1 (looped) | ARM REST API | Microsoft.Authorization/roleAssignments@2022-04-01 |

**Dependencies:**

| Dependency       | Direction | Protocol           | Purpose                   |
| ---------------- | --------- | ------------------ | ------------------------- |
| Project Identity | Upstream  | Principal ID       | Project managed identity  |
| Project Resource | Upstream  | Resource Reference | Scope for role assignment |

**Resilience (Platform-Managed):**

| Aspect      | Configuration                           | Notes                          |
| ----------- | --------------------------------------- | ------------------------------ |
| Scope Guard | Conditional (`role.scope == 'Project'`) | Only assigns at matching scope |

**Scaling (Platform-Managed):**

| Dimension  | Strategy      | Configuration                 |
| ---------- | ------------- | ----------------------------- |
| Horizontal | Loop per role | Supports N roles per identity |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Assignment Status | Assignment provisioning state | Azure Portal |

#### 5.5.4 Key Vault Access

See Section 2.5. Assigns Key Vault Secrets User role to service principals.

| Attribute          | Value                                  |
| ------------------ | -------------------------------------- |
| **Component Name** | Key Vault Access                       |
| **Service Type**   | Authorization                          |
| **Source**         | src/identity/keyVaultAccess.bicep:1-21 |
| **Confidence**     | 0.91                                   |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                        |
| ------------- | ----- | ------------ | -------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.Authorization/roleAssignments@2022-04-01 |
| Bicep Outputs | 2     | Bicep        | roleAssignmentId, roleAssignmentName               |

**Dependencies:**

| Dependency        | Direction | Protocol     | Purpose                             |
| ----------------- | --------- | ------------ | ----------------------------------- |
| Service Principal | Upstream  | Principal ID | Identity requiring Key Vault access |

**Resilience (Platform-Managed):**

| Aspect     | Configuration                     | Notes                   |
| ---------- | --------------------------------- | ----------------------- |
| Fixed Role | Key Vault Secrets User (4633458b) | Read-only secret access |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration                   |
| ---------- | -------------- | ------------------------------- |
| Horizontal | Not applicable | Single assignment per principal |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Assignment Status | Assignment provisioning state | Azure Portal |

#### 5.5.5 Catalog Management

See Section 2.5. Registers DevCenter catalogs with GitHub and Azure DevOps Git
support.

| Attribute          | Value                                |
| ------------------ | ------------------------------------ |
| **Component Name** | Catalog Management                   |
| **Service Type**   | Configuration                        |
| **Source**         | src/workload/core/catalog.bicep:1-68 |
| **Confidence**     | 0.88                                 |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                |
| ------------- | ----- | ------------ | ---------------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.DevCenter/devcenters/catalogs@2026-01-01-preview |
| Bicep Outputs | 1     | Bicep        | AZURE_DEV_CENTER_CATALOG_NAME                              |

**Dependencies:**

| Dependency        | Direction | Protocol           | Purpose                        |
| ----------------- | --------- | ------------------ | ------------------------------ |
| DevCenter         | Upstream  | Resource Reference | Parent resource                |
| Secret Identifier | Upstream  | Secure Parameter   | Private repo authentication    |
| Git Repository    | External  | HTTPS              | Catalog source (GitHub or ADO) |

**Resilience (Platform-Managed):**

| Aspect     | Configuration     | Notes                              |
| ---------- | ----------------- | ---------------------------------- |
| Sync Type  | Scheduled         | Automatic catalog synchronization  |
| Visibility | Public or Private | Private repos use secretIdentifier |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                | Configuration               |
| ---------- | ----------------------- | --------------------------- |
| Horizontal | Loop per catalog config | Iterated in devCenter.bicep |

**Health (Platform-Managed):**

| Probe Type          | Configuration         | Source                 |
| ------------------- | --------------------- | ---------------------- |
| Catalog Sync Status | DevCenter sync health | Azure DevCenter Portal |

#### 5.5.6 Environment Type Management

See Section 2.5. Creates named environment types on DevCenter.

| Attribute          | Value                                        |
| ------------------ | -------------------------------------------- |
| **Component Name** | Environment Type Management                  |
| **Service Type**   | Configuration                                |
| **Source**         | src/workload/core/environmentType.bicep:1-36 |
| **Confidence**     | 0.88                                         |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                        |
| ------------- | ----- | ------------ | ------------------------------------------------------------------ |
| ARM Resource  | 1     | ARM REST API | Microsoft.DevCenter/devcenters/environmentTypes@2026-01-01-preview |
| Bicep Outputs | 2     | Bicep        | environmentTypeName, environmentTypeId                             |

**Dependencies:**

| Dependency | Direction | Protocol           | Purpose         |
| ---------- | --------- | ------------------ | --------------- |
| DevCenter  | Upstream  | Resource Reference | Parent resource |

**Resilience (Platform-Managed):**

| Aspect      | Configuration | Notes                                           |
| ----------- | ------------- | ----------------------------------------------- |
| Idempotency | Name-based    | Environment type names are unique per DevCenter |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                  | Configuration              |
| ---------- | ------------------------- | -------------------------- |
| Horizontal | Loop per environment type | Supports dev, staging, UAT |

**Health (Platform-Managed):**

| Probe Type            | Configuration      | Source       |
| --------------------- | ------------------ | ------------ |
| ARM Deployment Status | Provisioning state | Azure Portal |

#### 5.5.7 Project Catalog Registration

See Section 2.5. Registers project-level catalogs for environment and image
definitions.

| Attribute          | Value                                          |
| ------------------ | ---------------------------------------------- |
| **Component Name** | Project Catalog Registration                   |
| **Service Type**   | Configuration                                  |
| **Source**         | src/workload/project/projectCatalog.bicep:1-59 |
| **Confidence**     | 0.88                                           |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                              |
| ------------- | ----- | ------------ | -------------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.DevCenter/projects/catalogs@2026-01-01-preview |

**Dependencies:**

| Dependency        | Direction | Protocol           | Purpose                     |
| ----------------- | --------- | ------------------ | --------------------------- |
| Project           | Upstream  | Resource Reference | Parent project              |
| Secret Identifier | Upstream  | Secure Parameter   | Private repo authentication |

**Resilience (Platform-Managed):**

| Aspect    | Configuration | Notes                     |
| --------- | ------------- | ------------------------- |
| Sync Type | Scheduled     | Automatic synchronization |

**Scaling (Platform-Managed):**

| Dimension  | Strategy         | Configuration             |
| ---------- | ---------------- | ------------------------- |
| Horizontal | Loop per catalog | Iterated in project.bicep |

**Health (Platform-Managed):**

| Probe Type          | Configuration              | Source                 |
| ------------------- | -------------------------- | ---------------------- |
| Catalog Sync Status | Project-scoped sync health | Azure DevCenter Portal |

#### 5.5.8 Project Environment Provisioning

See Section 2.5. Creates project-scoped environment types with SystemAssigned
identity.

| Attribute          | Value                                                  |
| ------------------ | ------------------------------------------------------ |
| **Component Name** | Project Environment Provisioning                       |
| **Service Type**   | Configuration                                          |
| **Source**         | src/workload/project/projectEnvironmentType.bicep:1-50 |
| **Confidence**     | 0.88                                                   |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                                                      |
| ------------- | ----- | ------------ | ---------------------------------------------------------------- |
| ARM Resource  | 1     | ARM REST API | Microsoft.DevCenter/projects/environmentTypes@2026-01-01-preview |
| Bicep Outputs | 1     | Bicep        | environmentTypeName                                              |

**Dependencies:**

| Dependency   | Direction | Protocol           | Purpose           |
| ------------ | --------- | ------------------ | ----------------- |
| Project      | Upstream  | Resource Reference | Parent project    |
| Subscription | Upstream  | Resource ID        | Deployment target |

**Resilience (Platform-Managed):**

| Aspect       | Configuration          | Notes                                 |
| ------------ | ---------------------- | ------------------------------------- |
| Identity     | SystemAssigned         | Auto-provisioned managed identity     |
| Creator Role | Contributor (b24988ac) | Default role for environment creators |

**Scaling (Platform-Managed):**

| Dimension  | Strategy                  | Configuration             |
| ---------- | ------------------------- | ------------------------- |
| Horizontal | Loop per environment type | Iterated in project.bicep |

**Health (Platform-Managed):**

| Probe Type            | Configuration      | Source       |
| --------------------- | ------------------ | ------------ |
| ARM Deployment Status | Provisioning state | Azure Portal |

### 5.6 Application Interactions

#### 5.6.1 Bicep Module Invocation

| Attribute          | Value                   |
| ------------------ | ----------------------- |
| **Component Name** | Bicep Module Invocation |
| **Service Type**   | Module Reference        |
| **Source**         | infra/main.bicep:89-168 |
| **Confidence**     | 0.88                    |

**API Surface:**

| Endpoint Type | Count | Protocol               | Description                                   |
| ------------- | ----- | ---------------------- | --------------------------------------------- |
| Module Calls  | 3     | Bicep Module Reference | monitoring, security, workload modules        |
| Output Chains | 8     | Bicep Output           | Parameters passed between modules via outputs |

**Dependencies:**

| Dependency           | Direction  | Protocol         | Purpose                     |
| -------------------- | ---------- | ---------------- | --------------------------- |
| All 23 Bicep modules | Downstream | Module Reference | Full module dependency tree |

**Resilience (Platform-Managed):**

| Aspect              | Configuration               | Notes                          |
| ------------------- | --------------------------- | ------------------------------ |
| Dependency Ordering | dependsOn + output chaining | Enforced sequential deployment |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration           |
| ---------- | -------------- | ----------------------- |
| Horizontal | Not applicable | Single deployment graph |

**Health (Platform-Managed):**

| Probe Type            | Configuration                 | Source       |
| --------------------- | ----------------------------- | ------------ |
| ARM Deployment Status | Per-module provisioning state | Azure Portal |

#### 5.6.2 ARM API Deployment

| Attribute          | Value                                     |
| ------------------ | ----------------------------------------- |
| **Component Name** | ARM API Deployment                        |
| **Service Type**   | Request/Response                          |
| **Source**         | src/workload/core/devCenter.bicep:159-176 |
| **Confidence**     | 0.85                                      |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                   |
| ------------- | ----- | ------------ | ----------------------------- |
| REST Calls    | 14+   | ARM REST API | All resource type deployments |

**Dependencies:**

| Dependency             | Direction | Protocol | Purpose           |
| ---------------------- | --------- | -------- | ----------------- |
| Azure Resource Manager | Upstream  | REST API | Deployment engine |

**Resilience (Platform-Managed):**

| Aspect       | Configuration    | Notes                                    |
| ------------ | ---------------- | ---------------------------------------- |
| Retry Policy | ARM SDK defaults | Automatic retry with exponential backoff |

**Scaling (Platform-Managed):**

| Dimension  | Strategy              | Configuration               |
| ---------- | --------------------- | --------------------------- |
| Horizontal | ARM throttling limits | Per-subscription API limits |

**Health (Platform-Managed):**

| Probe Type         | Configuration          | Source           |
| ------------------ | ---------------------- | ---------------- |
| ARM Service Health | Azure Status Dashboard | Platform-managed |

### 5.7 Application Events

#### 5.7.1 DevCenter Diagnostic Streaming

| Attribute          | Value                                     |
| ------------------ | ----------------------------------------- |
| **Component Name** | DevCenter Diagnostic Streaming            |
| **Service Type**   | Diagnostic Event                          |
| **Source**         | src/workload/core/devCenter.bicep:178-199 |
| **Confidence**     | 0.88                                      |

**API Surface:**

| Endpoint Type     | Count | Protocol         | Description                                              |
| ----------------- | ----- | ---------------- | -------------------------------------------------------- |
| ARM Resource      | 1     | ARM REST API     | Microsoft.Insights/diagnosticSettings@2021-05-01-preview |
| Log Categories    | 1     | AzureDiagnostics | allLogs category group                                   |
| Metric Categories | 1     | AzureDiagnostics | AllMetrics category                                      |

**Dependencies:**

| Dependency              | Direction  | Protocol       | Purpose                   |
| ----------------------- | ---------- | -------------- | ------------------------- |
| DevCenter               | Upstream   | Resource Scope | Source of diagnostic data |
| Log Analytics Workspace | Downstream | Resource ID    | Telemetry destination     |

**Resilience (Platform-Managed):**

| Aspect   | Configuration    | Notes                     |
| -------- | ---------------- | ------------------------- |
| Delivery | AzureDiagnostics | Platform-managed delivery |

**Scaling (Platform-Managed):**

| Dimension  | Strategy          | Configuration                   |
| ---------- | ----------------- | ------------------------------- |
| Horizontal | PaaS auto-scaling | Log Analytics ingestion scaling |

**Health (Platform-Managed):**

| Probe Type                 | Configuration    | Source        |
| -------------------------- | ---------------- | ------------- |
| Diagnostic Settings Health | Platform-managed | Azure Monitor |

See Section 2.7 for the remaining diagnostic event entries (Key Vault, VNet, Log
Analytics self-diagnostics). All follow the same pattern with allLogs and
AllMetrics categories streamed to the centralized Log Analytics workspace.

### 5.8 Application Data Objects

#### 5.8.1 DevCenterConfig

| Attribute          | Value                                   |
| ------------------ | --------------------------------------- |
| **Component Name** | DevCenterConfig                         |
| **Service Type**   | Type Definition                         |
| **Source**         | src/workload/core/devCenter.bicep:30-65 |
| **Confidence**     | 0.91                                    |

**API Surface:**

| Endpoint Type   | Count | Protocol   | Description                                                                                                                 |
| --------------- | ----- | ---------- | --------------------------------------------------------------------------------------------------------------------------- |
| Type Properties | 6     | Bicep Type | name, identity, catalogItemSyncEnableStatus, microsoftHostedNetworkEnableStatus, installAzureMonitorAgentEnableStatus, tags |

**Dependencies:**

| Dependency     | Direction  | Protocol       | Purpose                |
| -------------- | ---------- | -------------- | ---------------------- |
| devcenter.yaml | Upstream   | YAML Config    | Configuration source   |
| Identity Type  | Downstream | Type Reference | Nested type definition |
| Tags Type      | Downstream | Type Reference | Nested type definition |

**Resilience (Platform-Managed):**

| Aspect            | Configuration | Notes                               |
| ----------------- | ------------- | ----------------------------------- |
| Schema Validation | JSON Schema   | Validated via devcenter.schema.json |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration          |
| ---------- | -------------- | ---------------------- |
| Horizontal | Not applicable | Static type definition |

**Health (Platform-Managed):**

| Probe Type              | Configuration  | Source                  |
| ----------------------- | -------------- | ----------------------- |
| Compile-Time Validation | Bicep compiler | Type safety enforcement |

See Section 2.8 for the remaining data object entries (KeyVaultSettings,
NetworkSettings, ProjectNetwork, PoolConfig). All follow typed Bicep parameter
patterns with compile-time validation.

### 5.9 Integration Patterns

#### 5.9.1 Configuration-as-Code

| Attribute          | Value                             |
| ------------------ | --------------------------------- |
| **Component Name** | Configuration-as-Code             |
| **Service Type**   | Config Integration                |
| **Source**         | src/workload/workload.bicep:41-42 |
| **Confidence**     | 0.94                              |

**Pattern Type**: Configuration-Driven Deployment

**Protocol**: YAML → JSON Schema validation → Bicep loadYamlContent() → ARM API

**Data Contract**: Three YAML configuration files validated against JSON Schema
draft-07. Schema enforces GUID patterns, CIDR blocks, enum values, string length
constraints, and required tag fields.

**Error Handling**: JSON Schema validation failures block Bicep compilation.
Invalid YAML structure prevents loadYamlContent() from parsing. ARM deployment
fails with descriptive errors if schema-compliant but semantically invalid
values are provided.

#### 5.9.2 Module Composition

| Attribute          | Value                   |
| ------------------ | ----------------------- |
| **Component Name** | Module Composition      |
| **Service Type**   | Orchestration Pattern   |
| **Source**         | infra/main.bicep:89-168 |
| **Confidence**     | 0.94                    |

**Pattern Type**: Hierarchical Module Orchestration

**Protocol**: Bicep module references with output chaining and explicit
dependsOn

**Data Contract**: Each module declares typed parameters and typed outputs.
Output values from upstream modules are passed as parameter inputs to downstream
modules. Type safety is enforced at compile time.

**Error Handling**: Missing parameters fail Bicep compilation. Module deployment
failures cascade through dependsOn ordering, preventing downstream modules from
executing. ARM provides per-module deployment status and error messages.

### 5.10 Service Contracts

#### 5.10.1 DevCenter Configuration Schema

| Attribute          | Value                                            |
| ------------------ | ------------------------------------------------ |
| **Component Name** | DevCenter Configuration Schema                   |
| **Service Type**   | JSON Schema                                      |
| **Source**         | infra/settings/workload/devcenter.schema.json:\* |
| **Confidence**     | 0.94                                             |

**Contract Scope**: Validates DevCenter name, identity configuration, catalogs,
environment types, projects, pools, network settings, and RBAC role assignments.

**Versioning**: JSON Schema draft-07 with no explicit version field.

**Breaking Change Policy**: Schema changes require corresponding YAML
configuration updates. Additive properties with defaults are non-breaking.
Removal of required properties or enum values constitutes a breaking change.

#### 5.10.2 Security Configuration Schema

| Attribute          | Value                                           |
| ------------------ | ----------------------------------------------- |
| **Component Name** | Security Configuration Schema                   |
| **Service Type**   | JSON Schema                                     |
| **Source**         | infra/settings/security/security.schema.json:\* |
| **Confidence**     | 0.94                                            |

**Contract Scope**: Validates Key Vault name (3-24 chars, alphanumeric with
hyphens), soft delete retention (7-90 days), purge protection, and RBAC
authorization settings.

**Versioning**: JSON Schema draft-07.

#### 5.10.3 Resource Organization Schema

| Attribute          | Value                                                             |
| ------------------ | ----------------------------------------------------------------- |
| **Component Name** | Resource Organization Schema                                      |
| **Service Type**   | JSON Schema                                                       |
| **Source**         | infra/settings/resourceOrganization/azureResources.schema.json:\* |
| **Confidence**     | 0.94                                                              |

**Contract Scope**: Validates resource group names (1-90 chars), create flags,
and required tag fields (environment, division, team, project, costCenter,
owner, landingZone, resources).

**Versioning**: JSON Schema draft-07.

### 5.11 Application Dependencies

#### 5.11.1 Azure Developer CLI

| Attribute          | Value               |
| ------------------ | ------------------- |
| **Component Name** | Azure Developer CLI |
| **Service Type**   | CLI Framework       |
| **Source**         | azure.yaml:1-38     |
| **Confidence**     | 0.94                |

**API Surface:**

| Endpoint Type | Count | Protocol     | Description                         |
| ------------- | ----- | ------------ | ----------------------------------- |
| Hooks         | 1     | Shell Script | preprovision hook running setUp.sh  |
| Commands      | 3     | CLI          | azd provision, azd deploy, azd down |

**Dependencies:**

| Dependency           | Direction  | Protocol | Purpose                   |
| -------------------- | ---------- | -------- | ------------------------- |
| Azure CLI            | Upstream   | CLI      | Azure authentication      |
| setUp.sh / setUp.ps1 | Downstream | Shell    | Pre-provision validation  |
| infra/main.bicep     | Downstream | IaC      | Infrastructure deployment |

**Resilience (Platform-Managed):**

| Aspect        | Configuration          | Notes                              |
| ------------- | ---------------------- | ---------------------------------- |
| Pre-provision | continueOnError: false | Blocks deployment on setup failure |
| Interactive   | true                   | Requires user confirmation         |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration          |
| ---------- | -------------- | ---------------------- |
| Horizontal | Not applicable | Single deployment tool |

**Health (Platform-Managed):**

| Probe Type | Configuration        | Source          |
| ---------- | -------------------- | --------------- |
| azd Status | Deployment lifecycle | Terminal output |

#### 5.11.2 Hugo Documentation Framework

| Attribute          | Value                        |
| ------------------ | ---------------------------- |
| **Component Name** | Hugo Documentation Framework |
| **Service Type**   | Documentation                |
| **Source**         | package.json:1-50            |
| **Confidence**     | 0.82                         |

**API Surface:**

| Endpoint Type | Count | Protocol | Description                              |
| ------------- | ----- | -------- | ---------------------------------------- |
| npm Scripts   | 15    | npm      | build, serve, check:links, clean, update |

**Dependencies:**

| Dependency            | Direction | Protocol | Purpose               |
| --------------------- | --------- | -------- | --------------------- |
| hugo-extended 0.136.2 | Upstream  | npm      | Static site generator |
| autoprefixer 10.x     | Upstream  | npm      | CSS post-processing   |
| postcss-cli 11.x      | Upstream  | npm      | CSS pipeline          |

**Resilience (Platform-Managed):**

| Aspect        | Configuration        | Notes                 |
| ------------- | -------------------- | --------------------- |
| Link Checking | htmltest integration | Post-build validation |

**Scaling (Platform-Managed):**

| Dimension  | Strategy       | Configuration    |
| ---------- | -------------- | ---------------- |
| Horizontal | Not applicable | Local build tool |

**Health (Platform-Managed):**

| Probe Type   | Configuration | Source          |
| ------------ | ------------- | --------------- |
| Build Status | npm run build | Terminal output |

### Summary

The Component Catalog documents 29 components across all 11 TOGAF Application
Architecture types. The dominant service type is PaaS (Azure-managed resources),
with all resilience, scaling, and health attributes governed by the Azure
platform. The four Application Services (Main Orchestrator, DevCenter Core,
Workload Service, Security Service) coordinate the deployment of seven
Application Components and eight Application Functions through a well-defined
Bicep module composition pattern.

Source traceability is maintained for every component with file path and
line-range references. All confidence scores exceed the 0.7 threshold, with the
highest scores (0.97) assigned to core infrastructure components (Key Vault, Log
Analytics, Network Connection, Project, Project Pool) that exhibit strong
filename, path, content, and cross-reference signals.

---

## Section 8: Dependencies & Integration

### Overview

This section documents all inter-module dependencies, data flows, and
integration patterns within the DevExp-DevBox platform. The architecture follows
a hierarchical module composition pattern where the subscription-scoped
orchestrator delegates to domain-specific modules in a strict sequential order.
Cross-cutting dependencies include diagnostic telemetry streaming, RBAC identity
assignment chains, and configuration loading from YAML files.

#### Module Dependency Graph

```mermaid
---
title: Module Dependency Call Graph
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
    accTitle: Module Dependency Call Graph
    accDescr: Shows the complete Bicep module dependency chain from the main orchestrator through monitoring, security, and workload domains with all downstream module references

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

    MAIN("📦 main.bicep"):::core

    MAIN -->|"scope: monitoringRG"| MON("📊 logAnalytics.bicep"):::data
    MAIN -->|"scope: securityRG"| SECMOD("🔒 security.bicep"):::core
    MAIN -->|"scope: workloadRG"| WLMOD("⚙️ workload.bicep"):::core

    SECMOD --> KV("🔑 keyVault.bicep"):::data
    SECMOD --> SECRET("🔐 secret.bicep"):::data

    WLMOD --> DCMOD("🏗️ devCenter.bicep"):::core
    WLMOD --> PROJMOD("📁 project.bicep"):::core

    DCMOD --> CATMOD("📚 catalog.bicep"):::neutral
    DCMOD --> ETMOD("🏷️ environmentType.bicep"):::neutral
    DCMOD --> DCRA("🛡️ devCenterRoleAssignment"):::neutral
    DCMOD --> ORA("🛡️ orgRoleAssignment"):::neutral

    PROJMOD --> PCMOD("📚 projectCatalog.bicep"):::neutral
    PROJMOD --> PETMOD("🏷️ projectEnvType.bicep"):::neutral
    PROJMOD --> POOLMOD("🖥️ projectPool.bicep"):::neutral
    PROJMOD --> CONNMOD("🌐 connectivity.bicep"):::neutral
    PROJMOD --> PIRA("🛡️ projectIdentityRBAC"):::neutral

    CONNMOD --> VNET("🔌 vnet.bicep"):::neutral
    CONNMOD --> NETCONN("🔌 networkConnection.bicep"):::neutral

    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
```

#### Service-to-Service Call Graph

| Source Module                      | Target Module                                     | Protocol         | Data Exchanged                                                       | Direction  |
| ---------------------------------- | ------------------------------------------------- | ---------------- | -------------------------------------------------------------------- | ---------- |
| infra/main.bicep                   | src/management/logAnalytics.bicep                 | Module Reference | name parameter                                                       | Downstream |
| infra/main.bicep                   | src/security/security.bicep                       | Module Reference | secretValue, logAnalyticsId, tags                                    | Downstream |
| infra/main.bicep                   | src/workload/workload.bicep                       | Module Reference | logAnalyticsId, secretIdentifier, securityResourceGroupName          | Downstream |
| src/security/security.bicep        | src/security/keyVault.bicep                       | Module Reference | tags, keyvaultSettings                                               | Downstream |
| src/security/security.bicep        | src/security/secret.bicep                         | Module Reference | name, keyVaultName, logAnalyticsId, secretValue                      | Downstream |
| src/workload/workload.bicep        | src/workload/core/devCenter.bicep                 | Module Reference | config, catalogs, environmentTypes, logAnalyticsId, secretIdentifier | Downstream |
| src/workload/workload.bicep        | src/workload/project/project.bicep                | Module Reference | name, devCenterName, catalogs, pools, network, identity              | Downstream |
| src/workload/core/devCenter.bicep  | src/identity/devCenterRoleAssignment.bicep        | Module Reference | id, principalId, scope                                               | Downstream |
| src/workload/core/devCenter.bicep  | src/identity/orgRoleAssignment.bicep              | Module Reference | principalId, roles                                                   | Downstream |
| src/workload/core/devCenter.bicep  | src/workload/core/catalog.bicep                   | Module Reference | devCenterName, catalogConfig, secretIdentifier                       | Downstream |
| src/workload/core/devCenter.bicep  | src/workload/core/environmentType.bicep           | Module Reference | devCenterName, environmentConfig                                     | Downstream |
| src/workload/project/project.bicep | src/identity/projectIdentityRoleAssignment.bicep  | Module Reference | projectName, principalId, roles                                      | Downstream |
| src/workload/project/project.bicep | src/workload/project/projectCatalog.bicep         | Module Reference | projectName, catalogConfig, secretIdentifier                         | Downstream |
| src/workload/project/project.bicep | src/workload/project/projectEnvironmentType.bicep | Module Reference | projectName, environmentConfig                                       | Downstream |
| src/workload/project/project.bicep | src/connectivity/connectivity.bicep               | Module Reference | devCenterName, projectNetwork, logAnalyticsId                        | Downstream |
| src/workload/project/project.bicep | src/workload/project/projectPool.bicep            | Module Reference | name, projectName, catalogs, vmSku, networkConnectionName            | Downstream |

#### Data Flow Diagram

```mermaid
---
title: Configuration-to-Deployment Data Flow
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
    accTitle: Configuration to Deployment Data Flow Diagram
    accDescr: Shows data flow from YAML configuration files through JSON Schema validation and Bicep compilation to Azure Resource Manager deployment with output chaining between modules

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

    subgraph configInput["Configuration Input"]
        YAML1("📄 devcenter.yaml"):::data
        YAML2("📄 security.yaml"):::data
        YAML3("📄 azureResources.yaml"):::data
    end

    subgraph validation["Schema Validation"]
        SCH1("📋 devcenter.schema.json"):::neutral
        SCH2("📋 security.schema.json"):::neutral
        SCH3("📋 azureResources.schema.json"):::neutral
    end

    subgraph compilation["Bicep Compilation"]
        LOAD("⚙️ loadYamlContent"):::core
        BICEP("⚙️ Bicep Compiler"):::core
    end

    subgraph deployment["Azure Deployment"]
        ARM("☁️ ARM Template"):::core
        DEPLOY("☁️ Resource Provisioning"):::core
    end

    YAML1 --> SCH1
    YAML2 --> SCH2
    YAML3 --> SCH3
    SCH1 --> LOAD
    SCH2 --> LOAD
    SCH3 --> LOAD
    LOAD --> BICEP
    BICEP --> ARM
    ARM --> DEPLOY

    style configInput fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style validation fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style compilation fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style deployment fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
```

#### External Dependency Table

| External System        | Protocol    | Purpose                        | Components Using It                       |
| ---------------------- | ----------- | ------------------------------ | ----------------------------------------- |
| Azure Resource Manager | REST API    | All resource provisioning      | All 23 Bicep modules                      |
| Microsoft Entra ID     | OAuth/OIDC  | Authentication, Azure AD Join  | Network Connection, RBAC modules          |
| GitHub Repositories    | HTTPS (Git) | Catalog source synchronization | Catalog, Project Catalog modules          |
| Azure DevOps Git       | HTTPS (Git) | Alternative catalog source     | Catalog, Project Catalog modules          |
| Azure Monitor          | REST API    | Diagnostic telemetry ingestion | DevCenter, Key Vault, VNet, Log Analytics |

#### Event Subscription Map

| Event Source    | Event Type            | Destination                    | Configuration                            |
| --------------- | --------------------- | ------------------------------ | ---------------------------------------- |
| DevCenter       | allLogs, AllMetrics   | Log Analytics Workspace        | AzureDiagnostics via diagnostic settings |
| Key Vault       | allLogs, AllMetrics   | Log Analytics Workspace        | AzureDiagnostics via diagnostic settings |
| Virtual Network | allLogs, AllMetrics   | Log Analytics Workspace        | Direct via diagnostic settings           |
| Log Analytics   | allLogs, AllMetrics   | Log Analytics Workspace (self) | Self-referencing diagnostic settings     |
| Catalog Sync    | Scheduled sync events | DevCenter                      | Built-in DevCenter sync                  |

#### Output Chaining Map

| Producing Module   | Output Name                       | Consuming Module                       | Consumed As                     |
| ------------------ | --------------------------------- | -------------------------------------- | ------------------------------- |
| logAnalytics.bicep | AZURE_LOG_ANALYTICS_WORKSPACE_ID  | main.bicep → security, workload        | logAnalyticsId parameter        |
| security.bicep     | AZURE_KEY_VAULT_SECRET_IDENTIFIER | main.bicep → workload                  | secretIdentifier parameter      |
| security.bicep     | AZURE_KEY_VAULT_NAME              | main.bicep (output)                    | Direct output                   |
| devCenter.bicep    | AZURE_DEV_CENTER_NAME             | workload.bicep → project               | devCenterName parameter         |
| project.bicep      | AZURE_PROJECT_NAME                | workload.bicep (output array)          | Array aggregation               |
| connectivity.bicep | networkConnectionName             | project.bicep → projectPool            | networkConnectionName parameter |
| connectivity.bicep | networkType                       | project.bicep → projectPool            | networkType parameter           |
| vnet.bicep         | AZURE_VIRTUAL_NETWORK             | connectivity.bicep → networkConnection | subnetId extraction             |

### Summary

The DevExp-DevBox platform implements a deep module dependency tree with 16
service-to-service module reference calls and 8 output-chaining relationships.
The dependency flow is strictly sequential: Monitoring → Security → Workload →
DevCenter → Projects → Pools, enforced through Bicep `dependsOn` declarations
and output parameter passing.

All cross-cutting concerns (diagnostic telemetry, RBAC assignments,
configuration loading) are centralized into reusable modules. Five external
systems are integrated via standard protocols: Azure Resource Manager (REST),
Microsoft Entra ID (OAuth/OIDC), GitHub (HTTPS/Git), Azure DevOps (HTTPS/Git),
and Azure Monitor (REST). The Configuration-as-Code integration pattern ensures
that all deployment-time decisions are declarative, schema-validated, and
version-controlled through the three YAML configuration files and their
companion JSON Schemas.
