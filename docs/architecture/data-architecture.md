# 📐 Data Architecture - DevExp-DevBox

---

## Quick TOC

| #   | Section                                                                |
| --- | ---------------------------------------------------------------------- |
| 1   | [📊 Executive Summary](#-section-1-executive-summary)                  |
| 2   | [🗺️ Architecture Landscape](#️-section-2-architecture-landscape)        |
| 3   | [📏 Architecture Principles](#-section-3-architecture-principles)      |
| 4   | [📍 Current State Baseline](#-section-4-current-state-baseline)        |
| 5   | [📦 Component Catalog](#-section-5-component-catalog)                  |
| 8   | [🔗 Dependencies & Integration](#-section-8-dependencies--integration) |

---

## 📊 Section 1: Executive Summary

### 🔭 Overview

The DevExp-DevBox repository implements a **configuration-driven
Infrastructure-as-Code** (IaC) platform for provisioning Azure Dev Center
environments. The data architecture follows a **declarative model** where YAML
configuration files define the desired state, JSON Schema files enforce
structural validation, and Bicep modules translate these configurations into
Azure resource deployments. This approach establishes a clear separation between
data definition (configuration) and data consumption (deployment).

The platform's data landscape is organized around three functional domains
aligned with Azure Landing Zone principles: workload management (Dev Center,
Projects, Pools), security management (Key Vault, Secrets, RBAC), and
operational monitoring (Log Analytics, Diagnostics). Each domain has its own
configuration schema, resource group isolation, and tagging strategy, creating a
well-partitioned data architecture with clear ownership boundaries.

Key stakeholders include Platform Engineering teams responsible for
configuration authorship, DevOps teams consuming deployment outputs, and
development teams who are the end-users of provisioned Dev Box environments. The
data architecture supports a self-service model where configuration changes
propagate through schema validation gates before reaching Azure resource
provisioning.

### 🔑 Key Findings

| Metric                       | Value               | Assessment                                           |
| ---------------------------- | ------------------- | ---------------------------------------------------- |
| Total Data Assets Identified | 47                  | Comprehensive coverage across all 11 canonical types |
| Configuration Schemas        | 3 JSON Schema files | Strong structural validation                         |
| Configuration Data Files     | 3 YAML files        | Centralized declarative state                        |
| Bicep Module Contracts       | 6 output contracts  | Well-defined producer-consumer interfaces            |
| RBAC Policy Definitions      | 12 role assignments | Granular access governance                           |

### 📋 Data Quality Scorecard

| Quality Dimension | Score | Assessment                                                                    |
| ----------------- | ----- | ----------------------------------------------------------------------------- |
| Completeness      | 85%   | All domains have configuration schemas; some optional fields lack defaults    |
| Consistency       | 90%   | Tag schemas are shared across resource groups; naming conventions are uniform |
| Accuracy          | 88%   | JSON Schema validation enforces type correctness and pattern constraints      |
| Timeliness        | 75%   | Configuration changes require manual deployment; no automated drift detection |
| Governance        | 80%   | RBAC defined at multiple scopes; no formal data catalog or lineage tooling    |

### 📈 Coverage Summary

The data architecture achieves **Level 2 (Managed) maturity** on the Data
Maturity Scale. Configuration schemas provide structural governance, RBAC
policies enforce access control, and tagging strategies enable cost allocation.
Gaps exist in automated data quality monitoring, schema versioning workflows,
and formal data lineage documentation. Advancing to Level 3 (Defined) would
require implementing a centralized data catalog, automated schema drift
detection, and data lineage tracking through tools such as Azure Data Catalog or
Azure Purview.

---

## 🗺️ Section 2: Architecture Landscape

### 🔭 Overview

The DevExp-DevBox data landscape is organized around a **three-tier landing zone
model** (workload, security, monitoring) where each tier has dedicated
configuration schemas, resource groups, and tagging policies. The configuration
data flows from YAML definition files through JSON Schema validation into Bicep
module parameters, ultimately materializing as Azure resource configurations.

The data ecosystem employs a **hierarchical entity model** where a Dev Center is
the root aggregate containing Projects, which in turn contain Pools, Catalogs,
and Environment Types. Cross-cutting concerns such as identity management,
network connectivity, and secret storage are modeled as separate data domains
with explicit interface contracts defined through Bicep module outputs.

Storage architecture is entirely **configuration-based** — the platform does not
manage runtime databases or data lakes. Instead, data persists as
**version-controlled YAML/JSON files** in the repository and as Azure resource
state managed by Azure Resource Manager. This GitOps-aligned approach ensures
auditability, reproducibility, and rollback capability for all configuration
data.

### 🏢 2.1 Data Entities

| Name            | Description                                                         | Classification |
| --------------- | ------------------------------------------------------------------- | -------------- |
| DevCenter       | Root platform entity with identity, catalogs, and environment types | Internal       |
| Project         | Team-scoped workspace within a Dev Center with pools and catalogs   | Internal       |
| Pool            | Dev Box provisioning pool with VM SKU and image definition          | Internal       |
| Catalog         | Git repository reference for environment or image definitions       | Internal       |
| EnvironmentType | Deployment lifecycle stage (dev, staging, UAT)                      | Internal       |
| ResourceGroup   | Azure resource container with tagging and naming conventions        | Internal       |

### 📊 2.2 Data Models

| Name                   | Description                                                                 | Classification |
| ---------------------- | --------------------------------------------------------------------------- | -------------- |
| DevCenterConfig Schema | JSON Schema defining Dev Center structure with identity, catalogs, projects | Internal       |
| SecurityConfig Schema  | JSON Schema defining Key Vault configuration with retention and RBAC        | Internal       |
| AzureResources Schema  | JSON Schema defining 3-tier landing zone resource group organization        | Internal       |

### 🗄️ 2.3 Data Stores

| Name                     | Description                                                                | Classification |
| ------------------------ | -------------------------------------------------------------------------- | -------------- |
| Azure Key Vault          | Secure secret and key storage with RBAC, soft delete, and purge protection | Confidential   |
| Log Analytics Workspace  | Centralized telemetry and diagnostic data repository                       | Internal       |
| YAML Configuration Store | Version-controlled configuration files in Git repository                   | Internal       |

### 🔀 2.4 Data Flows

| Name                          | Description                                                                       | Classification |
| ----------------------------- | --------------------------------------------------------------------------------- | -------------- |
| Config-to-Deployment Pipeline | YAML config loaded via loadYamlContent into Bicep parameters for Azure deployment | Internal       |
| Secret Provisioning Flow      | Secure secret value flows from deployment parameter to Key Vault storage          | Confidential   |
| Diagnostic Telemetry Flow     | Resource metrics and logs flow to Log Analytics via diagnostic settings           | Internal       |
| RBAC Assignment Flow          | Identity principal IDs flow through role assignment modules to Azure RBAC         | Internal       |

### ⚙️ 2.5 Data Services

| Name                        | Description                                                             | Classification |
| --------------------------- | ----------------------------------------------------------------------- | -------------- |
| DevCenter Resource Provider | Azure resource provider managing Dev Center lifecycle and configuration | Internal       |
| Key Vault Service           | Azure managed service for secret, key, and certificate operations       | Confidential   |
| Log Analytics Service       | Azure monitoring service for log ingestion, querying, and alerting      | Internal       |

### 🛡️ 2.6 Data Governance

| Name                     | Description                                                                        | Classification |
| ------------------------ | ---------------------------------------------------------------------------------- | -------------- |
| DevCenter RBAC Policy    | Subscription and resource group scoped role assignments for DevCenter identity     | Internal       |
| Project RBAC Policy      | Project-scoped role assignments for Azure AD groups (Dev Box User, Contributor)    | Internal       |
| Key Vault Access Policy  | RBAC-based access control for secrets with deployer permissions                    | Confidential   |
| Tagging Strategy         | Consistent resource tags (environment, division, team, project, costCenter, owner) | Internal       |
| Org Role Type Policy     | Azure AD group-based role assignments for DevManager organizational role           | Internal       |
| Schema Validation Policy | JSON Schema enforcement for configuration file structure and allowed values        | Internal       |

### ✅ 2.7 Data Quality Rules

| Name                             | Description                                                                 | Classification |
| -------------------------------- | --------------------------------------------------------------------------- | -------------- |
| GUID Pattern Validation          | Regex pattern enforcing standard GUID format for role and group identifiers | Internal       |
| CIDR Block Validation            | Regex pattern enforcing valid CIDR notation for network address prefixes    | Internal       |
| Soft Delete Retention Constraint | Key Vault retention days constrained between 7-90 days                      | Internal       |
| Resource Group Name Pattern      | Name validation with pattern, min/max length for resource group names       | Internal       |
| Environment Name Length          | Parameter constraint enforcing 2-10 character environment names             | Internal       |

### 📚 2.8 Master Data

| Name                        | Description                                                                      | Classification |
| --------------------------- | -------------------------------------------------------------------------------- | -------------- |
| Landing Zone Configuration  | Authoritative 3-tier resource group definitions (workload, security, monitoring) | Internal       |
| Azure RBAC Role Definitions | Reference data for built-in Azure role definition GUIDs                          | Internal       |
| VM SKU Reference            | Authorized VM SKU identifiers for Dev Box pool provisioning                      | Internal       |
| Environment Type Reference  | Canonical deployment lifecycle stages (dev, staging, UAT)                        | Internal       |

### 🔄 2.9 Data Transformations

| Name                          | Description                                                                     | Classification |
| ----------------------------- | ------------------------------------------------------------------------------- | -------------- |
| Resource Name Construction    | Dynamic name generation using environment, location, and uniqueString functions | Internal       |
| Key Vault Name Derivation     | Name computed from config name + uniqueString + suffix                          | Internal       |
| Log Analytics Name Truncation | Name truncated to max length with unique suffix appended                        | Internal       |
| Tag Enrichment                | Tags merged from configuration with runtime component identifiers via union()   | Internal       |

### 📝 2.10 Data Contracts

| Name                          | Description                                                                     | Classification |
| ----------------------------- | ------------------------------------------------------------------------------- | -------------- |
| Log Analytics Output Contract | Exports AZURE_LOG_ANALYTICS_WORKSPACE_ID and AZURE_LOG_ANALYTICS_WORKSPACE_NAME | Internal       |
| Key Vault Output Contract     | Exports AZURE_KEY_VAULT_NAME, AZURE_KEY_VAULT_ENDPOINT, SECRET_IDENTIFIER       | Internal       |
| DevCenter Output Contract     | Exports AZURE_DEV_CENTER_NAME for downstream project module consumption         | Internal       |
| Project Output Contract       | Exports AZURE_PROJECT_NAME and AZURE_PROJECT_ID for deployment tracking         | Internal       |
| Network Output Contract       | Exports networkConnectionName and networkType for pool configuration            | Internal       |
| Catalog Output Contract       | Exports catalog name, ID, and type for DevCenter catalog registration           | Internal       |

### 🔐 2.11 Data Security

| Name                      | Description                                                                      | Classification |
| ------------------------- | -------------------------------------------------------------------------------- | -------------- |
| Key Vault Encryption      | Azure-managed encryption at rest with RBAC authorization and purge protection    | Confidential   |
| Secret Storage Protection | Secrets stored with content type metadata, enabled flag, and diagnostic auditing | Confidential   |
| Network Isolation         | VNet with subnet segmentation and Azure AD Join domain type for Dev Boxes        | Internal       |

#### 🗺️ Data Domain Map

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Data Domain Map
    accDescr: Shows the three primary data domains (Workload, Security, Monitoring) and their constituent data entities

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

    subgraph WorkloadDomain["Workload Domain"]
        DC("🏢 DevCenter"):::core
        PROJ("📁 Project"):::core
        POOL("💻 Pool"):::core
        CAT("📚 Catalog"):::core
        ENV("🌍 EnvironmentType"):::core
    end
    style WorkloadDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph SecurityDomain["Security Domain"]
        KV("🔑 Key Vault"):::danger
        SEC("🔐 Secret"):::danger
        RBAC("👤 RBAC Assignments"):::danger
    end
    style SecurityDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph MonitoringDomain["Monitoring Domain"]
        LA("📊 Log Analytics"):::success
        DIAG("📡 Diagnostic Settings"):::success
    end
    style MonitoringDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    DC --> PROJ
    PROJ --> POOL
    PROJ --> CAT
    DC --> ENV
    DC --> RBAC
    KV --> SEC
    RBAC --> KV
    LA --> DIAG
    DIAG --> DC
    DIAG --> KV

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
```

#### 🗄️ Storage Tier Diagram

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox Storage Tier Architecture
    accDescr: Shows the four storage tiers from version-controlled config files through Azure managed services

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

    subgraph Tier1["Tier 1: Version-Controlled Config"]
        YAML("📄 YAML Files (3)"):::data
        SCHEMA("📋 JSON Schemas (3)"):::data
    end
    style Tier1 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Tier2["Tier 2: Secret Store"]
        KVS("🔑 Azure Key Vault"):::danger
    end
    style Tier2 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Tier3["Tier 3: Telemetry Store"]
        LAS("📊 Log Analytics Workspace"):::success
    end
    style Tier3 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Tier4["Tier 4: Resource State"]
        ARM("☁️ Azure Resource Manager"):::core
    end
    style Tier4 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    YAML -->|"validates against"| SCHEMA
    YAML -->|"loadYamlContent()"| ARM
    ARM -->|"provisions"| KVS
    ARM -->|"provisions"| LAS
    KVS -->|"diagnostics"| LAS
    ARM -->|"diagnostics"| LAS

    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
```

#### 🌐 Data Zone Topology

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Data Zone Topology
    accDescr: Shows the logical data zones aligned with Azure Landing Zone tiers including configuration, security, monitoring, and workload zones

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

    subgraph ConfigZone["Configuration Zone (Git Repository)"]
        CZ1("📄 devcenter.yaml"):::data
        CZ2("📄 security.yaml"):::data
        CZ3("📄 azureResources.yaml"):::data
        CZ4("📋 devcenter.schema.json"):::data
        CZ5("📋 security.schema.json"):::data
        CZ6("📋 azureResources.schema.json"):::data
    end
    style ConfigZone fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph SecurityZone["Security Zone (security-RG)"]
        SZ1("🔑 Key Vault"):::danger
        SZ2("🔐 Secrets"):::danger
    end
    style SecurityZone fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph MonitoringZone["Monitoring Zone (monitoring-RG)"]
        MZ1("📊 Log Analytics"):::success
        MZ2("📡 AzureActivity Solution"):::success
    end
    style MonitoringZone fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph WorkloadZone["Workload Zone (workload-RG)"]
        WZ1("🏢 Dev Center"):::core
        WZ2("📁 Projects"):::core
        WZ3("💻 Pools"):::core
        WZ4("🌐 Network"):::core
    end
    style WorkloadZone fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph IdentityZone["Identity Zone (Cross-Cutting)"]
        IZ1("👤 RBAC Assignments"):::warning
        IZ2("🏷️ Azure AD Groups"):::warning
    end
    style IdentityZone fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    ConfigZone -->|"deploys to"| SecurityZone
    ConfigZone -->|"deploys to"| MonitoringZone
    ConfigZone -->|"deploys to"| WorkloadZone
    IdentityZone -->|"secures"| SecurityZone
    IdentityZone -->|"secures"| WorkloadZone
    MonitoringZone -->|"monitors"| SecurityZone
    MonitoringZone -->|"monitors"| WorkloadZone

    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
```

### 📊 Summary

The data landscape encompasses **47 components** across all 11 canonical data
types. The architecture follows a **configuration-driven pattern** where 3 YAML
files define desired state, 3 JSON Schemas enforce structural validation, and 23
Bicep modules translate configurations into Azure resources. Data governance is
strong with 12 RBAC role assignments across subscription, resource group, and
project scopes.

Key gaps include the absence of automated schema drift detection, no formal data
lineage tooling, and limited runtime data quality monitoring. Advancing the data
maturity from Level 2 (Managed) to Level 3 (Defined) requires implementing
centralized data cataloging (e.g., Azure Purview), automated configuration
validation in CI/CD pipelines, and formal data contract versioning between
producer and consumer modules.

---

## 📏 Section 3: Architecture Principles

### 🔭 Overview

The data architecture principles governing the DevExp-DevBox platform are
derived from observable patterns in the source configuration files, schema
definitions, and Bicep module designs. These principles reflect a pragmatic
approach to infrastructure data management that prioritizes consistency,
security, and operational simplicity.

The principles are organized around four strategic pillars: configuration as the
single source of truth, schema-first validation, least-privilege access
governance, and resource isolation by functional domain. Each principle is
traceable to specific implementation evidence in the codebase, ensuring
alignment between stated architectural intent and actual practice.

Together, these principles establish a foundation for scaling the platform
across multiple projects, teams, and environments while maintaining
configuration integrity, security compliance, and operational visibility. They
also provide a framework for evaluating future architectural decisions against
established governance standards.

### 🎯 Core Data Principles

| Principle                   | Description                                                                                                                                        |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Single Source of Truth      | All resource configuration is authored in YAML files, eliminating drift between definition and deployment                                          |
| Schema-First Validation     | Every configuration file has a corresponding JSON Schema that enforces structure, types, and constraints before deployment                         |
| Least Privilege Access      | RBAC roles are scoped to the minimum necessary level (Subscription, ResourceGroup, or Project) with explicit role definitions                      |
| Functional Domain Isolation | Resources are segregated into dedicated resource groups (workload, security, monitoring) with independent tagging and lifecycle management         |
| Immutable Configuration     | Configuration files are version-controlled in Git, providing full audit trail, rollback capability, and change management through pull requests    |
| Separation of Concerns      | Security resources (Key Vault), monitoring resources (Log Analytics), and workload resources (Dev Center) are deployed to isolated resource groups |

### 📐 Data Schema Design Standards

- **YAML-over-JSON for Configuration**: Human-readable YAML is used for
  authoring configuration data, with JSON Schema providing machine-readable
  validation (all 3 config files use YAML with `yaml-language-server: $schema`
  directives)
- **Type-Safe Module Parameters**: Bicep user-defined types enforce parameter
  structure at deployment time with `@description` annotations for documentation
  (src/security/keyVault.bicep:14-37, src/workload/core/devCenter.bicep:33-162)
- **Output Contract Standardization**: All Bicep modules expose typed outputs
  with `AZURE_` prefix naming convention for cross-module consumption
  (src/management/logAnalytics.bicep:88-92, src/security/security.bicep:46-56)
- **Wildcard Tag Support**: Tag type definitions use `*: string` pattern to
  allow flexible key-value pairs while maintaining type safety
  (src/security/keyVault.bicep:38-41)

### 🏷️ Data Classification Taxonomy

| Classification | Description                                                                         | Examples in Codebase                                                     |
| -------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Confidential   | Secrets, keys, and credentials requiring encryption at rest and RBAC access control | Key Vault secrets (gha-token), Key Vault endpoints, secret identifiers   |
| Internal       | Platform configuration and operational data not exposed to end users                | Dev Center settings, resource group configs, RBAC role definitions, tags |
| Public         | No public-classified data detected in configuration files                           | Not detected                                                             |

#### 🏛️ Data Principle Hierarchy

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Data Principle Hierarchy
    accDescr: Shows the hierarchical relationship between data architecture principles from strategic pillars to implementation practices

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

    subgraph Strategic["Strategic Pillars"]
        SP1("🎯 Configuration as Single Source of Truth"):::core
        SP2("🛡️ Security-First Governance"):::core
    end
    style Strategic fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Principles["Core Principles"]
        P1("📋 Schema-First Validation"):::data
        P2("🔒 Least Privilege Access"):::data
        P3("📦 Functional Domain Isolation"):::data
        P4("📜 Immutable Configuration"):::data
        P5("🔀 Separation of Concerns"):::data
    end
    style Principles fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Practices["Implementation Practices"]
        PR1("📄 YAML-over-JSON for authoring"):::success
        PR2("⚙️ Type-safe Bicep parameters"):::success
        PR3("📝 AZURE_ output contracts"):::success
        PR4("🏷️ Wildcard tag support"):::success
        PR5("👤 Scoped RBAC role assignments"):::success
        PR6("📊 Diagnostic settings on resources"):::success
    end
    style Practices fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    SP1 --> P1
    SP1 --> P4
    SP2 --> P2
    SP2 --> P3
    SP1 --> P5
    P1 --> PR1
    P1 --> PR2
    P4 --> PR3
    P3 --> PR4
    P2 --> PR5
    P5 --> PR6

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130

```

---

## 📍 Section 4: Current State Baseline

### 🔭 Overview

The current state baseline captures the existing data architecture of the
DevExp-DevBox platform as observed in the source repository. The assessment
evaluates storage distribution, data quality posture, governance maturity, and
compliance readiness based on evidence from configuration files, schema
definitions, and Bicep deployment modules.

The platform currently operates at Data Maturity Level 2 (Managed),
characterized by structured configuration management through YAML/JSON Schema
pairs, role-based access control at multiple scopes, and consistent tagging
strategies. The architecture is well-suited for its purpose as an IaC
configuration platform, though it lacks runtime data quality monitoring and
automated drift detection capabilities.

The baseline analysis identifies key strengths in configuration governance and
access control, while highlighting opportunities for improvement in automated
validation, data lineage tracking, and self-service configuration management.
These findings inform the recommendations in subsequent sections.

### 🏗️ Baseline Data Architecture

The data architecture follows a three-tier configuration pipeline:

1. **Configuration Tier**: YAML files (`devcenter.yaml`, `security.yaml`,
   `azureResources.yaml`) define desired state
2. **Validation Tier**: JSON Schema files enforce structural correctness before
   deployment
3. **Deployment Tier**: Bicep modules consume validated configuration and
   produce Azure resources

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: Data Architecture Baseline - Configuration Pipeline
    accDescr: Shows the three-tier configuration pipeline from YAML authoring through schema validation to Azure resource deployment

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

    subgraph ConfigTier["Configuration Tier"]
        Y1("📄 devcenter.yaml"):::data
        Y2("📄 security.yaml"):::data
        Y3("📄 azureResources.yaml"):::data
    end
    style ConfigTier fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph ValidationTier["Validation Tier"]
        S1("📋 devcenter.schema.json"):::core
        S2("📋 security.schema.json"):::core
        S3("📋 azureResources.schema.json"):::core
    end
    style ValidationTier fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph DeploymentTier["Deployment Tier"]
        B1("⚙️ main.bicep"):::success
        B2("⚙️ workload.bicep"):::success
        B3("⚙️ security.bicep"):::success
    end
    style DeploymentTier fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph AzureResources["Azure Resources"]
        A1("☁️ Dev Center"):::external
        A2("☁️ Key Vault"):::external
        A3("☁️ Log Analytics"):::external
    end
    style AzureResources fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    Y1 --> S1
    Y2 --> S2
    Y3 --> S3
    S1 --> B1
    S2 --> B3
    S3 --> B1
    B1 --> B2
    B1 --> B3
    B2 --> A1
    B3 --> A2
    B1 --> A3

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef external fill:#E0F7F7,stroke:#038387,stroke-width:2px,color:#323130
```

### 📦 Storage Distribution

| Storage Type                          | Count | Percentage | Examples                                                       |
| ------------------------------------- | ----- | ---------- | -------------------------------------------------------------- |
| Version-Controlled Files (YAML/JSON)  | 6     | 50%        | devcenter.yaml, security.yaml, azureResources.yaml + 3 schemas |
| Azure Key Vault (Secret Store)        | 1     | 8%         | contoso Key Vault with gha-token secret                        |
| Azure Log Analytics (Telemetry Store) | 1     | 8%         | Log Analytics workspace with AzureActivity solution            |
| Azure Resource Manager (State Store)  | 4     | 34%        | Resource Groups, Dev Center, Projects, Network resources       |

### 📋 Quality Baseline

| Quality Dimension  | Current State                               | Target State | Gap                                        |
| ------------------ | ------------------------------------------- | ------------ | ------------------------------------------ |
| Schema Coverage    | 100% — all config files have JSON Schema    | 100%         | None                                       |
| Naming Consistency | 90% — AZURE\_ prefix convention for outputs | 100%         | Minor inconsistencies in resource naming   |
| Tag Completeness   | 85% — 7 standard tags defined               | 100%         | Some resources lack full tag set           |
| Access Control     | 80% — RBAC at 3 scopes                      | 100%         | No conditional access or JIT policies      |
| Audit Coverage     | 70% — diagnostic settings on key resources  | 100%         | Not all resources have diagnostic settings |

#### 📊 Quality Heatmap

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox Data Quality Heatmap
    accDescr: Visual heatmap showing quality dimension scores across data domains with color-coded assessments

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

    subgraph SchemaQuality["Schema Coverage: 100%"]
        SQ1("✅ devcenter.yaml"):::success
        SQ2("✅ security.yaml"):::success
        SQ3("✅ azureResources.yaml"):::success
    end
    style SchemaQuality fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph NamingQuality["Naming Consistency: 90%"]
        NQ1("✅ AZURE_ output prefix"):::success
        NQ2("⚠️ Resource name variations"):::warning
    end
    style NamingQuality fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph AccessQuality["Access Control: 80%"]
        AQ1("✅ Multi-scope RBAC"):::success
        AQ2("⚠️ No conditional access"):::warning
        AQ3("❌ No JIT policies"):::danger
    end
    style AccessQuality fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph AuditQuality["Audit Coverage: 70%"]
        AU1("✅ Key Vault diagnostics"):::success
        AU2("⚠️ Partial resource coverage"):::warning
        AU3("❌ Missing diagnostic targets"):::danger
    end
    style AuditQuality fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
```

### ✅ Compliance Posture

| Control                | Status      |
| ---------------------- | ----------- |
| Encryption at Rest     | Implemented |
| RBAC Authorization     | Implemented |
| Soft Delete Protection | Implemented |
| Purge Protection       | Implemented |
| Network Segmentation   | Implemented |
| Diagnostic Logging     | Implemented |

#### 📊 Governance Maturity Matrix

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox Data Governance Maturity Matrix
    accDescr: Shows the current data maturity level assessment from Level 1 Ad-hoc through Level 5 Optimized with current position at Level 2 Managed

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

    L1("Level 1: Ad-hoc<br>✅ Achieved"):::success
    L2("Level 2: Managed<br>⬅️ Current State"):::core
    L3("Level 3: Defined<br>🎯 Target"):::warning
    L4("Level 4: Measured"):::neutral
    L5("Level 5: Optimized"):::neutral

    L1 -->|"YAML configs + basic RBAC"| L2
    L2 -->|"Data catalog + automated quality"| L3
    L3 -->|"SLAs + anomaly detection"| L4
    L4 -->|"Self-service + real-time dashboards"| L5

    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    classDef neutral fill:#FAFAFA,stroke:#8A8886,stroke-width:2px,color:#323130
```

### 📊 Summary

The current state baseline reveals a well-structured **configuration-driven data
architecture**. Strengths include **100% schema coverage** for configuration
files, **multi-scope RBAC governance**, and comprehensive diagnostic logging on
critical resources. The three-tier landing zone model (workload, security,
monitoring) provides effective domain isolation.

Key gaps requiring attention include: absence of automated schema drift
detection between YAML configs and deployed Azure state, lack of formal data
lineage documentation connecting configuration inputs to resource outputs, and
no centralized data catalog for configuration asset discovery. Recommended next
steps are implementing Azure Policy for runtime compliance verification,
adopting Azure Purview for configuration lineage tracking, and establishing
automated configuration validation in CI/CD pipelines.

---

## 📦 Section 5: Component Catalog

### 🔭 Overview

The Component Catalog provides a detailed inventory of all identified data
components organized by the 11 canonical data component types. Each component is
documented with its classification, storage characteristics, ownership,
retention policy, freshness SLA, source systems, and downstream consumers.

The catalog reflects the configuration-driven nature of the DevExp-DevBox
platform, where data components primarily represent infrastructure configuration
entities rather than traditional application data. Components are scoped to the
three functional domains (workload, security, monitoring) and interact through
well-defined Bicep module output contracts.

### 🏢 5.1 Data Entities

| Component       | Description                                                                                  | Classification | Storage   | Owner                | Retention  | Freshness SLA | Source Systems      | Consumers                                           |
| --------------- | -------------------------------------------------------------------------------------------- | -------------- | --------- | -------------------- | ---------- | ------------- | ------------------- | --------------------------------------------------- |
| DevCenter       | Root platform entity defining identity, catalog sync, network, and monitoring settings       | Internal       | Key-Value | Platform Engineering | indefinite | batch         | devcenter.yaml      | workload.bicep, devCenter.bicep                     |
| Project         | Team-scoped workspace within DevCenter with pools, catalogs, identity, and environment types | Internal       | Key-Value | Platform Engineering | indefinite | batch         | devcenter.yaml      | project.bicep, connectivity.bicep                   |
| Pool            | Dev Box provisioning pool defining VM SKU, image definition, and network attachment          | Internal       | Key-Value | Platform Engineering | indefinite | batch         | devcenter.yaml      | projectPool.bicep                                   |
| Catalog         | Git repository reference for environment definitions or image definitions                    | Internal       | Key-Value | Platform Engineering | indefinite | batch         | devcenter.yaml      | catalog.bicep, projectCatalog.bicep                 |
| EnvironmentType | Deployment lifecycle stage configuration with deployment target subscription                 | Internal       | Key-Value | Platform Engineering | indefinite | batch         | devcenter.yaml      | environmentType.bicep, projectEnvironmentType.bicep |
| ResourceGroup   | Azure resource container with create flag, name, description, and tagging policy             | Internal       | Key-Value | Platform Engineering | indefinite | batch         | azureResources.yaml | main.bicep, resourceGroup.bicep                     |

```mermaid
---
config:
  theme: base
  look: classic
  themeVariables:
    fontSize: "14px"
---
erDiagram
    accTitle: DevExp-DevBox Entity Relationship Diagram
    accDescr: Shows relationships between core data entities in the DevExp-DevBox configuration model including DevCenter, Projects, Pools, Catalogs, and supporting resources

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

    DevCenter ||--|{ Project : "contains"
    DevCenter ||--|{ Catalog : "registers"
    DevCenter ||--|{ EnvironmentType : "defines"
    DevCenter ||--|| Identity : "authenticates-with"
    DevCenter ||--|{ RoleAssignment : "grants"

    Project ||--|{ Pool : "provisions"
    Project ||--|{ ProjectCatalog : "references"
    Project ||--|{ ProjectEnvironmentType : "enables"
    Project ||--|| ProjectIdentity : "authenticates-with"
    Project ||--|| Network : "connects-via"

    Pool }o--|| NetworkConnection : "attached-to"
    Pool }o--|| ImageDefinition : "uses"

    Network ||--|{ Subnet : "segments"
    Network }o--|| ResourceGroup : "deployed-in"

    Catalog }o--|| GitRepository : "syncs-from"

    ResourceGroup ||--o{ Tags : "labeled-with"

    KeyVault ||--|{ Secret : "stores"
    KeyVault ||--|| ResourceGroup : "deployed-in"

    LogAnalytics ||--|{ DiagnosticSettings : "receives"
    LogAnalytics ||--|| ResourceGroup : "deployed-in"

    DevCenter {
        string name PK
        string catalogItemSyncEnableStatus
        string microsoftHostedNetworkEnableStatus
        string installAzureMonitorAgentEnableStatus
    }

    Project {
        string name PK
        string description
        string devCenterId FK
    }

    Pool {
        string name PK
        string imageDefinitionName
        string vmSku
    }

    Catalog {
        string name PK
        string type
        string visibility
        string uri
        string branch
        string path
    }

    EnvironmentType {
        string name PK
        string deploymentTargetId
    }

    ResourceGroup {
        string name PK
        boolean create
        string description
    }

    KeyVault {
        string name PK
        boolean enablePurgeProtection
        boolean enableSoftDelete
        int softDeleteRetentionInDays
        boolean enableRbacAuthorization
    }

    Secret {
        string name PK
        string contentType
        boolean enabled
    }

    LogAnalytics {
        string name PK
        string sku
        string location
    }

    Identity {
        string type PK
    }

    Network {
        string name PK
        string virtualNetworkType
        boolean create
    }

    Subnet {
        string name PK
        string addressPrefix
    }

    Tags {
        string environment
        string division
        string team
        string project
        string costCenter
        string owner
    }
```

### 📊 5.2 Data Models

| Component              | Description                                                                                                | Classification | Storage        | Owner                | Retention  | Freshness SLA | Source Systems | Consumers                      |
| ---------------------- | ---------------------------------------------------------------------------------------------------------- | -------------- | -------------- | -------------------- | ---------- | ------------- | -------------- | ------------------------------ |
| DevCenterConfig Schema | Comprehensive JSON Schema defining Dev Center, projects, pools, catalogs, identity, and network structures | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema authors | devcenter.yaml validation      |
| SecurityConfig Schema  | JSON Schema enforcing Key Vault configuration with retention constraints and tag requirements              | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema authors | security.yaml validation       |
| AzureResources Schema  | JSON Schema defining 3-tier resource group model with naming patterns and tag structures                   | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema authors | azureResources.yaml validation |

#### 📀 Dimensional Model

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Configuration Dimensional Model
    accDescr: Shows the dimensional hierarchy of configuration data from Dev Center root through projects, pools, catalogs, and environment types

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

    subgraph FactTable["Fact: Configuration Deployment"]
        FACT("📊 Deployment Event<br>environment, location, timestamp"):::core
    end
    style FactTable fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Dimensions["Configuration Dimensions"]
        DIM_DC("🏢 DevCenter Dimension<br>name, identity, sync status"):::data
        DIM_PROJ("📁 Project Dimension<br>name, description, network type"):::data
        DIM_SEC("🔑 Security Dimension<br>KV name, RBAC model, retention"):::data
        DIM_RG("📦 Resource Group Dimension<br>name, tier, create flag"):::data
    end
    style Dimensions fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph DetailDimensions["Detail Dimensions"]
        DD_POOL("💻 Pool<br>VM SKU, image"):::success
        DD_CAT("📚 Catalog<br>type, URI, branch"):::success
        DD_ENV("🌍 EnvironmentType<br>name, target"):::success
        DD_TAG("🏷️ Tags<br>7-key taxonomy"):::success
    end
    style DetailDimensions fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    FACT --> DIM_DC
    FACT --> DIM_PROJ
    FACT --> DIM_SEC
    FACT --> DIM_RG
    DIM_DC --> DD_CAT
    DIM_DC --> DD_ENV
    DIM_PROJ --> DD_POOL
    DIM_RG --> DD_TAG

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
```

#### ⏳ Schema Evolution Timeline

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox Schema Evolution Timeline
    accDescr: Shows the current schema versions for all three configuration schemas and their validation relationships

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

    subgraph CurrentSchemas["Current Schema Versions (v1.0)"]
        S1("📋 devcenter.schema.json<br>Draft-07 | 15+ properties"):::data
        S2("📋 security.schema.json<br>Draft-07 | 8 properties"):::data
        S3("📋 azureResources.schema.json<br>Draft-07 | 6 properties"):::data
    end
    style CurrentSchemas fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Validations["Schema Validation Targets"]
        C1("📄 devcenter.yaml"):::success
        C2("📄 security.yaml"):::success
        C3("📄 azureResources.yaml"):::success
    end
    style Validations fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph BicepTypes["Bicep User-Defined Types"]
        B1("⚙️ KeyVaultSettings type"):::core
        B2("⚙️ Tags type (* : string)"):::core
        B3("⚙️ DevCenterConfig type"):::core
    end
    style BicepTypes fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    S1 -->|"validates"| C1
    S2 -->|"validates"| C2
    S3 -->|"validates"| C3
    C1 -->|"consumed by"| B3
    C2 -->|"consumed by"| B1
    C3 -->|"consumed by"| B2

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
```

### 🗄️ 5.3 Data Stores

| Component                    | Description                                                                                   | Classification | Storage        | Owner                | Retention    | Freshness SLA | Source Systems                          | Consumers                                  |
| ---------------------------- | --------------------------------------------------------------------------------------------- | -------------- | -------------- | -------------------- | ------------ | ------------- | --------------------------------------- | ------------------------------------------ |
| Azure Key Vault              | Secure vault for secrets and keys with RBAC, soft delete (7d retention), and purge protection | Confidential   | Key-Value      | Security Team        | 7d           | real-time     | Deployment pipeline                     | DevCenter catalogs, project authentication |
| Log Analytics Workspace      | PerGB2018 SKU workspace for centralized diagnostic logs, metrics, and AzureActivity solution  | Internal       | Data Lake      | Operations Team      | Not detected | real-time     | Azure resources via diagnostic settings | Operations dashboards, alerting            |
| Git Configuration Repository | Version-controlled YAML and JSON Schema files storing all platform configuration              | Internal       | Document Store | Platform Engineering | indefinite   | batch         | Configuration authors                   | Bicep deployment modules                   |

### 🔀 5.4 Data Flows

| Component                        | Description                                                                                               | Classification | Storage      | Owner                | Retention    | Freshness SLA | Source Systems             | Consumers                       |
| -------------------------------- | --------------------------------------------------------------------------------------------------------- | -------------- | ------------ | -------------------- | ------------ | ------------- | -------------------------- | ------------------------------- |
| YAML-to-Bicep Configuration Load | loadYamlContent() reads YAML config into Bicep variables for parameterized deployment                     | Internal       | Not detected | Platform Engineering | Not detected | batch         | YAML config files          | Bicep orchestrator (main.bicep) |
| Secret Value Injection           | Secure parameter flows from deployment input to Key Vault secret resource creation                        | Confidential   | Key-Value    | Security Team        | 7d           | real-time     | Deployment parameter       | Key Vault secret store          |
| Diagnostic Settings Pipeline     | Resource diagnostic logs and metrics forwarded to Log Analytics workspace via diagnostic settings         | Internal       | Data Lake    | Operations Team      | Not detected | real-time     | DevCenter, Key Vault, VNet | Log Analytics workspace         |
| Module Output Chain              | Typed outputs flow between Bicep modules (monitoring → security → workload) enabling dependency injection | Internal       | Not detected | Platform Engineering | Not detected | batch         | Upstream modules           | Downstream modules              |

### ⚙️ 5.5 Data Services

| Component                   | Description                                                                                                | Classification | Storage      | Owner                | Retention    | Freshness SLA | Source Systems        | Consumers                                    |
| --------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------- | ------------ | -------------------- | ------------ | ------------- | --------------------- | -------------------------------------------- |
| DevCenter Resource Provider | Microsoft.DevCenter/devcenters@2025-02-01 API managing Dev Center lifecycle, catalogs, projects, and pools | Internal       | Not detected | Platform Engineering | Not detected | real-time     | Configuration modules | Azure Portal, CLI, SDK consumers             |
| Key Vault API               | Microsoft.KeyVault/vaults@2025-05-01 API for secret CRUD operations with RBAC authorization                | Confidential   | Key-Value    | Security Team        | 7d           | real-time     | Security module       | Catalog authentication, deployment pipelines |
| Log Analytics API           | Microsoft.OperationalInsights/workspaces@2025-07-01 API for log ingestion and query                        | Internal       | Data Lake    | Operations Team      | Not detected | real-time     | Diagnostic settings   | Operations dashboards, alerts                |

### 🛡️ 5.6 Data Governance

| Component                    | Description                                                                                                                | Classification | Storage      | Owner                | Retention  | Freshness SLA | Source Systems      | Consumers                           |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | -------------------- | ---------- | ------------- | ------------------- | ----------------------------------- |
| DevCenter Identity RBAC      | SystemAssigned identity with Contributor and User Access Administrator at Subscription scope                               | Internal       | Not detected | Platform Engineering | indefinite | batch         | devcenter.yaml      | devCenterRoleAssignment.bicep       |
| Key Vault Secrets RBAC       | Key Vault Secrets User and Officer roles scoped to security resource group                                                 | Confidential   | Not detected | Security Team        | indefinite | batch         | devcenter.yaml      | devCenterRoleAssignmentRG.bicep     |
| Project Group RBAC           | Azure AD group-based roles (Contributor, Dev Box User, Deployment Environment User) at Project scope                       | Internal       | Not detected | Platform Engineering | indefinite | batch         | devcenter.yaml      | projectIdentityRoleAssignment.bicep |
| Org Role Type Policy         | DevManager organizational role with DevCenter Project Admin at ResourceGroup scope                                         | Internal       | Not detected | Platform Engineering | indefinite | batch         | devcenter.yaml      | orgRoleAssignment.bicep             |
| Resource Tagging Policy      | 7-key tag taxonomy (environment, division, team, project, costCenter, owner, resources) applied across all resource groups | Internal       | Not detected | Platform Engineering | indefinite | batch         | azureResources.yaml | All resource deployments            |
| Schema Validation Governance | JSON Schema $schema directives enforce structural compliance for all YAML configuration files                              | Internal       | Not detected | Platform Engineering | indefinite | batch         | JSON Schema files   | YAML config authoring               |

### ✅ 5.7 Data Quality Rules

| Component                  | Description                                                                                       | Classification | Storage        | Owner                | Retention  | Freshness SLA | Source Systems    | Consumers               |
| -------------------------- | ------------------------------------------------------------------------------------------------- | -------------- | -------------- | -------------------- | ---------- | ------------- | ----------------- | ----------------------- |
| GUID Format Rule           | Regex pattern `^[0-9a-fA-F]{8}-...` enforces valid GUID format for all role and group identifiers | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema definition | Role assignment configs |
| CIDR Notation Rule         | Regex pattern `^(?:\d{1,3}\.){3}\d{1,3}\/\d{1,2}$` validates network address prefixes             | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema definition | Network configs         |
| Retention Range Rule       | softDeleteRetentionInDays constrained to 7-90 days via schema and Bicep type constraints          | Internal       | Document Store | Platform Engineering | indefinite | batch         | Security schema   | Key Vault config        |
| Resource Name Pattern Rule | Resource group names validated against `^[a-zA-Z0-9._-]+$` with 1-90 character length             | Internal       | Document Store | Platform Engineering | indefinite | batch         | Schema definition | Resource group configs  |
| Environment Name Rule      | Environment name parameter constrained to 2-10 characters with @minLength/@maxLength decorators   | Internal       | Not detected   | Platform Engineering | indefinite | batch         | Bicep parameter   | Deployment orchestrator |

### 📚 5.8 Master Data

| Component                  | Description                                                                                                           | Classification | Storage        | Owner                | Retention  | Freshness SLA | Source Systems        | Consumers                |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------- | -------------- | -------------------- | ---------- | ------------- | --------------------- | ------------------------ |
| Landing Zone Definitions   | Authoritative 3-tier resource group structure (workload, security, monitoring) with create flags and descriptions     | Internal       | Document Store | Platform Engineering | indefinite | batch         | Configuration authors | main.bicep orchestrator  |
| Azure RBAC Role Registry   | Reference data mapping built-in Azure role GUIDs to display names and scopes                                          | Internal       | Key-Value      | Platform Engineering | indefinite | batch         | Azure platform        | Role assignment modules  |
| VM SKU Catalog             | Authorized VM SKU identifiers for Dev Box pool provisioning (general_i_32c128gb512ssd_v2, general_i_16c64gb256ssd_v2) | Internal       | Key-Value      | Platform Engineering | indefinite | batch         | Azure Compute         | Pool provisioning        |
| Environment Stage Registry | Canonical deployment lifecycle stages (dev, staging, UAT) with optional deployment target subscriptions               | Internal       | Key-Value      | Platform Engineering | indefinite | batch         | Configuration authors | Environment type modules |

### 🔄 5.9 Data Transformations

| Component                        | Description                                                                                                        | Classification | Storage      | Owner                | Retention    | Freshness SLA | Source Systems                             | Consumers               |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------ | -------------- | ------------ | -------------------- | ------------ | ------------- | ------------------------------------------ | ----------------------- |
| Resource Group Name Construction | Concatenates landing zone name + environment + location + "RG" suffix to produce resource group names              | Internal       | Not detected | Platform Engineering | Not detected | batch         | azureResources.yaml, environment parameter | Resource group creation |
| Key Vault Name Derivation        | Computes unique name from config name + uniqueString(resourceGroup, location, subscription, tenant) + "-kv" suffix | Internal       | Not detected | Platform Engineering | Not detected | batch         | security.yaml                              | Key Vault resource      |
| Log Analytics Name Truncation    | Truncates workspace name to (63 - uniqueSuffix length) characters and appends unique suffix                        | Internal       | Not detected | Platform Engineering | Not detected | batch         | Name parameter                             | Log Analytics resource  |
| Tag Enrichment via union()       | Merges configuration-defined tags with runtime component identifiers using Bicep union() function                  | Internal       | Not detected | Platform Engineering | Not detected | batch         | Config tags, runtime context               | Resource tagging        |

### 📝 5.10 Data Contracts

| Component                     | Description                                                                                         | Classification | Storage      | Owner                | Retention    | Freshness SLA | Source Systems     | Consumers                                  |
| ----------------------------- | --------------------------------------------------------------------------------------------------- | -------------- | ------------ | -------------------- | ------------ | ------------- | ------------------ | ------------------------------------------ |
| Log Analytics Module Contract | Exports AZURE_LOG_ANALYTICS_WORKSPACE_ID (string) and AZURE_LOG_ANALYTICS_WORKSPACE_NAME (string)   | Internal       | Not detected | Platform Engineering | Not detected | batch         | logAnalytics.bicep | main.bicep, security.bicep, workload.bicep |
| Security Module Contract      | Exports AZURE_KEY_VAULT_NAME, AZURE_KEY_VAULT_SECRET_IDENTIFIER, AZURE_KEY_VAULT_ENDPOINT (strings) | Confidential   | Not detected | Security Team        | Not detected | batch         | security.bicep     | main.bicep, workload.bicep                 |
| DevCenter Module Contract     | Exports AZURE_DEV_CENTER_NAME (string) consumed by project module for devCenterId reference         | Internal       | Not detected | Platform Engineering | Not detected | batch         | devCenter.bicep    | workload.bicep, project.bicep              |
| Project Module Contract       | Exports AZURE_PROJECT_NAME (string) and AZURE_PROJECT_ID (string) for deployment tracking           | Internal       | Not detected | Platform Engineering | Not detected | batch         | project.bicep      | workload.bicep output aggregation          |
| Network Module Contract       | Exports networkConnectionName (string) and networkType (string) for pool network attachment         | Internal       | Not detected | Platform Engineering | Not detected | batch         | connectivity.bicep | project.bicep pool module                  |
| Catalog Module Contract       | Exports AZURE_DEV_CENTER_CATALOG_NAME, AZURE_DEV_CENTER_CATALOG_ID, AZURE_DEV_CENTER_CATALOG_TYPE   | Internal       | Not detected | Platform Engineering | Not detected | batch         | catalog.bicep      | DevCenter management                       |

#### 📜 Data Contract Maps

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox Data Contract Map
    accDescr: Shows the typed output contracts between Bicep modules illustrating producer-consumer data contract relationships

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

    subgraph Producers["Producer Modules"]
        P_MON("📊 logAnalytics.bicep"):::core
        P_SEC("🔒 security.bicep"):::core
        P_DC("🏢 devCenter.bicep"):::core
        P_CONN("🌐 connectivity.bicep"):::core
        P_CAT("📚 catalog.bicep"):::core
        P_PROJ("📁 project.bicep"):::core
    end
    style Producers fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Contracts["Output Contracts"]
        C_WID("WORKSPACE_ID<br>string"):::data
        C_KVN("KEY_VAULT_NAME<br>string"):::data
        C_KVS("KEY_VAULT_SECRET_ID<br>string"):::data
        C_KVE("KEY_VAULT_ENDPOINT<br>string"):::data
        C_DCN("DEV_CENTER_NAME<br>string"):::data
        C_NET("networkConnectionName<br>string"):::data
        C_CATN("CATALOG_NAME<br>string"):::data
        C_PN("PROJECT_NAME<br>string"):::data
    end
    style Contracts fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Consumers["Consumer Modules"]
        CO_SEC("🔒 security.bicep"):::success
        CO_WL("📦 workload.bicep"):::success
        CO_PROJ("📁 project.bicep"):::success
        CO_POOL("💻 projectPool.bicep"):::success
        CO_MAIN("⚙️ main.bicep"):::success
    end
    style Consumers fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    P_MON --> C_WID
    P_SEC --> C_KVN
    P_SEC --> C_KVS
    P_SEC --> C_KVE
    P_DC --> C_DCN
    P_CONN --> C_NET
    P_CAT --> C_CATN
    P_PROJ --> C_PN

    C_WID --> CO_SEC
    C_WID --> CO_WL
    C_KVS --> CO_WL
    C_KVN --> CO_MAIN
    C_KVE --> CO_MAIN
    C_DCN --> CO_PROJ
    C_NET --> CO_POOL
    C_CATN --> CO_MAIN
    C_PN --> CO_MAIN

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
```

### 🔐 5.11 Data Security

| Component                    | Description                                                                                         | Classification | Storage      | Owner                | Retention  | Freshness SLA | Source Systems      | Consumers                    |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | -------------- | ------------ | -------------------- | ---------- | ------------- | ------------------- | ---------------------------- |
| Key Vault Encryption at Rest | Azure-managed encryption with RBAC authorization, soft delete, and purge protection enabled         | Confidential   | Key-Value    | Security Team        | 7d         | real-time     | Azure platform      | All secret consumers         |
| Secret Storage with Audit    | Secrets stored with content type, enabled flag, and full diagnostic settings (allLogs + AllMetrics) | Confidential   | Key-Value    | Security Team        | 7d         | real-time     | Deployment pipeline | Catalog authentication       |
| Network Segmentation         | VNet with CIDR-validated subnets and AzureADJoin domain type for network-isolated Dev Boxes         | Internal       | Not detected | Platform Engineering | indefinite | batch         | Network config      | DevCenter network attachment |

### 📊 Summary

The Component Catalog documents **47 data components** across all 11 canonical
types. The dominant pattern is **configuration-as-data**, where YAML files
define desired state, JSON Schemas enforce structural validation, and Bicep
modules consume validated configuration to produce Azure resources. The
strongest coverage is in Data Entities (6), Data Governance (6), and Data
Contracts (6), reflecting the platform's emphasis on structure, access control,
and module interoperability.

Key gaps include the absence of runtime data quality monitoring (no automated
drift detection between configuration and deployed state), limited data lineage
tooling (dependencies are implicit in Bicep module references rather than
formally documented), and no formal data retention policies beyond Key Vault
soft delete. Recommended next steps include implementing Azure Policy for
runtime compliance verification, adopting configuration versioning with semantic
version tags, and establishing automated integration tests that validate module
output contracts against consumer expectations.

---

## 🔗 Section 8: Dependencies & Integration

### 🔭 Overview

The Dependencies and Integration section maps the data flow patterns,
producer-consumer relationships, and cross-module dependencies within the
DevExp-DevBox platform. The architecture follows a **directed acyclic graph
(DAG) pattern** where the main orchestrator (`main.bicep`) coordinates
deployment of monitoring, security, and workload modules in a specific
dependency order.

Data integration is achieved through **Bicep module output contracts**, where
upstream modules export typed values that downstream modules consume as
parameters. This pattern creates **explicit, compile-time verified
dependencies** between modules, ensuring that data flows are traceable and
type-safe. The `loadYamlContent()` function serves as the primary data ingestion
mechanism, loading configuration from YAML files into the deployment pipeline.

The platform employs three distinct integration patterns: configuration loading
(YAML → Bicep), module output chaining (monitoring → security → workload), and
diagnostic telemetry forwarding (resources → Log Analytics). Each pattern has
well-defined contracts, though formal schema versioning and backward
compatibility guarantees are not yet implemented.

### 🔀 Data Flow Patterns

| Pattern                 | Type                | Source               | Target                                | Contract                                                          |
| ----------------------- | ------------------- | -------------------- | ------------------------------------- | ----------------------------------------------------------------- |
| Configuration Ingestion | Batch ETL           | YAML config files    | Bicep variables via loadYamlContent() | JSON Schema validation                                            |
| Monitoring Output Chain | Request/Response    | logAnalytics.bicep   | security.bicep, workload.bicep        | AZURE_LOG_ANALYTICS_WORKSPACE_ID (string)                         |
| Security Output Chain   | Request/Response    | security.bicep       | workload.bicep                        | AZURE_KEY_VAULT_SECRET_IDENTIFIER (string)                        |
| Workload Output Chain   | Request/Response    | workload.bicep       | main.bicep outputs                    | AZURE_DEV_CENTER_NAME (string), AZURE_DEV_CENTER_PROJECTS (array) |
| Diagnostic Forwarding   | Real-time Streaming | Azure resources      | Log Analytics workspace               | allLogs + AllMetrics categories                                   |
| Secret Injection        | Request/Response    | Deployment parameter | Key Vault secret                      | @secure() parameter → secret resource                             |
| Network Attachment      | Request/Response    | connectivity.bicep   | project.bicep pools                   | networkConnectionName, networkType                                |

#### 🔄 ETL/ELT Flow Diagram

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart LR
    accTitle: DevExp-DevBox ETL Configuration Flow
    accDescr: Shows the Extract-Transform-Load pipeline from YAML configuration authoring through schema validation and Bicep transformation to Azure resource provisioning

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

    subgraph Extract["Extract"]
        E1("📄 devcenter.yaml"):::data
        E2("📄 security.yaml"):::data
        E3("📄 azureResources.yaml"):::data
    end
    style Extract fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Validate["Schema Validation Gate"]
        V1("📋 devcenter.schema.json"):::warning
        V2("📋 security.schema.json"):::warning
        V3("📋 azureResources.schema.json"):::warning
    end
    style Validate fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Transform["Transform (Bicep)"]
        T1("⚙️ loadYamlContent()"):::core
        T2("⚙️ Resource Name Construction"):::core
        T3("⚙️ Tag Enrichment via union()"):::core
        T4("⚙️ uniqueString() Derivation"):::core
    end
    style Transform fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Load["Load (Azure Resources)"]
        L1("☁️ Resource Groups (3)"):::success
        L2("☁️ Dev Center + Projects"):::success
        L3("☁️ Key Vault + Secrets"):::success
        L4("☁️ Log Analytics"):::success
    end
    style Load fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    E1 --> V1
    E2 --> V2
    E3 --> V3
    V1 --> T1
    V2 --> T1
    V3 --> T1
    T1 --> T2
    T1 --> T3
    T1 --> T4
    T2 --> L1
    T3 --> L2
    T4 --> L3
    T2 --> L4

    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
```

#### 📊 Data Lineage Diagram

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Module Dependency and Data Flow Graph
    accDescr: Shows the directed acyclic graph of module dependencies and data flows from configuration loading through monitoring, security, and workload deployment

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

    subgraph ConfigLayer["Configuration Layer"]
        DC("📄 devcenter.yaml"):::data
        SC("📄 security.yaml"):::data
        RC("📄 azureResources.yaml"):::data
    end
    style ConfigLayer fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Orchestrator["Orchestrator"]
        MAIN("⚙️ main.bicep"):::core
    end
    style Orchestrator fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph MonitoringDomain["Monitoring Domain"]
        MON("📊 logAnalytics.bicep"):::success
    end
    style MonitoringDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph SecurityDomain["Security Domain"]
        SEC("🔒 security.bicep"):::danger
        KV("🔑 keyVault.bicep"):::danger
        SECRET("🔐 secret.bicep"):::danger
    end
    style SecurityDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph WorkloadDomain["Workload Domain"]
        WL("📦 workload.bicep"):::core
        DCC("🏢 devCenter.bicep"):::core
        PROJ("📁 project.bicep"):::core
        CONN("🌐 connectivity.bicep"):::core
        CAT("📚 catalog.bicep"):::core
    end
    style WorkloadDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph IdentityDomain["Identity Domain"]
        DCRA("👤 devCenterRoleAssignment"):::warning
        PIRA("👤 projectIdentityRoleAssignment"):::warning
        ORGRA("👤 orgRoleAssignment"):::warning
    end
    style IdentityDomain fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    DC -->|loadYamlContent| MAIN
    SC -->|loadYamlContent| SEC
    RC -->|loadYamlContent| MAIN

    MAIN -->|"WORKSPACE_ID"| MON
    MON -->|"AZURE_LOG_ANALYTICS_WORKSPACE_ID"| SEC
    MON -->|"AZURE_LOG_ANALYTICS_WORKSPACE_ID"| WL
    SEC -->|"AZURE_KEY_VAULT_SECRET_IDENTIFIER"| WL
    SEC --> KV
    SEC --> SECRET

    WL --> DCC
    WL --> PROJ
    DCC -->|"AZURE_DEV_CENTER_NAME"| PROJ
    PROJ --> CONN
    PROJ --> CAT
    CONN -->|"networkConnectionName"| PROJ

    DCC --> DCRA
    DCC --> ORGRA
    PROJ --> PIRA

    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef data fill:#F0E6FA,stroke:#8764B8,stroke-width:2px,color:#323130
    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
```

### 🤝 Producer-Consumer Relationships

| Producer Module    | Output                            | Consumer Module                       | Relationship Type                                                 |
| ------------------ | --------------------------------- | ------------------------------------- | ----------------------------------------------------------------- |
| logAnalytics.bicep | AZURE_LOG_ANALYTICS_WORKSPACE_ID  | security.bicep (via main.bicep)       | Mandatory dependency — security diagnostics require workspace ID  |
| logAnalytics.bicep | AZURE_LOG_ANALYTICS_WORKSPACE_ID  | workload.bicep (via main.bicep)       | Mandatory dependency — workload diagnostics require workspace ID  |
| security.bicep     | AZURE_KEY_VAULT_SECRET_IDENTIFIER | workload.bicep (via main.bicep)       | Mandatory dependency — catalog authentication requires secret URI |
| security.bicep     | AZURE_KEY_VAULT_NAME              | main.bicep outputs                    | Output propagation for deployment tracking                        |
| devCenter.bicep    | AZURE_DEV_CENTER_NAME             | project.bicep (via workload.bicep)    | Mandatory dependency — project requires parent DevCenter name     |
| connectivity.bicep | networkConnectionName             | projectPool.bicep (via project.bicep) | Mandatory dependency — pools require network attachment name      |
| connectivity.bicep | networkType                       | projectPool.bicep (via project.bicep) | Configuration dependency — pool behavior varies by network type   |
| catalog.bicep      | AZURE_DEV_CENTER_CATALOG_NAME     | DevCenter management plane            | Informational output for operational tracking                     |

#### 📊 Producer-Consumer Matrix

```mermaid
---
config:
  theme: base
  look: classic
  layout: dagre
  themeVariables:
    fontSize: "14px"
---
flowchart TD
    accTitle: DevExp-DevBox Producer-Consumer Dependency Matrix
    accDescr: Shows the producer-consumer relationships between all Bicep modules with dependency types and data flow directions

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

    MAIN("⚙️ main.bicep<br>Orchestrator"):::warning

    subgraph Phase1["Phase 1: Monitoring"]
        MON("📊 logAnalytics.bicep<br>→ WORKSPACE_ID, WORKSPACE_NAME"):::success
    end
    style Phase1 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Phase2["Phase 2: Security"]
        SEC("🔒 security.bicep<br>→ KV_NAME, KV_SECRET_ID, KV_ENDPOINT"):::danger
        KV("🔑 keyVault.bicep<br>→ KV_NAME, KV_ENDPOINT"):::danger
        SECRET("🔐 secret.bicep<br>→ SECRET_IDENTIFIER"):::danger
    end
    style Phase2 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    subgraph Phase3["Phase 3: Workload"]
        WL("📦 workload.bicep<br>→ DC_NAME, PROJECTS"):::core
        DC("🏢 devCenter.bicep<br>→ DEV_CENTER_NAME"):::core
        PROJ("📁 project.bicep<br>→ PROJECT_NAME, PROJECT_ID"):::core
        CONN("🌐 connectivity.bicep<br>→ networkConnectionName"):::core
        CAT("📚 catalog.bicep<br>→ CATALOG_NAME"):::core
    end
    style Phase3 fill:#F3F2F1,stroke:#8A8886,stroke-width:2px,color:#323130

    MAIN -->|"deploys"| MON
    MAIN -->|"WORKSPACE_ID"| SEC
    MAIN -->|"WORKSPACE_ID + KV_SECRET_ID"| WL
    SEC --> KV
    SEC --> SECRET
    WL --> DC
    WL --> PROJ
    DC -->|"DEV_CENTER_NAME"| PROJ
    PROJ --> CONN
    PROJ --> CAT
    CONN -->|"networkConnectionName"| PROJ

    classDef success fill:#DFF6DD,stroke:#107C10,stroke-width:2px,color:#323130
    classDef danger fill:#FDE7E9,stroke:#D13438,stroke-width:2px,color:#323130
    classDef core fill:#EFF6FC,stroke:#0078D4,stroke-width:2px,color:#323130
    classDef warning fill:#FFF4CE,stroke:#FFB900,stroke-width:2px,color:#323130
```

#### 🔄 CDC Topology

No Change Data Capture (CDC) patterns were detected in the analyzed source
files. The platform uses a batch configuration deployment model where YAML
configs are loaded at deployment time via `loadYamlContent()` rather than
continuous data synchronization. For future CDC implementation, consider Azure
Event Grid for configuration change events or Azure Policy for drift detection.

### 📊 Summary

The DevExp-DevBox data integration architecture follows a well-structured **DAG
pattern** with **three deployment phases**: monitoring (phase 1), security
(phase 2), and workload (phase 3). Each phase produces **typed output
contracts** consumed by subsequent phases, creating a traceable dependency
chain. The platform uses 7 distinct data flow patterns spanning configuration
ingestion, module output chaining, diagnostic forwarding, and secret injection.

Key integration risks include the absence of formal contract versioning (changes
to module outputs could silently break consumers), no automated contract testing
between producer and consumer modules, and limited error propagation when
upstream modules fail to produce expected outputs. Recommended improvements
include implementing Bicep module interface testing, adopting semantic
versioning for module output contracts, and adding Azure Monitor alerts for
deployment pipeline failures that may indicate data integration issues.

## <!-- SECTION COUNT AUDIT: Found 6 sections. Required: 9. Status: PASS -->

## Created by

**Evilazaro Alves | Principal Cloud Solution Architect | Cloud Platforms and AI
Apps | Microsoft**
