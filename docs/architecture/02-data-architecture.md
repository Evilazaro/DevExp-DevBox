# Data Architecture

> **DevExp-DevBox Landing Zone Accelerator**

| Metadata         | Value                     |
| ---------------- | ------------------------- |
| **Version**      | 1.0.0                     |
| **Last Updated** | January 22, 2026          |
| **Author**       | Platform Engineering Team |
| **Status**       | Active                    |

---

## Table of Contents

- [Data Overview](#data-overview)
- [Configuration Data Model](#configuration-data-model)
- [Secrets Management](#secrets-management)
- [Telemetry & Diagnostics](#telemetry--diagnostics)
- [Data Flow Diagrams](#data-flow-diagrams)
- [Data Governance](#data-governance)
- [Schema Documentation](#schema-documentation)
- [References](#references)
- [Glossary](#glossary)

---

## Data Overview

The DevExp-DevBox Landing Zone Accelerator manages several categories of data
that flow through the system during deployment and operation.

### Data Categories

| Category               | Type                    | Storage Location                   | Sensitivity | Lifecycle           |
| ---------------------- | ----------------------- | ---------------------------------- | ----------- | ------------------- |
| **Configuration Data** | YAML files              | Git repository (`infra/settings/`) | Low         | Version controlled  |
| **Secrets**            | PAT tokens, credentials | Azure Key Vault                    | High        | Managed rotation    |
| **Telemetry**          | Logs, metrics           | Log Analytics Workspace            | Medium      | 30-90 day retention |
| **State**              | Deployment outputs      | Azure Resource Manager             | Low         | Deployment lifetime |
| **Identity Data**      | Role assignments        | Azure RBAC                         | Medium      | Resource lifetime   |

### Data Entity Overview

```mermaid
erDiagram
    AZURE_RESOURCES ||--o{ RESOURCE_GROUP : contains
    RESOURCE_GROUP ||--o{ DEVCENTER : hosts
    RESOURCE_GROUP ||--o{ KEY_VAULT : hosts
    RESOURCE_GROUP ||--o{ LOG_ANALYTICS : hosts

    DEVCENTER ||--o{ PROJECT : manages
    DEVCENTER ||--o{ CATALOG : references
    DEVCENTER ||--o{ ENVIRONMENT_TYPE : defines

    PROJECT ||--o{ POOL : contains
    PROJECT ||--o{ PROJECT_CATALOG : references
    PROJECT ||--o{ PROJECT_ENV_TYPE : enables

    POOL ||--|| IMAGE_DEFINITION : uses
    CATALOG ||--o{ IMAGE_DEFINITION : provides

    KEY_VAULT ||--o{ SECRET : stores
    CATALOG }|--|| SECRET : authenticates_with

    LOG_ANALYTICS ||--o{ DIAGNOSTIC_SETTING : receives_from
    DEVCENTER ||--|| DIAGNOSTIC_SETTING : sends_to
    KEY_VAULT ||--|| DIAGNOSTIC_SETTING : sends_to
```

---

## Configuration Data Model

### Configuration File Hierarchy

```
infra/settings/
├── resourceOrganization/
│   ├── azureResources.yaml      # Landing zone resource groups
│   └── azureResources.schema.json
├── security/
│   ├── security.yaml            # Key Vault configuration
│   └── security.schema.json
└── workload/
    ├── devcenter.yaml           # DevCenter, projects, pools
    └── devcenter.schema.json
```

### Resource Organization Configuration (`azureResources.yaml`)

Defines the landing zone resource group structure following Azure Landing Zone
principles.

```mermaid
classDiagram
    class AzureResources {
        +workload: LandingZone
        +security: LandingZone
        +monitoring: LandingZone
    }

    class LandingZone {
        +create: boolean
        +name: string
        +description: string
        +tags: Tags
    }

    class Tags {
        +environment: string
        +division: string
        +team: string
        +project: string
        +costCenter: string
        +owner: string
        +landingZone: string
        +resources: string
    }

    AzureResources *-- LandingZone : contains 3
    LandingZone *-- Tags : has
```

#### Data Model Details

| Entity          | Field         | Type    | Required | Description                            |
| --------------- | ------------- | ------- | -------- | -------------------------------------- |
| **LandingZone** | `create`      | boolean | Yes      | Whether to create the resource group   |
|                 | `name`        | string  | Yes      | Base name for the resource group       |
|                 | `description` | string  | Yes      | Purpose description                    |
|                 | `tags`        | object  | Yes      | Resource tags                          |
| **Tags**        | `environment` | string  | Yes      | Deployment environment (dev/test/prod) |
|                 | `division`    | string  | Yes      | Business division                      |
|                 | `team`        | string  | Yes      | Owning team                            |
|                 | `project`     | string  | Yes      | Project name                           |
|                 | `costCenter`  | string  | Yes      | Cost allocation center                 |
|                 | `owner`       | string  | Yes      | Resource owner                         |

### Security Configuration (`security.yaml`)

Defines Azure Key Vault settings for secrets management.

```mermaid
classDiagram
    class SecurityConfig {
        +create: boolean
        +keyVault: KeyVaultConfig
    }

    class KeyVaultConfig {
        +name: string
        +description: string
        +secretName: string
        +enablePurgeProtection: boolean
        +enableSoftDelete: boolean
        +softDeleteRetentionInDays: integer
        +enableRbacAuthorization: boolean
        +tags: Tags
    }

    SecurityConfig *-- KeyVaultConfig : has
    KeyVaultConfig *-- Tags : has
```

#### Security Configuration Details

| Field                       | Type    | Constraints              | Default     | Description                        |
| --------------------------- | ------- | ------------------------ | ----------- | ---------------------------------- |
| `name`                      | string  | 3-24 chars, alphanumeric | -           | Globally unique Key Vault name     |
| `secretName`                | string  | -                        | `gha-token` | Name for the stored secret         |
| `enablePurgeProtection`     | boolean | -                        | `true`      | Prevents permanent deletion        |
| `enableSoftDelete`          | boolean | -                        | `true`      | Enables recovery window            |
| `softDeleteRetentionInDays` | integer | 7-90                     | `7`         | Retention period for deleted items |
| `enableRbacAuthorization`   | boolean | -                        | `true`      | Use Azure RBAC vs access policies  |

### DevCenter Configuration (`devcenter.yaml`)

The most complex configuration defining the entire workload structure.

```mermaid
classDiagram
    class DevCenterConfig {
        +name: string
        +catalogItemSyncEnableStatus: Status
        +microsoftHostedNetworkEnableStatus: Status
        +installAzureMonitorAgentEnableStatus: Status
        +identity: Identity
        +catalogs: Catalog[]
        +environmentTypes: EnvironmentType[]
        +projects: Project[]
        +tags: Tags
    }

    class Identity {
        +type: string
        +roleAssignments: RoleAssignments
    }

    class RoleAssignments {
        +devCenter: RBACRole[]
        +orgRoleTypes: OrgRoleType[]
    }

    class Project {
        +name: string
        +description: string
        +network: NetworkConfig
        +identity: ProjectIdentity
        +pools: Pool[]
        +environmentTypes: EnvironmentType[]
        +catalogs: ProjectCatalog[]
        +tags: Tags
    }

    class Pool {
        +name: string
        +imageDefinitionName: string
        +vmSku: string
    }

    class Catalog {
        +name: string
        +type: CatalogType
        +visibility: Visibility
        +uri: string
        +branch: string
        +path: string
    }

    class NetworkConfig {
        +name: string
        +create: boolean
        +resourceGroupName: string
        +virtualNetworkType: string
        +addressPrefixes: string[]
        +subnets: Subnet[]
        +tags: Tags
    }

    DevCenterConfig *-- Identity
    DevCenterConfig *-- "1..*" Catalog
    DevCenterConfig *-- "1..*" Project
    Identity *-- RoleAssignments
    Project *-- NetworkConfig
    Project *-- "1..*" Pool
    Project *-- "0..*" Catalog : projectCatalogs
```

#### DevCenter Entity Details

| Entity              | Field                                  | Type             | Description                                        |
| ------------------- | -------------------------------------- | ---------------- | -------------------------------------------------- |
| **DevCenterConfig** | `name`                                 | string           | DevCenter resource name                            |
|                     | `catalogItemSyncEnableStatus`          | Enabled/Disabled | Auto-sync catalog items                            |
|                     | `microsoftHostedNetworkEnableStatus`   | Enabled/Disabled | Use Microsoft-hosted networks                      |
|                     | `installAzureMonitorAgentEnableStatus` | Enabled/Disabled | Install monitoring agent on Dev Boxes              |
| **Project**         | `name`                                 | string           | Project identifier                                 |
|                     | `description`                          | string           | Project description                                |
|                     | `network`                              | NetworkConfig    | Network connectivity settings                      |
|                     | `pools`                                | Pool[]           | Dev Box pool definitions                           |
| **Pool**            | `name`                                 | string           | Pool identifier (e.g., `backend-engineer`)         |
|                     | `imageDefinitionName`                  | string           | Reference to catalog image                         |
|                     | `vmSku`                                | string           | Azure VM SKU (e.g., `general_i_32c128gb512ssd_v2`) |
| **Catalog**         | `type`                                 | gitHub/adoGit    | Source control type                                |
|                     | `visibility`                           | public/private   | Repository visibility                              |
|                     | `uri`                                  | string           | Repository URL                                     |
|                     | `branch`                               | string           | Branch to sync                                     |
|                     | `path`                                 | string           | Path within repository                             |

---

## Secrets Management

### Secret Types

| Secret                    | Storage                 | Purpose                        | Consumers                       | Rotation                      |
| ------------------------- | ----------------------- | ------------------------------ | ------------------------------- | ----------------------------- |
| **GitHub PAT**            | Key Vault (`gha-token`) | Private catalog authentication | DevCenter catalogs              | Manual (recommended: 90 days) |
| **Azure DevOps PAT**      | Key Vault               | ADO catalog authentication     | DevCenter catalogs              | Manual (recommended: 90 days) |
| **Federated Credentials** | Azure AD                | CI/CD authentication           | GitHub Actions, Azure Pipelines | Automatic                     |

### Secrets Flow Diagram

```mermaid
sequenceDiagram
    participant User as Platform Engineer
    participant GH as GitHub/ADO
    participant CLI as Azure CLI/azd
    participant KV as Key Vault
    participant DC as DevCenter
    participant Cat as Catalog

    Note over User,Cat: Secret Provisioning Flow

    User->>GH: Generate PAT token
    User->>CLI: azd provision (with secret)
    CLI->>KV: Create/Update secret
    KV-->>CLI: Secret URI returned
    CLI->>DC: Configure DevCenter
    DC->>Cat: Create catalog with secret reference

    Note over User,Cat: Secret Consumption Flow

    Cat->>KV: Request secret (via managed identity)
    KV->>KV: Validate RBAC permissions
    KV-->>Cat: Return secret value
    Cat->>GH: Authenticate to repository
    GH-->>Cat: Return catalog content
```

### Key Vault Access Model

```mermaid
flowchart TD
    subgraph Identity["Identity Sources"]
        DC_MI[DevCenter<br/>Managed Identity]
        PROJ_MI[Project<br/>Managed Identity]
        ADMIN[Platform Engineers<br/>Azure AD Group]
    end

    subgraph KV["Key Vault"]
        SECRET[gha-token<br/>Secret]
    end

    subgraph Roles["RBAC Roles"]
        R1[Key Vault<br/>Secrets User]
        R2[Key Vault<br/>Secrets Officer]
    end

    DC_MI --> R1
    DC_MI --> R2
    PROJ_MI --> R1
    PROJ_MI --> R2
    ADMIN --> R2

    R1 --> |Get, List| SECRET
    R2 --> |Get, List, Set, Delete| SECRET
```

### Secret Security Controls

| Control                | Implementation                       | Purpose                                     |
| ---------------------- | ------------------------------------ | ------------------------------------------- |
| **RBAC Authorization** | `enableRbacAuthorization: true`      | Granular access control via Azure RBAC      |
| **Soft Delete**        | `enableSoftDelete: true`             | Recover accidentally deleted secrets        |
| **Purge Protection**   | `enablePurgeProtection: true`        | Prevent permanent deletion during retention |
| **Retention Period**   | `softDeleteRetentionInDays: 7`       | Recovery window for deleted secrets         |
| **Diagnostic Logging** | Log Analytics integration            | Audit all secret operations                 |
| **Managed Identities** | SystemAssigned on DevCenter/Projects | Eliminate credential storage in code        |

---

## Telemetry & Diagnostics

### Log Analytics Data Collection

```mermaid
flowchart LR
    subgraph Sources["Data Sources"]
        DC[DevCenter]
        KV[Key Vault]
        VNET[Virtual Network]
        LA_SELF[Log Analytics]
    end

    subgraph LA["Log Analytics Workspace"]
        LOGS[Logs]
        METRICS[Metrics]
        SOLUTIONS[Solutions]
    end

    subgraph Outputs["Outputs"]
        ALERTS[Alerts]
        DASHBOARDS[Dashboards]
        QUERIES[KQL Queries]
    end

    DC -->|allLogs, AllMetrics| LOGS
    KV -->|allLogs, AllMetrics| LOGS
    VNET -->|allLogs, AllMetrics| LOGS
    LA_SELF -->|allLogs, AllMetrics| LOGS

    LOGS --> ALERTS
    LOGS --> DASHBOARDS
    METRICS --> DASHBOARDS
    LOGS --> QUERIES
```

### Diagnostic Settings Configuration

All resources deploy with standardized diagnostic settings:

| Resource            | Log Categories | Metric Categories | Destination             |
| ------------------- | -------------- | ----------------- | ----------------------- |
| **DevCenter**       | allLogs        | AllMetrics        | Log Analytics Workspace |
| **Key Vault**       | allLogs        | AllMetrics        | Log Analytics Workspace |
| **Virtual Network** | allLogs        | AllMetrics        | Log Analytics Workspace |
| **Log Analytics**   | allLogs        | AllMetrics        | Self (workspace)        |

### Telemetry Data Model

```mermaid
erDiagram
    LOG_ANALYTICS_WORKSPACE ||--o{ AZURE_DIAGNOSTICS : receives
    LOG_ANALYTICS_WORKSPACE ||--o{ AZURE_METRICS : receives
    LOG_ANALYTICS_WORKSPACE ||--|| AZURE_ACTIVITY_SOLUTION : has

    AZURE_DIAGNOSTICS {
        string TimeGenerated
        string ResourceId
        string Category
        string OperationName
        string ResultType
        string Properties
    }

    AZURE_METRICS {
        string TimeGenerated
        string ResourceId
        string MetricName
        float Total
        float Average
        float Maximum
        float Minimum
    }
```

### Data Retention

| Data Type         | Default Retention | Configurable      | Purpose                     |
| ----------------- | ----------------- | ----------------- | --------------------------- |
| **Logs**          | 30 days           | Yes (30-730 days) | Operational troubleshooting |
| **Metrics**       | 93 days           | No                | Performance analysis        |
| **Activity Logs** | 90 days           | No                | Audit trail                 |
| **Security Logs** | 90 days           | Yes               | Compliance                  |

---

## Data Flow Diagrams

### Configuration Loading Flow

```mermaid
flowchart TD
    subgraph Git["Git Repository"]
        YAML1[azureResources.yaml]
        YAML2[security.yaml]
        YAML3[devcenter.yaml]
    end

    subgraph Bicep["Bicep Processing"]
        MAIN[main.bicep]
        LOAD1["loadYamlContent()<br/>resourceOrganization"]
        LOAD2["loadYamlContent()<br/>security"]
        LOAD3["loadYamlContent()<br/>workload"]
    end

    subgraph Modules["Module Deployment"]
        MOD1[logAnalytics.bicep]
        MOD2[security.bicep]
        MOD3[workload.bicep]
    end

    subgraph Azure["Azure Resources"]
        RG[Resource Groups]
        LA[Log Analytics]
        KV[Key Vault]
        DC[DevCenter]
    end

    YAML1 --> LOAD1
    YAML2 --> LOAD2
    YAML3 --> LOAD3

    MAIN --> LOAD1
    MAIN --> LOAD2
    MAIN --> LOAD3

    LOAD1 --> MOD1
    LOAD1 --> MOD2
    LOAD1 --> MOD3

    LOAD2 --> MOD2
    LOAD3 --> MOD3

    MOD1 --> LA
    MOD2 --> KV
    MOD3 --> DC

    MAIN --> RG
```

### Deployment Data Flow

```mermaid
flowchart LR
    subgraph Input["Input Data"]
        ENV[Environment Name]
        LOC[Location]
        SECRET[Secret Value]
    end

    subgraph Transform["Parameter Transformation"]
        SUFFIX["resourceNameSuffix =<br/>{env}-{location}-RG"]
        RGNAMES["createResourceGroupName =<br/>{zone.name}-{suffix}"]
    end

    subgraph Output["Output Resources"]
        SEC_RG[Security RG]
        MON_RG[Monitoring RG]
        WRK_RG[Workload RG]
    end

    ENV --> SUFFIX
    LOC --> SUFFIX
    SUFFIX --> RGNAMES
    RGNAMES --> SEC_RG
    RGNAMES --> MON_RG
    RGNAMES --> WRK_RG
```

### Cross-Module Data Dependencies

```mermaid
flowchart TD
    subgraph main["main.bicep (Subscription Scope)"]
        M_IN[/"Parameters:<br/>location, secretValue,<br/>environmentName"/]
    end

    subgraph monitoring["monitoring module"]
        LA[Log Analytics]
        LA_OUT[/"Output:<br/>AZURE_LOG_ANALYTICS_WORKSPACE_ID"/]
    end

    subgraph security["security module"]
        KV[Key Vault + Secret]
        SEC_OUT[/"Output:<br/>AZURE_KEY_VAULT_SECRET_IDENTIFIER"/]
    end

    subgraph workload["workload module"]
        DC[DevCenter]
        PROJ[Projects]
    end

    M_IN --> LA
    LA --> LA_OUT

    LA_OUT -->|logAnalyticsId| KV
    M_IN -->|secretValue| KV
    KV --> SEC_OUT

    LA_OUT -->|logAnalyticsId| DC
    SEC_OUT -->|secretIdentifier| DC

    DC --> PROJ
```

---

## Data Governance

### Data Classification

| Classification   | Examples                     | Controls              | Access                |
| ---------------- | ---------------------------- | --------------------- | --------------------- |
| **Public**       | Documentation, schemas       | Version control       | Anyone                |
| **Internal**     | Configuration YAML, tags     | Git repository        | Organization          |
| **Confidential** | PAT tokens, credentials      | Key Vault + RBAC      | Authorized identities |
| **Restricted**   | Tenant IDs, subscription IDs | Environment variables | CI/CD pipelines       |

### Compliance Considerations

| Framework        | Requirement        | Implementation                             |
| ---------------- | ------------------ | ------------------------------------------ |
| **SOC 2**        | Access logging     | Key Vault diagnostic logs to Log Analytics |
| **ISO 27001**    | Secrets encryption | Key Vault with software-protected keys     |
| **GDPR**         | Data minimization  | No PII in configuration files              |
| **Azure Policy** | Tagging compliance | Mandatory tags on all resources            |

### Data Lineage

```mermaid
flowchart LR
    subgraph Source["Source of Truth"]
        GIT[Git Repository]
    end

    subgraph CI["CI/CD"]
        GHA[GitHub Actions]
        ADO[Azure DevOps]
    end

    subgraph Deploy["Deployment"]
        AZD[azd CLI]
        ARM[ARM/Bicep]
    end

    subgraph Runtime["Runtime"]
        AZ[Azure Resources]
    end

    subgraph Audit["Audit Trail"]
        LA[Log Analytics]
        ACT[Activity Log]
    end

    GIT -->|Push| GHA
    GIT -->|Push| ADO
    GHA -->|azd provision| AZD
    ADO -->|azd provision| AZD
    AZD -->|Deploy| ARM
    ARM -->|Create/Update| AZ
    AZ -->|Diagnostics| LA
    AZ -->|Operations| ACT
```

### Data Quality Rules

| Rule                   | Enforcement                   | Validation                         |
| ---------------------- | ----------------------------- | ---------------------------------- |
| **Schema Validation**  | JSON Schema files             | YAML files must conform to schemas |
| **Required Fields**    | Schema `required` arrays      | Deployment fails if missing        |
| **Value Constraints**  | Schema patterns, enums        | Invalid values rejected            |
| **Naming Conventions** | Bicep `@minLength/@maxLength` | Enforced at deployment             |
| **Tag Requirements**   | Azure Policy                  | Post-deployment compliance         |

---

## Schema Documentation

### JSON Schema Files

#### `azureResources.schema.json`

Validates landing zone resource group configuration.

| Property Path       | Type    | Constraints | Description          |
| ------------------- | ------- | ----------- | -------------------- |
| `workload.create`   | boolean | Required    | Create workload RG   |
| `workload.name`     | string  | Required    | RG base name         |
| `workload.tags`     | object  | Required    | Resource tags        |
| `security.create`   | boolean | Required    | Create security RG   |
| `security.name`     | string  | Required    | RG base name         |
| `monitoring.create` | boolean | Required    | Create monitoring RG |
| `monitoring.name`   | string  | Required    | RG base name         |

#### `security.schema.json`

Validates Key Vault security configuration.

| Property Path                        | Type    | Constraints                                 | Description      |
| ------------------------------------ | ------- | ------------------------------------------- | ---------------- |
| `create`                             | boolean | Required                                    | Create Key Vault |
| `keyVault.name`                      | string  | 3-24 chars, pattern: `^[a-zA-Z0-9-]{3,24}$` | KV name          |
| `keyVault.enablePurgeProtection`     | boolean | -                                           | Purge protection |
| `keyVault.softDeleteRetentionInDays` | integer | 7-90                                        | Retention days   |
| `keyVault.tags.environment`          | string  | enum: dev/test/staging/prod                 | Environment tag  |

#### `devcenter.schema.json`

Validates DevCenter workload configuration.

| Property Path                          | Type   | Constraints                            | Description           |
| -------------------------------------- | ------ | -------------------------------------- | --------------------- |
| `name`                                 | string | minLength: 1                           | DevCenter name        |
| `identity.type`                        | string | enum: SystemAssigned/UserAssigned/etc. | Identity type         |
| `catalogs[].type`                      | string | -                                      | Catalog source type   |
| `catalogs[].visibility`                | string | enum: public/private                   | Repository visibility |
| `projects[].pools[].vmSku`             | string | -                                      | VM SKU for pool       |
| `projects[].network.addressPrefixes[]` | string | CIDR pattern                           | VNet address space    |

### Schema Validation Flow

```mermaid
flowchart TD
    YAML[YAML Configuration File]
    SCHEMA[JSON Schema]
    VALIDATOR[YAML Language Server]

    YAML --> VALIDATOR
    SCHEMA --> VALIDATOR

    VALIDATOR -->|Valid| SUCCESS[✅ Proceed to Deployment]
    VALIDATOR -->|Invalid| ERROR[❌ Validation Errors]

    ERROR --> FIX[Fix Configuration]
    FIX --> YAML
```

---

## References

### External References

| Reference                      | URL                                                                         | Description       |
| ------------------------------ | --------------------------------------------------------------------------- | ----------------- |
| Azure Key Vault Best Practices | https://learn.microsoft.com/azure/key-vault/general/best-practices          | Security guidance |
| Log Analytics Documentation    | https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-overview | Monitoring setup  |
| JSON Schema Specification      | https://json-schema.org/specification                                       | Schema validation |

### Related Architecture Documents

| Document                 | Path                                                               | Description                       |
| ------------------------ | ------------------------------------------------------------------ | --------------------------------- |
| Business Architecture    | [01-business-architecture.md](./01-business-architecture.md)       | Business context and stakeholders |
| Application Architecture | [03-application-architecture.md](./03-application-architecture.md) | Bicep module architecture         |
| Technology Architecture  | [04-technology-architecture.md](./04-technology-architecture.md)   | Azure services and infrastructure |

---

## Glossary

| Term                    | Definition                                                                     |
| ----------------------- | ------------------------------------------------------------------------------ |
| **loadYamlContent()**   | Bicep function that loads YAML files as typed objects at compile time          |
| **Diagnostic Settings** | Azure configuration that routes logs and metrics to destinations               |
| **RBAC Authorization**  | Key Vault access model using Azure role assignments instead of access policies |
| **Soft Delete**         | Feature that retains deleted Key Vault objects for recovery                    |
| **Purge Protection**    | Feature that prevents permanent deletion during retention period               |
| **PAT**                 | Personal Access Token for Git repository authentication                        |
| **Managed Identity**    | Azure AD identity automatically managed by Azure for service authentication    |
| **KQL**                 | Kusto Query Language used for Log Analytics queries                            |

---

_This document follows TOGAF Architecture Development Method (ADM) principles
and aligns with the Data Architecture domain of the BDAT framework._
