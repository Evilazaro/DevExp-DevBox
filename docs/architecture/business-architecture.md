# Business Architecture — DevExp-DevBox

| Field                  | Value                                    |
| ---------------------- | ---------------------------------------- |
| **Layer**              | Business                                 |
| **Quality Level**      | comprehensive                            |
| **Framework**          | TOGAF 10 / BDAT                          |
| **Repository**         | Evilazaro/DevExp-DevBox                  |
| **Components Found**   | 25                                       |
| **Average Confidence** | 0.82                                     |
| **Diagrams Included**  | 3                                        |
| **Sections Generated** | 1, 2, 3, 4, 5, 8                         |
| **Generated**          | 2026-03-12T10:27:00Z                     |

---

## 1. Executive Summary

### Overview

The DevExp-DevBox repository implements an **Azure Dev Box Adoption & Deployment Accelerator** that enables platform engineering teams to deliver self-service developer workstations at enterprise scale. This Business Architecture analysis examines the strategic capabilities, value streams, business processes, and governance structures documented across the repository's configuration-driven Infrastructure-as-Code model.

The analysis identifies 25 Business layer components spanning 9 of the 11 canonical TOGAF Business Architecture component types. The repository's declarative YAML configuration model, validated by JSON Schemas, externalizes all business-level settings from infrastructure code — enabling repeatable, auditable provisioning aligned with Azure Landing Zone principles and the Cloud Adoption Framework.

- **Business Strategy**: 1 (Developer Experience Platform Strategy)
- **Business Capabilities**: 5 (Developer Workstation Provisioning, Identity & Access Management, Secrets Management, Centralized Monitoring, Network Isolation)
- **Value Streams**: 1 (Developer Onboarding & Self-Service)
- **Business Processes**: 3 (Environment Provisioning, Change Management, Cleanup & Decommissioning)
- **Business Services**: 3 (Dev Box Pool Service, Catalog Sync Service, Environment Type Service)
- **Business Functions**: 2 (Platform Engineering, Project Delivery)
- **Business Roles & Actors**: 4 (Platform Engineering Team, eShop Developers, Dev Manager, Dev Box User)
- **Business Rules**: 4 (Tagging Policy, RBAC Least Privilege, Naming Convention, Schema Validation)
- **Business Events**: 2 (Provisioning Trigger, Configuration Change)
- **Business Objects/Entities**: Not detected
- **KPIs & Metrics**: Not detected
- **Average Confidence**: 0.82

---

## 2. Architecture Landscape

### Overview

This section provides an inventory of all Business layer components detected in the DevExp-DevBox repository, organized by the 11 canonical TOGAF Business Architecture component types. Each component is listed with its source file, confidence score, and maturity level.

The repository's business architecture is centered on a configuration-driven platform engineering model where YAML files define business-level settings (teams, projects, roles, environments) and Bicep modules implement infrastructure delivery. Business intent is observable in configuration files, documentation, issue templates, and deployment scripts.

### 2.1 Business Strategy (1)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Developer Experience Platform Strategy | **Strategic initiative** to deliver self-service developer workstations at enterprise scale through configuration-driven IaC, enabling platform engineering teams to provision Azure Dev Box environments with built-in security, monitoring, and network isolation | README.md:12-22 | 0.88 | 3 - Defined |

### 2.2 Business Capabilities (5)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Developer Workstation Provisioning | **Core capability** for on-demand, role-specific developer machine provisioning with configurable VM SKUs and image definitions per project | infra/settings/workload/devcenter.yaml:139-147 | 0.92 | 4 - Measured |
| Identity & Access Management | **Core capability** for centralized Azure AD group-based RBAC with role assignments at subscription, resource group, and project scopes following least-privilege principles | infra/settings/workload/devcenter.yaml:28-60 | 0.90 | 4 - Measured |
| Secrets Management | **Core capability** for centralized credential storage with Key Vault RBAC authorization, purge protection, and soft delete | infra/settings/security/security.yaml:19-37 | 0.87 | 3 - Defined |
| Centralized Monitoring | **Supporting capability** for audit trail and diagnostic logging across all deployed resources via Log Analytics workspace | infra/settings/resourceOrganization/azureResources.yaml:48-62 | 0.81 | 3 - Defined |
| Network Isolation | **Supporting capability** for project-scoped virtual networks with subnet segmentation and Azure AD-joined network connections | infra/settings/workload/devcenter.yaml:90-108 | 0.85 | 3 - Defined |

### 2.3 Value Streams (1)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Developer Onboarding & Self-Service | **End-to-end value stream** from Azure AD group creation through YAML configuration to infrastructure provisioning and developer self-service access via Dev Center portal | README.md:186-207, infra/settings/workload/devcenter.yaml:85-170 | 0.80 | 3 - Defined |

### 2.4 Business Processes (3)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Environment Provisioning | **Core process** for deploying the full landing zone through `azd provision`, executing platform-appropriate setup scripts that validate prerequisites, authenticate, store tokens, and provision infrastructure | setUp.ps1:1-39, setUp.sh:1-43, README.md:186-207 | 0.88 | 4 - Measured |
| Change Management | **Governance process** defining Epic → Feature → Task hierarchy with required labels (type, area, priority, status), PR reviews, and documentation-as-code approach | CONTRIBUTING.md:1-150 | 0.85 | 3 - Defined |
| Cleanup & Decommissioning | **Lifecycle process** for removing subscription deployments, deleting users and role assignments, destroying credentials, removing GitHub secrets, and cleaning resource groups | cleanSetUp.ps1:1-10 | 0.78 | 2 - Repeatable |

### 2.5 Business Services (3)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Dev Box Pool Service | **Provisioning service** delivering role-specific developer workstations with configurable compute tiers (backend-engineer: 32-core, frontend-engineer: 16-core) | infra/settings/workload/devcenter.yaml:139-147 | 0.85 | 3 - Defined |
| Catalog Sync Service | **Configuration service** synchronizing Dev Box definitions and environment configurations from GitHub and Azure DevOps Git repositories | infra/settings/workload/devcenter.yaml:66-73, 159-170 | 0.82 | 3 - Defined |
| Environment Type Service | **SDLC service** managing deployment environments (dev, staging, UAT) with configurable deployment targets for each project | infra/settings/workload/devcenter.yaml:76-83 | 0.80 | 3 - Defined |

### 2.6 Business Functions (2)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Platform Engineering Function | **Organizational unit** responsible for Dev Center management, infrastructure provisioning, and governance enforcement across all projects | infra/settings/workload/devcenter.yaml:57-60, CONTRIBUTING.md:1-10 | 0.83 | 3 - Defined |
| Project Delivery Function | **Organizational unit** responsible for project-level Dev Box consumption, environment usage, and team-specific tooling requirements | infra/settings/workload/devcenter.yaml:85-170 | 0.78 | 2 - Repeatable |

### 2.7 Business Roles & Actors (4)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Platform Engineering Team | **Governance role** (Azure AD Group) with DevCenter Project Admin permissions for managing Dev Box deployments and project settings | infra/settings/workload/devcenter.yaml:55-63 | 0.90 | 4 - Measured |
| eShop Developers | **Consumer role** (Azure AD Group) with Dev Box User, Deployment Environment User, and Key Vault Secrets access for self-service workstation provisioning | infra/settings/workload/devcenter.yaml:110-137 | 0.90 | 4 - Measured |
| Dev Manager | **Administrative role** responsible for configuring Dev Box definitions without directly consuming Dev Boxes | infra/settings/workload/devcenter.yaml:54-63 | 0.85 | 3 - Defined |
| Dev Box User | **End-user role** with permissions to create and manage personal Dev Box instances within assigned projects | infra/settings/workload/devcenter.yaml:117-119 | 0.82 | 3 - Defined |

### 2.8 Business Rules (4)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Tagging Policy | **Governance rule** mandating standardized tags (environment, division, team, project, costCenter, owner, landingZone, resources) on all Azure resources for cost tracking and organizational alignment | infra/settings/resourceOrganization/azureResources.yaml:22-29 | 0.90 | 4 - Measured |
| RBAC Least Privilege | **Security rule** enforcing role assignments scoped to the minimum required level (Project, ResourceGroup, Subscription) following Azure best practices guidance | infra/settings/workload/devcenter.yaml:31-48 | 0.88 | 4 - Measured |
| Naming Convention | **Standards rule** requiring consistent resource naming with environment and location suffixes (e.g., `{name}-{env}-{location}-RG`) | infra/main.bicep:35-48 | 0.82 | 3 - Defined |
| Schema Validation | **Quality rule** enforcing JSON Schema validation on all YAML configuration files to prevent configuration drift and ensure structural correctness | infra/settings/workload/devcenter.yaml:1 | 0.80 | 3 - Defined |

### 2.9 Business Events (2)

| Name | Description | Source | Confidence | Maturity |
| ---- | ----------- | ------ | ---------- | -------- |
| Provisioning Trigger | **Lifecycle event** triggered by `azd provision` command that initiates the preprovision hook, executes setup scripts, and deploys the full landing zone | README.md:186-207, setUp.ps1:1-10 | 0.78 | 3 - Defined |
| Configuration Change | **Governance event** triggered by YAML configuration updates that flow through the PR-based change management process before infrastructure deployment | CONTRIBUTING.md:50-75, infra/settings/workload/devcenter.yaml:1-14 | 0.75 | 2 - Repeatable |

### 2.10 Business Objects/Entities (0)

**Status**: Not detected in analyzed files. The repository defines infrastructure resources and configuration models rather than canonical business domain entities (e.g., Customer, Order, Product). Business objects are implicit within the Dev Box provisioning domain but not explicitly modeled as standalone documents.

### 2.11 KPIs & Metrics (0)

**Status**: Not detected in analyzed files. While the repository emphasizes monitoring (Log Analytics, diagnostic settings), no explicit business KPI definitions, SLA targets, or performance dashboards were found in the source. CONTRIBUTING.md references "Exit metrics" for Epics but does not define specific measurable KPIs.

### Summary

The Architecture Landscape identifies 25 Business layer components across 9 of 11 canonical types, with strongest coverage in Business Capabilities (5), Business Roles & Actors (4), and Business Rules (4). Confidence scores range from 0.75 to 0.92, with an average of 0.82. Maturity assessments indicate Level 3 (Defined) as the dominant maturity, with Identity & Access Management and Developer Workstation Provisioning reaching Level 4 (Measured).

Two component types — Business Objects/Entities and KPIs & Metrics — were not detected. The repository focuses on infrastructure platform delivery rather than business domain modeling, which explains the absence of formal business entities. Adding explicit KPI definitions (e.g., provisioning time SLA, developer adoption rate) would strengthen the business architecture's measurability.

---

## 3. Architecture Principles

### Overview

The following architectural principles are observed in the DevExp-DevBox repository, derived from documented configuration patterns, code structure, and governance artifacts. These principles guide the design and evolution of the developer experience platform.

Each principle reflects an observable pattern in the source rather than a prescriptive recommendation, consistent with the anti-hallucination protocol requiring source traceability.

| # | Principle | Rationale | Source Evidence |
| - | --------- | --------- | --------------- |
| 1 | **Configuration-Driven Design** | All business-level settings are externalized in YAML configuration files validated by JSON Schemas, separating intent from implementation | infra/settings/workload/devcenter.yaml:1, infra/settings/security/security.yaml:1, infra/settings/resourceOrganization/azureResources.yaml:1 |
| 2 | **Landing Zone Alignment** | Resources are organized across dedicated resource groups (Workload, Security, Monitoring) following Azure Landing Zone and Cloud Adoption Framework principles | infra/settings/resourceOrganization/azureResources.yaml:16-62, README.md:50-60 |
| 3 | **Least-Privilege Access** | RBAC role assignments are scoped to the minimum required level (Project, ResourceGroup, Subscription) with Azure AD group-based identity governance | infra/settings/workload/devcenter.yaml:31-48, 110-137 |
| 4 | **Modular Composition** | Infrastructure is decomposed into independent, reusable Bicep modules with clear input/output contracts, enabling selective deployment and testing | src/workload/workload.bicep:1-10, infra/main.bicep:87-150 |
| 5 | **Governance by Default** | Standardized tagging, schema validation, and change management processes are enforced across all resources and workflows | infra/settings/resourceOrganization/azureResources.yaml:22-29, CONTRIBUTING.md:24-42 |
| 6 | **Cross-Platform Portability** | Setup and deployment scripts are provided for both PowerShell (Windows) and Bash (Linux/macOS), ensuring platform-agnostic adoption | setUp.ps1:1-10, setUp.sh:1-10, azure.yaml:1, azure-pwh.yaml:1 |
| 7 | **Idempotent Deployment** | All infrastructure provisioning is designed for safe re-execution, with `azd provision` and Bicep modules producing consistent results regardless of prior state | CONTRIBUTING.md:70-80, src/workload/workload.bicep:1-10 |

---

## 4. Current State Baseline

### Overview

This section captures the current maturity and structural characteristics of the Business Architecture as observed in the DevExp-DevBox repository. The analysis is based on configuration files, deployment scripts, documentation, and governance artifacts found in the specified folder paths.

The platform operates as a single-project deployment (eShop) with a well-defined capability model and role-based access structure. The business architecture demonstrates Level 3 (Defined) overall maturity with pockets of Level 4 (Measured) in identity management and workstation provisioning.

### Business Capability Heatmap

| Capability | Maturity Level | Evidence |
| ---------- | -------------- | -------- |
| Developer Workstation Provisioning | 4 - Measured | Role-specific VM SKUs, image definitions, pool configuration (infra/settings/workload/devcenter.yaml:139-147) |
| Identity & Access Management | 4 - Measured | Azure AD groups, scoped RBAC roles, managed identities (infra/settings/workload/devcenter.yaml:28-60) |
| Secrets Management | 3 - Defined | Key Vault with RBAC, purge protection, soft delete (infra/settings/security/security.yaml:19-37) |
| Centralized Monitoring | 3 - Defined | Log Analytics workspace, diagnostic settings (infra/settings/resourceOrganization/azureResources.yaml:48-62) |
| Network Isolation | 3 - Defined | Project-scoped VNets, subnet segmentation (infra/settings/workload/devcenter.yaml:90-108) |

### Business Architecture View

```mermaid
---
title: Business Capability Map — DevExp-DevBox
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
    accTitle: Business Capability Map — DevExp-DevBox
    accDescr: Shows the five core business capabilities of the DevExp-DevBox platform and their relationships to business functions and roles

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

    subgraph strategy["🎯 Developer Experience Platform Strategy"]
        direction TB
        strategyNode("📋 Self-Service Developer Workstations at Enterprise Scale"):::core
    end

    subgraph capabilities["🏢 Business Capabilities"]
        direction TB
        cap1("💻 Developer Workstation Provisioning"):::core
        cap2("🔑 Identity & Access Management"):::danger
        cap3("🔐 Secrets Management"):::danger
        cap4("📊 Centralized Monitoring"):::core
        cap5("🌐 Network Isolation"):::core
    end

    subgraph functions["⚙️ Business Functions"]
        direction TB
        func1("👥 Platform Engineering"):::success
        func2("📦 Project Delivery"):::success
    end

    subgraph roles["👤 Business Roles"]
        direction TB
        role1("🛡️ Platform Engineering Team"):::neutral
        role2("💻 eShop Developers"):::neutral
        role3("🔧 Dev Manager"):::neutral
        role4("👤 Dev Box User"):::neutral
    end

    strategyNode -->|"enables"| cap1
    strategyNode -->|"requires"| cap2
    strategyNode -->|"requires"| cap3
    strategyNode -->|"requires"| cap4
    strategyNode -->|"requires"| cap5
    func1 -->|"manages"| cap1
    func1 -->|"governs"| cap2
    func2 -->|"consumes"| cap1
    role1 -->|"operates"| func1
    role2 -->|"operates"| func2
    role3 -->|"configures"| func1
    role4 -->|"consumes"| cap1

    %% Centralized classDefs
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130

    style strategy fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style capabilities fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style functions fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style roles fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
```

### Summary

The current state baseline reveals a well-structured platform with Level 3-4 maturity across all five business capabilities. The strongest areas are Developer Workstation Provisioning and Identity & Access Management, both at Level 4 (Measured) with quantifiable configuration (VM SKUs, scoped RBAC roles). Secrets Management, Monitoring, and Network Isolation are at Level 3 (Defined) with standardized configurations but limited quantitative management.

The primary gap is the absence of explicit business KPIs and metrics for measuring platform adoption, provisioning latency, and cost efficiency. Adding measurable indicators would advance the overall business architecture from Level 3 to Level 4 maturity.

---

## 5. Component Catalog

### Overview

This section provides detailed specifications for each Business layer component identified in the Architecture Landscape. Components are organized by the 11 canonical TOGAF Business Architecture types, with each entry including purpose, capabilities, source traceability, confidence scoring, and maturity assessment.

The catalog serves as the authoritative reference for understanding the business intent behind the DevExp-DevBox platform's configuration-driven architecture. All component descriptions focus on business semantics rather than implementation details, consistent with the TOGAF Business Architecture scope.

### 5.1 Business Strategy

#### Developer Experience Platform Strategy

| Attribute | Value |
| --------- | ----- |
| **Name** | Developer Experience Platform Strategy |
| **Description** | Strategic initiative to deliver self-service developer workstations at enterprise scale through configuration-driven Infrastructure-as-Code, enabling platform engineering teams to provision Azure Dev Box environments with built-in security, monitoring, and network isolation |
| **Source** | README.md:12-22 |
| **Confidence** | 0.88 |
| **Maturity** | 3 - Defined |
| **Relationships** | Enables: Developer Workstation Provisioning, Identity & Access Management, Secrets Management, Centralized Monitoring, Network Isolation |

### 5.2 Business Capabilities

#### 5.2.1 Developer Workstation Provisioning

| Attribute | Value |
| --------- | ----- |
| **Name** | Developer Workstation Provisioning |
| **Description** | Core capability for on-demand, role-specific developer machine provisioning with configurable VM SKUs (backend-engineer: 32-core/128GB, frontend-engineer: 16-core/64GB) and custom image definitions delivered through Dev Box pools |
| **Source** | infra/settings/workload/devcenter.yaml:139-147 |
| **Confidence** | 0.92 |
| **Maturity** | 4 - Measured |
| **Relationships** | Delivered by: Dev Box Pool Service; Consumed by: eShop Developers, Dev Box User; Managed by: Platform Engineering Function |

#### 5.2.2 Identity & Access Management

| Attribute | Value |
| --------- | ----- |
| **Name** | Identity & Access Management |
| **Description** | Core capability for centralized Azure AD group-based RBAC with SystemAssigned managed identities and role assignments at subscription, resource group, and project scopes following documented least-privilege guidance |
| **Source** | infra/settings/workload/devcenter.yaml:28-60 |
| **Confidence** | 0.90 |
| **Maturity** | 4 - Measured |
| **Relationships** | Governs: All capabilities; Operated by: Platform Engineering Team; Consumed by: eShop Developers |

#### 5.2.3 Secrets Management

| Attribute | Value |
| --------- | ----- |
| **Name** | Secrets Management |
| **Description** | Core capability for centralized credential storage using Azure Key Vault with RBAC authorization, purge protection, soft delete (7-day retention), and support for GitHub Actions tokens and deployment credentials |
| **Source** | infra/settings/security/security.yaml:19-37 |
| **Confidence** | 0.87 |
| **Maturity** | 3 - Defined |
| **Relationships** | Stores: GitHub Access Token, Azure DevOps Token; Accessed by: eShop Developers (Key Vault Secrets User/Officer) |

#### 5.2.4 Centralized Monitoring

| Attribute | Value |
| --------- | ----- |
| **Name** | Centralized Monitoring |
| **Description** | Supporting capability providing audit trail and diagnostic logging across all deployed resources via a dedicated Log Analytics workspace with Azure Monitor agent installation enabled on all Dev Center resources |
| **Source** | infra/settings/resourceOrganization/azureResources.yaml:48-62 |
| **Confidence** | 0.81 |
| **Maturity** | 3 - Defined |
| **Relationships** | Monitors: Dev Center, Key Vault; Deployed to: devexp-monitoring resource group |

#### 5.2.5 Network Isolation

| Attribute | Value |
| --------- | ----- |
| **Name** | Network Isolation |
| **Description** | Supporting capability for project-scoped virtual networks with subnet segmentation (10.0.0.0/16 VNet, 10.0.1.0/24 subnet) and Azure AD-joined managed network connections attached to the Dev Center |
| **Source** | infra/settings/workload/devcenter.yaml:90-108 |
| **Confidence** | 0.85 |
| **Maturity** | 3 - Defined |
| **Relationships** | Provides: Network connectivity for Dev Box pools; Scoped to: eShop project; Type: Managed VNet |

### 5.3 Value Streams

#### Developer Onboarding & Self-Service

| Attribute | Value |
| --------- | ----- |
| **Name** | Developer Onboarding & Self-Service |
| **Description** | End-to-end value stream from Azure AD group creation through YAML configuration update, `azd provision` execution, RBAC role assignment, to developer self-service access via the Dev Center portal for VM provisioning from configured pools |
| **Source** | README.md:186-207, infra/settings/workload/devcenter.yaml:85-170 |
| **Confidence** | 0.80 |
| **Maturity** | 3 - Defined |
| **Relationships** | Triggers: Environment Provisioning process; Delivers: Self-service Dev Box access; Actors: Platform Engineering Team → eShop Developers |

### 5.4 Business Processes

#### 5.4.1 Environment Provisioning

| Attribute | Value |
| --------- | ----- |
| **Name** | Environment Provisioning |
| **Description** | Core automated process for deploying the full landing zone through `azd provision`, which triggers preprovision hooks executing platform-appropriate setup scripts that validate prerequisites, authenticate with Azure and source control platforms, securely store tokens, and provision all infrastructure resources |
| **Source** | setUp.ps1:1-39, setUp.sh:1-43, README.md:186-207 |
| **Confidence** | 0.88 |
| **Maturity** | 4 - Measured |
| **Relationships** | Triggered by: Provisioning Trigger event; Deploys: Monitoring → Security → Workload modules; Uses: Azure CLI, azd, GitHub CLI |

#### 5.4.2 Change Management

| Attribute | Value |
| --------- | ----- |
| **Name** | Change Management |
| **Description** | Governance process defining a product-oriented delivery model with Epic → Feature → Task hierarchy, required labels (type, area, priority, status), PR-based reviews with issue linking, and documentation-as-code updates in the same PR as infrastructure changes |
| **Source** | CONTRIBUTING.md:1-150 |
| **Confidence** | 0.85 |
| **Maturity** | 3 - Defined |
| **Relationships** | Triggers: Configuration Change event; Enforces: Engineering Standards, Validation Expectations, Definition of Done |

#### 5.4.3 Cleanup & Decommissioning

| Attribute | Value |
| --------- | ----- |
| **Name** | Cleanup & Decommissioning |
| **Description** | Lifecycle process for safely removing all provisioned resources including subscription deployments, user and role assignments, service principal credentials, GitHub secrets, and resource groups |
| **Source** | cleanSetUp.ps1:1-10 |
| **Confidence** | 0.78 |
| **Maturity** | 2 - Repeatable |
| **Relationships** | Reverses: Environment Provisioning process; Removes: RBAC assignments, Key Vault secrets, Resource Groups |

### 5.5 Business Services

#### 5.5.1 Dev Box Pool Service

| Attribute | Value |
| --------- | ----- |
| **Name** | Dev Box Pool Service |
| **Description** | Provisioning service delivering role-specific developer workstations through configured pools with distinct compute tiers: backend-engineer (general_i_32c128gb512ssd_v2) and frontend-engineer (general_i_16c64gb256ssd_v2), each with dedicated image definitions |
| **Source** | infra/settings/workload/devcenter.yaml:139-147 |
| **Confidence** | 0.85 |
| **Maturity** | 3 - Defined |
| **Relationships** | Delivers: Developer Workstation Provisioning capability; Consumed by: Dev Box User role |

#### 5.5.2 Catalog Sync Service

| Attribute | Value |
| --------- | ----- |
| **Name** | Catalog Sync Service |
| **Description** | Configuration service synchronizing Dev Center resource definitions from external Git repositories — supporting GitHub (public/private) and Azure DevOps Git catalogs with branch and path specifications for tasks, environments, and image definitions |
| **Source** | infra/settings/workload/devcenter.yaml:66-73, 159-170 |
| **Confidence** | 0.82 |
| **Maturity** | 3 - Defined |
| **Relationships** | Sources: microsoft/devcenter-catalog (GitHub), eShop environments and images; Scoped to: Dev Center and Project levels |

#### 5.5.3 Environment Type Service

| Attribute | Value |
| --------- | ----- |
| **Name** | Environment Type Service |
| **Description** | SDLC management service defining deployment environments (dev, staging, UAT) at both Dev Center and project levels with configurable deployment target subscriptions |
| **Source** | infra/settings/workload/devcenter.yaml:76-83 |
| **Confidence** | 0.80 |
| **Maturity** | 3 - Defined |
| **Relationships** | Enables: Multi-environment deployment; Consumed by: eShop project; Manages: dev, staging, UAT environments |

### 5.6 Business Functions

#### 5.6.1 Platform Engineering Function

| Attribute | Value |
| --------- | ----- |
| **Name** | Platform Engineering Function |
| **Description** | Organizational unit responsible for Dev Center management, infrastructure provisioning, governance enforcement, and maintaining the configuration-driven accelerator as a product-oriented platform |
| **Source** | infra/settings/workload/devcenter.yaml:57-60, CONTRIBUTING.md:1-10 |
| **Confidence** | 0.83 |
| **Maturity** | 3 - Defined |
| **Relationships** | Staffed by: Platform Engineering Team, Dev Manager; Manages: All 5 business capabilities; Operates: Change Management process |

#### 5.6.2 Project Delivery Function

| Attribute | Value |
| --------- | ----- |
| **Name** | Project Delivery Function |
| **Description** | Organizational unit responsible for project-level Dev Box consumption, environment usage, and team-specific tooling requirements — currently instantiated as the eShop project |
| **Source** | infra/settings/workload/devcenter.yaml:85-170 |
| **Confidence** | 0.78 |
| **Maturity** | 2 - Repeatable |
| **Relationships** | Staffed by: eShop Developers; Consumes: Developer Workstation Provisioning, Environment Type Service |

### 5.7 Business Roles & Actors

#### 5.7.1 Platform Engineering Team

| Attribute | Value |
| --------- | ----- |
| **Name** | Platform Engineering Team |
| **Description** | Azure AD group (ID: 5a1d1455-e771-4c19-aa03-fb4a08418f22) with DevCenter Project Admin role at ResourceGroup scope, responsible for managing Dev Box deployments and project settings |
| **Source** | infra/settings/workload/devcenter.yaml:55-63 |
| **Confidence** | 0.90 |
| **Maturity** | 4 - Measured |
| **Relationships** | Operates: Platform Engineering Function; Manages: Dev Center, Projects, Pools, Catalogs |

#### 5.7.2 eShop Developers

| Attribute | Value |
| --------- | ----- |
| **Name** | eShop Developers |
| **Description** | Azure AD group (ID: 9d42a792-2d74-441d-8bcb-71009371725f) with Contributor, Dev Box User, Deployment Environment User, Key Vault Secrets User, and Key Vault Secrets Officer roles scoped to Project and ResourceGroup levels |
| **Source** | infra/settings/workload/devcenter.yaml:110-137 |
| **Confidence** | 0.90 |
| **Maturity** | 4 - Measured |
| **Relationships** | Operates: Project Delivery Function; Consumes: Dev Box Pool Service, Environment Type Service |

#### 5.7.3 Dev Manager

| Attribute | Value |
| --------- | ----- |
| **Name** | Dev Manager |
| **Description** | Administrative role type for users who manage Dev Box deployments — can configure Dev Box definitions but typically do not consume Dev Boxes directly |
| **Source** | infra/settings/workload/devcenter.yaml:54-63 |
| **Confidence** | 0.85 |
| **Maturity** | 3 - Defined |
| **Relationships** | Belongs to: Platform Engineering Team; Configures: Platform Engineering Function |

#### 5.7.4 Dev Box User

| Attribute | Value |
| --------- | ----- |
| **Name** | Dev Box User |
| **Description** | End-user role with permissions to create and manage personal Dev Box instances within assigned projects, enabling self-service developer workstation provisioning |
| **Source** | infra/settings/workload/devcenter.yaml:117-119 |
| **Confidence** | 0.82 |
| **Maturity** | 3 - Defined |
| **Relationships** | Assigned to: eShop Developers group; Consumes: Developer Workstation Provisioning capability |

### 5.8 Business Rules

#### 5.8.1 Tagging Policy

| Attribute | Value |
| --------- | ----- |
| **Name** | Tagging Policy |
| **Description** | Governance rule mandating 8 standardized tags on all Azure resources: environment, division, team, project, costCenter, owner, landingZone, and resources — enabling cost allocation, ownership tracking, and landing zone classification |
| **Source** | infra/settings/resourceOrganization/azureResources.yaml:22-29 |
| **Confidence** | 0.90 |
| **Maturity** | 4 - Measured |
| **Relationships** | Enforced on: All resource groups and Azure resources; Defined in: azureResources.yaml, devcenter.yaml, security.yaml |

#### 5.8.2 RBAC Least Privilege

| Attribute | Value |
| --------- | ----- |
| **Name** | RBAC Least Privilege |
| **Description** | Security rule enforcing role assignments scoped to the minimum required level — Contributor and User Access Administrator at Subscription scope for Dev Center operations, Key Vault roles at ResourceGroup scope, and Dev Box User at Project scope |
| **Source** | infra/settings/workload/devcenter.yaml:31-48 |
| **Confidence** | 0.88 |
| **Maturity** | 4 - Measured |
| **Relationships** | Governs: Platform Engineering Team, eShop Developers; References: Azure RBAC built-in roles documentation |

#### 5.8.3 Naming Convention

| Attribute | Value |
| --------- | ----- |
| **Name** | Naming Convention |
| **Description** | Standards rule defining consistent resource naming with environment and location suffixes using the pattern `{resourceName}-{environmentName}-{location}-RG` for resource groups |
| **Source** | infra/main.bicep:35-48 |
| **Confidence** | 0.82 |
| **Maturity** | 3 - Defined |
| **Relationships** | Applied to: Resource group names (security, monitoring, workload); Enforced by: Bicep variable composition |

#### 5.8.4 Schema Validation

| Attribute | Value |
| --------- | ----- |
| **Name** | Schema Validation |
| **Description** | Quality rule enforcing JSON Schema validation on all YAML configuration files through `yaml-language-server` schema references, preventing configuration drift and ensuring structural correctness before deployment |
| **Source** | infra/settings/workload/devcenter.yaml:1 |
| **Confidence** | 0.80 |
| **Maturity** | 3 - Defined |
| **Relationships** | Validates: devcenter.yaml (devcenter.schema.json), security.yaml (security.schema.json), azureResources.yaml (azureResources.schema.json) |

### 5.9 Business Events

#### 5.9.1 Provisioning Trigger

| Attribute | Value |
| --------- | ----- |
| **Name** | Provisioning Trigger |
| **Description** | Lifecycle event initiated by the `azd provision` command that triggers a preprovision hook executing the platform-appropriate setup script — validating prerequisites, authenticating with Azure and source control, and deploying all infrastructure resources |
| **Source** | README.md:186-207, setUp.ps1:1-10 |
| **Confidence** | 0.78 |
| **Maturity** | 3 - Defined |
| **Relationships** | Triggers: Environment Provisioning process; Initiator: Platform Engineering Team or automated pipeline |

#### 5.9.2 Configuration Change

| Attribute | Value |
| --------- | ----- |
| **Name** | Configuration Change |
| **Description** | Governance event triggered when YAML configuration files are updated, flowing through the PR-based change management process with required issue linking, label application, and validation evidence before infrastructure deployment |
| **Source** | CONTRIBUTING.md:50-75, infra/settings/workload/devcenter.yaml:1-14 |
| **Confidence** | 0.75 |
| **Maturity** | 2 - Repeatable |
| **Relationships** | Triggers: Change Management process; Affects: All YAML configuration files; Governed by: CONTRIBUTING.md guidelines |

### 5.10 Business Objects/Entities (0)

**Status**: Not detected. The repository models infrastructure resources (Dev Center, Projects, Pools, VNets) rather than canonical business domain entities. Business objects are implicit within the developer experience domain but are not formalized as standalone documents or data models.

### 5.11 KPIs & Metrics (0)

**Status**: Not detected. While CONTRIBUTING.md references "Exit metrics" for Epics (line 142) and the repository tracks cost allocation through tagging, no explicit KPI definitions, SLA targets, or performance measurement frameworks were found. Inferred from CONTRIBUTING.md:142 — "Exit metrics met (or deviations documented)" suggests KPI awareness without formal definition.

### Summary

The Component Catalog documents 25 Business layer components with detailed specifications across 9 of 11 canonical types. The highest-confidence components are Developer Workstation Provisioning (0.92), Identity & Access Management (0.90), and the Tagging Policy (0.90). The Platform Engineering Team and eShop Developers roles demonstrate the strongest maturity at Level 4, reflecting their well-defined Azure AD group configurations with explicit RBAC assignments.

Gaps exist in Business Objects/Entities and KPIs & Metrics. The repository would benefit from formalizing business domain entities (Developer, Project, Pool as first-class business concepts) and defining measurable KPIs for platform adoption, provisioning time, and cost efficiency.

---

## 8. Dependencies & Integration

### Overview

This section maps the cross-component dependencies and integration patterns observed in the DevExp-DevBox Business Architecture. The platform follows a layered dependency model where monitoring is deployed first, followed by security, then workload resources — reflecting both technical dependencies and business priority sequencing.

Integration points span Azure services (Dev Center, Key Vault, Log Analytics, Virtual Networks), external source control platforms (GitHub, Azure DevOps), and identity providers (Azure Active Directory). The configuration-driven model creates a dependency chain from YAML configuration files through Bicep orchestration to deployed Azure resources.

### Dependency Matrix

| Source Component | Target Component | Relationship | Evidence |
| ---------------- | ---------------- | ------------ | -------- |
| Developer Workstation Provisioning | Identity & Access Management | **Requires** — Dev Box pools require RBAC role assignments for user access | infra/settings/workload/devcenter.yaml:110-137 |
| Developer Workstation Provisioning | Network Isolation | **Requires** — Dev Box pools connect to project-scoped VNets via network connections | infra/settings/workload/devcenter.yaml:90-108 |
| Developer Workstation Provisioning | Secrets Management | **Requires** — Dev Box image definitions reference secrets stored in Key Vault | infra/main.bicep:136-148 |
| Secrets Management | Centralized Monitoring | **Requires** — Key Vault diagnostic settings log to Log Analytics workspace | infra/main.bicep:124-132 |
| Dev Box Pool Service | Catalog Sync Service | **Depends on** — Pools reference image definitions synced from external catalogs | infra/settings/workload/devcenter.yaml:139-170 |
| Environment Provisioning | Change Management | **Governed by** — All provisioning changes flow through PR-based review process | CONTRIBUTING.md:50-75 |
| Platform Engineering Team | eShop Developers | **Administers** — Platform team configures projects consumed by developer team | infra/settings/workload/devcenter.yaml:55-63, 110-137 |

### Business Process Flow

```mermaid
---
title: Environment Provisioning Process Flow
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
    accTitle: Environment Provisioning Process Flow
    accDescr: Shows the end-to-end provisioning process from configuration through deployment to developer access, with role responsibilities

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

    subgraph configPhase["📋 Configuration Phase"]
        direction TB
        yamlConfig("📁 Update YAML Configuration"):::core
        schemaValidate("✅ JSON Schema Validation"):::success
        prReview("📝 PR Review & Approval"):::core
    end

    subgraph deployPhase["🚀 Deployment Phase"]
        direction TB
        azdProvision("🛠️ azd provision"):::core
        setupScript("⚙️ Setup Script Execution"):::core
        authStep("🔑 Azure & Source Control Auth"):::danger
    end

    subgraph infraPhase["🏗️ Infrastructure Phase"]
        direction TB
        monitoring("📊 Deploy Monitoring"):::core
        security("🔐 Deploy Security"):::danger
        workload("💻 Deploy Workload"):::core
    end

    subgraph accessPhase["👤 Access Phase"]
        direction TB
        rbacAssign("🔒 RBAC Assignment"):::danger
        devAccess("👤 Developer Self-Service"):::success
    end

    yamlConfig -->|"validates"| schemaValidate
    schemaValidate -->|"submits"| prReview
    prReview -->|"triggers"| azdProvision
    azdProvision -->|"executes"| setupScript
    setupScript -->|"authenticates"| authStep
    authStep -->|"deploys"| monitoring
    monitoring -->|"then"| security
    security -->|"then"| workload
    workload -->|"assigns"| rbacAssign
    rbacAssign -->|"enables"| devAccess

    %% Centralized classDefs
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130

    style configPhase fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style deployPhase fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style infraPhase fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style accessPhase fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
```

### Cross-Layer Integration Map

```mermaid
---
title: Cross-Layer Business Dependencies
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
    accTitle: Cross-Layer Business Dependencies
    accDescr: Shows how business capabilities depend on each other and integrate with external systems through configuration and identity patterns

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

    subgraph business["🏢 Business Layer"]
        direction TB
        provision("💻 Workstation Provisioning"):::core
        iam("🔑 Identity & Access"):::danger
        secrets("🔐 Secrets Management"):::danger
        monitor("📊 Monitoring"):::core
        network("🌐 Network Isolation"):::core
    end

    subgraph external["🌐 External Systems"]
        direction TB
        github("🐙 GitHub"):::external
        ado("🔗 Azure DevOps"):::external
        aad("🛡️ Azure Active Directory"):::external
    end

    provision -->|"requires RBAC"| iam
    provision -->|"uses credentials"| secrets
    provision -->|"logs to"| monitor
    provision -->|"connects via"| network
    secrets -->|"audited by"| monitor
    iam -->|"groups from"| aad
    provision -->|"catalogs from"| github
    provision -->|"catalogs from"| ado

    %% Centralized classDefs
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef external fill:#E0F7F7,stroke:#038387,stroke-width:2px,color:#323130

    style business fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
    style external fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130
```

### Summary

The dependency analysis reveals a tightly integrated platform with clear deployment sequencing: Monitoring → Security → Workload. All five business capabilities are interdependent, with Developer Workstation Provisioning as the central capability requiring Identity & Access Management, Secrets Management, Network Isolation, and Centralized Monitoring as supporting dependencies. External integrations with GitHub, Azure DevOps, and Azure Active Directory create external dependency points that are managed through configuration-driven catalog synchronization and Azure AD group-based identity governance.

The primary integration risk is the coupling between Dev Box pool image definitions and external Git catalogs — catalog synchronization failures would prevent new Dev Box provisioning. Implementing health monitoring for catalog sync status would mitigate this dependency risk.
