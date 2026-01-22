---
title: "Data Architecture"
description: "TOGAF Data Architecture documentation for the DevExp-DevBox Landing Zone Accelerator, covering configuration data models, secrets management, telemetry, and data governance."
author: "DevExp Team"
date: "2026-01-22"
version: "1.0.0"
tags:
  - TOGAF
  - Data Architecture
  - DevExp
  - Key Vault
  - Azure
---

# 🗄️ Data Architecture

> [!NOTE]
> **Target Audience**: Data Architects, Platform Engineers, Security Teams  
> **Reading Time**: ~20 minutes

<details>
<summary>📍 <strong>Document Navigation</strong></summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| [← Business Architecture](01-business-architecture.md) | [Architecture Index](README.md) | [Application Architecture →](03-application-architecture.md) |

</details>

> **TOGAF Layer**: Data Architecture  
> **Version**: 1.0.0  
> **Last Updated**: January 22, 2026  
> **Author**: DevExp Team

---

## 📑 Table of Contents

- [📊 Data Overview](#-data-overview)
- [⚙️ Configuration Data Model](#️-configuration-data-model)
- [🔐 Secrets Management](#-secrets-management)
- [📡 Telemetry & Diagnostics](#-telemetry--diagnostics)
- [🔀 Data Flow Diagrams](#-data-flow-diagrams)
- [🏛️ Data Governance](#️-data-governance)
- [📋 Schema Documentation](#-schema-documentation)
- [📚 References](#-references)
- [📖 Glossary](#-glossary)

---

## 📊 Data Overview

The DevExp-DevBox Landing Zone Accelerator manages several categories of data that flow through the system during deployment and runtime operations. Understanding these data types is essential for security, compliance, and operational management.

### Data Categories

```mermaid
---
title: Data Categories Overview
---
graph TB
    %% ===== CONFIGURATION DATA =====
    subgraph configData["Configuration Data"]
        CD1["Resource Organization<br/>azureResources.yaml"]
        CD2["Security Settings<br/>security.yaml"]
        CD3["Workload Config<br/>devcenter.yaml"]
    end
    
    %% ===== SECRETS & CREDENTIALS =====
    subgraph secretsData["Secrets & Credentials"]
        SC1["GitHub PAT<br/>Key Vault Secret"]
        SC2["Azure AD Tokens<br/>Managed Identity"]
        SC3["Service Principal<br/>OIDC Federation"]
    end
    
    %% ===== TELEMETRY DATA =====
    subgraph telemetryData["Telemetry Data"]
        TD1["Resource Logs<br/>Log Analytics"]
        TD2["Metrics<br/>Azure Monitor"]
        TD3["Diagnostic Data<br/>Azure Diagnostics"]
    end
    
    %% ===== STATE DATA =====
    subgraph stateData["State Data"]
        ST1["Deployment State<br/>azd Environment"]
        ST2["Resource State<br/>Azure RM"]
        ST3["RBAC Assignments<br/>Azure AD"]
    end
    
    %% ===== CLASS DEFINITIONS =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef security fill:#F44336,stroke:#C62828,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    classDef datastore fill:#F59E0B,stroke:#D97706,color:#000000
    
    %% ===== CLASS ASSIGNMENTS =====
    class CD1,CD2,CD3 primary
    class SC1,SC2,SC3 security
    class TD1,TD2,TD3 secondary
    class ST1,ST2,ST3 datastore
    
    %% ===== SUBGRAPH STYLES =====
    style configData fill:#EEF2FF,stroke:#4F46E5,stroke-width:2px
    style secretsData fill:#FEE2E2,stroke:#F44336,stroke-width:2px
    style telemetryData fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style stateData fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px
```

### Data Classification

| Data Type | Classification | Sensitivity | Storage Location | Retention |
|:----------|:--------------:|:-----------:|:-----------------|:----------|
| Resource Organization Config | Internal | Low | Git Repository | Version controlled |
| Security Configuration | Confidential | Medium | Git Repository | Version controlled |
| DevCenter Configuration | Internal | Low | Git Repository | Version controlled |
| GitHub PAT Token | Secret | Critical | Azure Key Vault | 7-90 days (soft delete) |
| Managed Identity Tokens | Secret | Critical | Azure AD | Session-based |
| Deployment Logs | Internal | Medium | Log Analytics | 30-90 days |
| Resource Metrics | Internal | Low | Azure Monitor | 93 days |
| Deployment State | Internal | Medium | azd Environment | Until deleted |

[↑ Back to Top](#️-data-architecture)

---

## ⚙️ Configuration Data Model

### Overview

The accelerator uses YAML-based configuration files with JSON Schema validation to define infrastructure settings. Configuration is loaded at deployment time using Bicep's `loadYamlContent()` function.

### Configuration File Structure

```
infra/settings/
├── resourceOrganization/
│   ├── azureResources.yaml      # Landing zone resource groups
│   └── azureResources.schema.json
├── security/
│   ├── security.yaml            # Key Vault configuration
│   └── security.schema.json
└── workload/
    ├── devcenter.yaml           # DevCenter & projects
    └── devcenter.schema.json
```

### Data Entity Relationship Diagram

```mermaid
---
title: Data Entity Relationship Model
---
erDiagram
    LANDING_ZONES ||--o{ RESOURCE_GROUPS : contains
    RESOURCE_GROUPS ||--o{ RESOURCES : hosts
    
    DEVCENTER ||--o{ PROJECTS : manages
    DEVCENTER ||--o{ CATALOGS : syncs
    DEVCENTER ||--o{ ENVIRONMENT_TYPES : defines
    DEVCENTER ||--|| IDENTITY : has
    
    PROJECTS ||--o{ POOLS : contains
    PROJECTS ||--o{ PROJECT_CATALOGS : syncs
    PROJECTS ||--o{ PROJECT_ENV_TYPES : enables
    PROJECTS ||--|| NETWORK : uses
    PROJECTS ||--|| PROJECT_IDENTITY : has
    
    IDENTITY ||--o{ ROLE_ASSIGNMENTS : grants
    PROJECT_IDENTITY ||--o{ ROLE_ASSIGNMENTS : grants
    
    KEY_VAULT ||--o{ SECRETS : stores
    SECRETS ||--|| CATALOGS : authenticates
    SECRETS ||--|| PROJECT_CATALOGS : authenticates
    
    NETWORK ||--o{ SUBNETS : contains
    NETWORK ||--|| NETWORK_CONNECTION : creates
    NETWORK_CONNECTION ||--|| DEVCENTER : attaches
    
    LANDING_ZONES {
        string security_name
        string monitoring_name
        string workload_name
        object tags
    }
    
    DEVCENTER {
        string name
        string catalogItemSyncEnableStatus
        string microsoftHostedNetworkEnableStatus
        string installAzureMonitorAgentEnableStatus
    }
    
    PROJECTS {
        string name
        string description
        object network
        object identity
        array pools
        array catalogs
        array environmentTypes
    }
    
    KEY_VAULT {
        string name
        boolean enablePurgeProtection
        boolean enableSoftDelete
        int softDeleteRetentionInDays
        boolean enableRbacAuthorization
    }
    
    POOLS {
        string name
        string imageDefinitionName
        string vmSku
    }
```

### Resource Organization Configuration

**File**: `infra/settings/resourceOrganization/azureResources.yaml`

| Property | Type | Description | Example |
|----------|------|-------------|---------|
| `workload.name` | string | Workload resource group name | `devexp-workload` |
| `workload.create` | boolean | Create new or use existing | `true` |
| `workload.tags` | object | Azure resource tags | See tags schema |
| `security.name` | string | Security resource group name | `devexp-security` |
| `security.create` | boolean | Create new or use existing | `true` |
| `monitoring.name` | string | Monitoring resource group name | `devexp-monitoring` |
| `monitoring.create` | boolean | Create new or use existing | `true` |

**Tags Schema**:

```yaml
tags:
  environment: dev|test|staging|prod
  division: string          # Business division
  team: string              # Team name
  project: string           # Project identifier
  costCenter: string        # Cost allocation
  owner: string             # Resource owner
  landingZone: string       # Landing zone type
  resources: string         # Resource type
```

### Security Configuration

**File**: `infra/settings/security/security.yaml`

| Property | Type | Description | Constraints |
|:---------|:-----|:------------|:------------|
| `create` | boolean | Create Key Vault | Required |
| `keyVault.name` | string | Key Vault name prefix | 3-24 chars, alphanumeric |
| `keyVault.description` | string | Purpose description | Optional |
| `keyVault.secretName` | string | Secret name for PAT | Default: `gha-token` |
| `keyVault.enablePurgeProtection` | boolean | Prevent permanent deletion | Recommended: `true` |
| `keyVault.enableSoftDelete` | boolean | Enable recovery period | Recommended: `true` |
| `keyVault.softDeleteRetentionInDays` | integer | Soft delete retention | 7-90 days |
| `keyVault.enableRbacAuthorization` | boolean | Use Azure RBAC | Recommended: `true` |

### DevCenter Configuration

**File**: `infra/settings/workload/devcenter.yaml`

#### Core DevCenter Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | DevCenter resource name |
| `catalogItemSyncEnableStatus` | Enabled\|Disabled | Catalog sync feature |
| `microsoftHostedNetworkEnableStatus` | Enabled\|Disabled | Microsoft-hosted networking |
| `installAzureMonitorAgentEnableStatus` | Enabled\|Disabled | Azure Monitor agent |
| `identity.type` | SystemAssigned\|UserAssigned | Managed identity type |

#### Identity & Role Assignments

```yaml
identity:
  type: "SystemAssigned"
  roleAssignments:
    devCenter:
      - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"  # Contributor
        name: "Contributor"
        scope: "Subscription"
      - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"  # User Access Admin
        name: "User Access Administrator"
        scope: "Subscription"
      - id: "4633458b-17de-408a-b874-0445c86b69e6"  # Key Vault Secrets User
        name: "Key Vault Secrets User"
        scope: "ResourceGroup"
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: "<guid>"
        azureADGroupName: "Platform Engineering Team"
        azureRBACRoles:
          - name: "DevCenter Project Admin"
            id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"
            scope: ResourceGroup
```

#### Project Configuration

```yaml
projects:
  - name: "eShop"
    description: "eShop project"
    network:
      name: eShop
      create: true
      resourceGroupName: "eShop-connectivity-RG"
      virtualNetworkType: Managed|Unmanaged
      addressPrefixes: ["10.0.0.0/16"]
      subnets:
        - name: eShop-subnet
          properties:
            addressPrefix: "10.0.1.0/24"
    pools:
      - name: "backend-engineer"
        imageDefinitionName: "eShop-backend-engineer"
        vmSku: "general_i_32c128gb512ssd_v2"
      - name: "frontend-engineer"
        imageDefinitionName: "eShop-frontend-engineer"
        vmSku: "general_i_16c64gb256ssd_v2"
    catalogs:
      - name: "environments"
        type: environmentDefinition
        sourceControl: gitHub
        visibility: private
        uri: "https://github.com/org/repo.git"
        branch: "main"
        path: "/.devcenter/environments"
```

[↑ Back to Top](#️-data-architecture)

---

## 🔐 Secrets Management

> [!IMPORTANT]
> All secrets are stored in Azure Key Vault with RBAC authorization. Never commit secrets to source control.

### Secret Types

| Secret | Purpose | Storage | Rotation |
|--------|---------|---------|----------|
| **GitHub PAT** | Catalog authentication for private repos | Key Vault | Manual (recommended: 90 days) |
| **Azure DevOps PAT** | ADO catalog authentication | Key Vault | Manual (recommended: 90 days) |
| **Service Principal** | CI/CD deployment | GitHub Secrets / Azure DevOps | OIDC (no rotation needed) |

### Key Vault Architecture

```mermaid
---
title: Key Vault Security Architecture
---
graph TB
    %% ===== KEY VAULT =====
    subgraph kvault["Azure Key Vault"]
        KV["contoso-*****-kv"]
        SEC1["gha-token<br/>GitHub PAT"]
    end
    
    %% ===== ACCESS PATTERNS =====
    subgraph access["Access Patterns"]
        DC["DevCenter<br/>Managed Identity"]
        PROJ["Project<br/>Managed Identity"]
        CICD["CI/CD Pipeline<br/>OIDC"]
    end
    
    %% ===== CONSUMERS =====
    subgraph consumers["Consumers"]
        CAT1["DevCenter<br/>Catalogs"]
        CAT2["Project<br/>Catalogs"]
    end
    
    %% ===== RELATIONSHIPS =====
    DC -->|Key Vault Secrets User| KV
    PROJ -->|Key Vault Secrets User| KV
    CICD -->|Key Vault Secrets Officer| KV
    
    KV -->|stores| SEC1
    SEC1 -->|secretIdentifier| CAT1
    SEC1 -->|secretIdentifier| CAT2
    
    %% ===== CLASS DEFINITIONS =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef security fill:#F44336,stroke:#C62828,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    
    %% ===== CLASS ASSIGNMENTS =====
    class KV primary
    class SEC1 security
    class DC,PROJ,CICD secondary
    class CAT1,CAT2 primary
    
    %% ===== SUBGRAPH STYLES =====
    style kvault fill:#EEF2FF,stroke:#4F46E5,stroke-width:2px
    style access fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style consumers fill:#F3F4F6,stroke:#6B7280,stroke-width:2px
```

### Secret Lifecycle

```mermaid
---
title: Secret Lifecycle Flow
---
sequenceDiagram
    participant Admin as Administrator
    participant GH as GitHub
    participant CICD as CI/CD Pipeline
    participant KV as Key Vault
    participant DC as DevCenter
    participant Cat as Catalog
    
    Admin->>GH: Create PAT with repo scope
    Admin->>CICD: Store PAT as pipeline secret
    CICD->>KV: azd provision (store secret)
    KV-->>CICD: Secret URI returned
    CICD->>DC: Deploy with secretIdentifier
    DC->>Cat: Configure catalog
    
    loop Catalog Sync
        Cat->>KV: Request secret (Managed Identity)
        KV-->>Cat: Return PAT
        Cat->>GH: Authenticate & sync
        GH-->>Cat: Repository content
    end
```

### Secret Access Patterns

| Principal | Role | Scope | Purpose |
|-----------|------|-------|---------|
| DevCenter Managed Identity | Key Vault Secrets User | Security RG | Read PAT for catalog sync |
| Project Managed Identity | Key Vault Secrets User | Security RG | Read PAT for project catalogs |
| DevCenter Managed Identity | Key Vault Secrets Officer | Security RG | Manage secrets if needed |
| CI/CD Service Principal | Deployer (custom) | Key Vault | Initial secret provisioning |

[↑ Back to Top](#️-data-architecture)

---

## 📡 Telemetry & Diagnostics

### Log Analytics Data Collection

```mermaid
---
title: Log Analytics Data Collection Flow
---
graph LR
    %% ===== DATA SOURCES =====
    subgraph dataSources["Data Sources"]
        DC["DevCenter"]
        KV["Key Vault"]
        VNET["Virtual Network"]
        LA["Log Analytics<br/>Workspace"]
    end
    
    %% ===== LOG CATEGORIES =====
    subgraph logCategories["Log Categories"]
        LOGS["All Logs<br/>categoryGroup: allLogs"]
        MET["All Metrics<br/>category: AllMetrics"]
    end
    
    %% ===== ANALYTICS =====
    subgraph analytics["Analytics"]
        QRY["KQL Queries"]
        WBK["Workbooks"]
        ALR["Alerts"]
    end
    
    %% ===== RELATIONSHIPS =====
    DC -->|Diagnostic Settings| LOGS
    KV -->|Diagnostic Settings| LOGS
    VNET -->|Diagnostic Settings| LOGS
    
    DC -->|Diagnostic Settings| MET
    KV -->|Diagnostic Settings| MET
    VNET -->|Diagnostic Settings| MET
    
    LOGS -->|ingests| LA
    MET -->|ingests| LA
    
    LA -->|enables| QRY
    LA -->|enables| WBK
    LA -->|enables| ALR
    
    %% ===== CLASS DEFINITIONS =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    classDef datastore fill:#F59E0B,stroke:#D97706,color:#000000
    classDef external fill:#6B7280,stroke:#4B5563,color:#FFFFFF
    
    %% ===== CLASS ASSIGNMENTS =====
    class LA primary
    class DC,KV,VNET secondary
    class LOGS,MET datastore
    class QRY,WBK,ALR external
    
    %% ===== SUBGRAPH STYLES =====
    style dataSources fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style logCategories fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px
    style analytics fill:#F3F4F6,stroke:#6B7280,stroke-width:2px
```

### Diagnostic Settings Configuration

| Resource | Log Categories | Metrics | Destination |
|----------|---------------|---------|-------------|
| Log Analytics Workspace | allLogs | AllMetrics | Self (workspace) |
| Key Vault | allLogs | AllMetrics | Log Analytics |
| DevCenter | allLogs | AllMetrics | Log Analytics |
| Virtual Network | allLogs | AllMetrics | Log Analytics |

### Telemetry Data Schema

**DevCenter Logs**:

```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DEVCENTER"
| project TimeGenerated, OperationName, ResultType, CallerIpAddress
```

**Key Vault Logs**:

```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| project TimeGenerated, OperationName, ResultType, identity_claim_upn_s
```

[↑ Back to Top](#️-data-architecture)

---

## 🔀 Data Flow Diagrams

### Configuration Loading Flow

```mermaid
---
title: Configuration Loading Flow
---
flowchart TB
    %% ===== SOURCE CONTROL =====
    subgraph sourceControl["Source Control"]
        YAML1["azureResources.yaml"]
        YAML2["security.yaml"]
        YAML3["devcenter.yaml"]
    end
    
    %% ===== BICEP COMPILATION =====
    subgraph bicepCompile["Bicep Compilation"]
        MAIN["main.bicep"]
        LOAD1["loadYamlContent<br/>resourceOrganization"]
        LOAD2["loadYamlContent<br/>security"]
        LOAD3["loadYamlContent<br/>workload"]
    end
    
    %% ===== AZURE RESOURCES =====
    subgraph azureResources["Azure Resources"]
        RG1["Security RG"]
        RG2["Monitoring RG"]
        RG3["Workload RG"]
    end
    
    %% ===== RELATIONSHIPS =====
    YAML1 -->|loads| LOAD1
    YAML2 -->|loads| LOAD2
    YAML3 -->|loads| LOAD3
    
    MAIN -->|invokes| LOAD1
    MAIN -->|invokes| LOAD2
    MAIN -->|invokes| LOAD3
    
    LOAD1 -->|createResourceGroupName| RG1
    LOAD1 -->|createResourceGroupName| RG2
    LOAD1 -->|createResourceGroupName| RG3
    
    LOAD2 -->|keyVault config| RG1
    LOAD3 -->|devCenter config| RG3
    
    %% ===== CLASS DEFINITIONS =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    classDef datastore fill:#F59E0B,stroke:#D97706,color:#000000
    
    %% ===== CLASS ASSIGNMENTS =====
    class MAIN primary
    class YAML1,YAML2,YAML3 datastore
    class LOAD1,LOAD2,LOAD3 secondary
    class RG1,RG2,RG3 primary
    
    %% ===== SUBGRAPH STYLES =====
    style sourceControl fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px
    style bicepCompile fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style azureResources fill:#EEF2FF,stroke:#4F46E5,stroke-width:2px
```

### Secrets Flow Diagram

```mermaid
flowchart TB
    subgraph "Secret Injection"
        ENV[Environment Variable<br/>KEY_VAULT_SECRET]
        AZD[azd provision]
        PARAM[@secure param<br/>secretValue]
    end
    
    subgraph "Secret Storage"
        SEC[security.bicep]
        SECMOD[secret.bicep]
        KV[(Key Vault<br/>gha-token)]
    end
    
    subgraph "Secret Consumption"
        URI[secretIdentifier<br/>URI]
        CAT[catalog.bicep]
        PCAT[projectCatalog.bicep]
    end
    
    ENV --> AZD
    AZD --> PARAM
    PARAM --> SEC
    SEC --> SECMOD
    SECMOD --> KV
    
    KV -->|properties.secretUri| URI
    URI --> CAT
    URI --> PCAT
    
    style KV fill:#D32F2F,color:#fff
    style ENV fill:#FFC107,color:#000
```

### Deployment Data Flow

```mermaid
sequenceDiagram
    participant Git as Git Repository
    participant AZD as Azure Developer CLI
    participant ARM as Azure Resource Manager
    participant RG as Resource Groups
    participant Res as Azure Resources
    participant LA as Log Analytics
    
    Git->>AZD: Clone & load YAML configs
    AZD->>AZD: Compile Bicep templates
    AZD->>ARM: Submit deployment
    ARM->>RG: Create resource groups
    
    par Parallel Deployment
        ARM->>Res: Deploy Log Analytics
        ARM->>Res: Deploy Key Vault
        ARM->>Res: Deploy DevCenter
    end
    
    Res->>LA: Configure diagnostics
    Res-->>AZD: Return outputs
    AZD-->>Git: Store in azd environment
```

---

## Data Governance

### Data Classification Matrix

| Data Element | Classification | Owner | Access Control | Encryption |
|--------------|---------------|-------|----------------|------------|
| YAML Configuration | Internal | Platform Team | Git branch protection | At rest (Git LFS optional) |
| JSON Schemas | Public | Platform Team | Read-only | None required |
| PAT Tokens | Secret | Security Team | Key Vault RBAC | At rest + in transit |
| Deployment Logs | Confidential | Operations | Log Analytics RBAC | At rest |
| Resource Metrics | Internal | Operations | Azure Monitor RBAC | At rest |
| Bicep Templates | Internal | Platform Team | Git branch protection | At rest |

### Data Retention Policies

| Data Type | Retention Period | Justification | Archive Location |
|-----------|------------------|---------------|------------------|
| Deployment Logs | 90 days | Compliance/troubleshooting | Log Analytics |
| Key Vault Soft Delete | 7-90 days | Recovery window | Key Vault |
| Resource Metrics | 93 days | Azure default | Azure Monitor |
| Git History | Indefinite | Version control | Git repository |
| azd Environment State | Until deleted | Active deployments | Local/.azure |

### Compliance Considerations

| Requirement | Implementation | Evidence |
|-------------|----------------|----------|
| **Data Encryption at Rest** | Azure Storage encryption, Key Vault encryption | Azure Security Center |
| **Data Encryption in Transit** | TLS 1.2+ for all Azure services | Network policies |
| **Access Logging** | Key Vault audit logs, Azure Activity Log | Log Analytics queries |
| **Data Residency** | Region-specific deployment | Bicep location parameter |
| **Right to Erasure** | Key Vault purge, resource deletion | Deletion scripts |

[↑ Back to Top](#️-data-architecture)

---

## 📋 Schema Documentation

### JSON Schema References

<details>
<summary><strong>📜 Security Schema (<code>security.schema.json</code>)</strong></summary>

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Azure Key Vault Security Configuration",
  "type": "object",
  "required": ["create", "keyVault"],
  "properties": {
    "create": { "type": "boolean" },
    "keyVault": {
      "type": "object",
      "required": ["name", "tags"],
      "properties": {
        "name": {
          "type": "string",
          "pattern": "^[a-zA-Z0-9-]{3,24}$",
          "minLength": 3,
          "maxLength": 24
        },
        "enablePurgeProtection": { "type": "boolean" },
        "enableSoftDelete": { "type": "boolean" },
        "softDeleteRetentionInDays": {
          "type": "integer",
          "minimum": 7,
          "maximum": 90
        },
        "enableRbacAuthorization": { "type": "boolean" }
      }
    }
  }
}
```

</details>

<details>
<summary><strong>📜 DevCenter Schema (<code>devcenter.schema.json</code>) - Key Definitions</strong></summary>

```json
{
  "definitions": {
    "roleAssignment": {
      "type": "object",
      "properties": {
        "id": { "type": "string", "pattern": "^[a-fA-F0-9-]{36}$" },
        "name": { "type": "string" },
        "scope": { "enum": ["Subscription", "ResourceGroup", "Project"] }
      }
    },
    "catalog": {
      "type": "object",
      "required": ["name", "type", "uri"],
      "properties": {
        "name": { "type": "string" },
        "type": { "enum": ["gitHub", "adoGit", "environmentDefinition", "imageDefinition"] },
        "visibility": { "enum": ["public", "private"] },
        "uri": { "type": "string", "format": "uri" },
        "branch": { "type": "string" },
        "path": { "type": "string" }
      }
    },
    "pool": {
      "type": "object",
      "required": ["name", "imageDefinitionName", "vmSku"],
      "properties": {
        "name": { "type": "string" },
        "imageDefinitionName": { "type": "string" },
        "vmSku": { "type": "string" }
      }
    }
  }
}
```

</details>

### Schema Validation

Schemas are validated at authoring time using the `yaml-language-server` directive:

```yaml
# yaml-language-server: $schema=./security.schema.json
```

[↑ Back to Top](#️-data-architecture)

---

## 📚 References

### Internal Documents

- [Business Architecture](01-business-architecture.md) - Business context and stakeholders
- [Application Architecture](03-application-architecture.md) - Module design and Bicep structure
- [Technology Architecture](04-technology-architecture.md) - Azure services and infrastructure
- [Security Architecture](05-security-architecture.md) - Security controls and secrets management

### External References

- [Azure Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Log Analytics Workspace Design](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/workspace-design)
- [Bicep loadYamlContent Function](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-files#loadyamlcontent)
- [JSON Schema Specification](https://json-schema.org/specification.html)

[↑ Back to Top](#️-data-architecture)

---

## 📖 Glossary

| Term | Definition |
|------|------------|
| **loadYamlContent()** | Bicep function that loads YAML files as objects at compile time |
| **Secret Identifier** | URI to a specific version of a secret in Azure Key Vault |
| **Diagnostic Settings** | Azure configuration for routing logs and metrics to destinations |
| **Soft Delete** | Key Vault feature allowing recovery of deleted secrets within retention period |
| **Purge Protection** | Key Vault feature preventing permanent deletion during soft delete period |
| **RBAC Authorization** | Key Vault access control using Azure Role-Based Access Control instead of access policies |

[↑ Back to Top](#️-data-architecture)

---

## 📎 Related Documents

<details>
<summary><strong>TOGAF Architecture Series</strong></summary>

| Document | Description |
|:---------|:------------|
| [📊 Business Architecture](01-business-architecture.md) | Stakeholder analysis, capabilities, value streams |
| 🗄️ **Data Architecture** | *You are here* |
| [🏛️ Application Architecture](03-application-architecture.md) | Bicep module design, dependencies, patterns |
| [⚙️ Technology Architecture](04-technology-architecture.md) | Azure services, CI/CD, deployment tools |
| [🔐 Security Architecture](05-security-architecture.md) | Threat model, RBAC, compliance controls |

</details>

---

<div align="center">

**[← Previous: Business Architecture](01-business-architecture.md)** | **[Next: Application Architecture →](03-application-architecture.md)**

---

*Document generated as part of TOGAF Architecture Documentation for DevExp-DevBox Landing Zone Accelerator*

</div>
