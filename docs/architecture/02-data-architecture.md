# Data Architecture

> **TOGAF Layer**: Data Architecture  
> **Version**: 1.0.0  
> **Last Updated**: January 22, 2026  
> **Author**: DevExp Team

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

The DevExp-DevBox Landing Zone Accelerator manages several categories of data that flow through the system during deployment and runtime operations. Understanding these data types is essential for security, compliance, and operational management.

### Data Categories

```mermaid
graph TB
    subgraph "Configuration Data"
        CD1[Resource Organization<br/>azureResources.yaml]
        CD2[Security Settings<br/>security.yaml]
        CD3[Workload Config<br/>devcenter.yaml]
    end
    
    subgraph "Secrets & Credentials"
        SC1[GitHub PAT<br/>Key Vault Secret]
        SC2[Azure AD Tokens<br/>Managed Identity]
        SC3[Service Principal<br/>OIDC Federation]
    end
    
    subgraph "Telemetry Data"
        TD1[Resource Logs<br/>Log Analytics]
        TD2[Metrics<br/>Azure Monitor]
        TD3[Diagnostic Data<br/>Azure Diagnostics]
    end
    
    subgraph "State Data"
        ST1[Deployment State<br/>azd Environment]
        ST2[Resource State<br/>Azure RM]
        ST3[RBAC Assignments<br/>Azure AD]
    end
    
    style CD1 fill:#E3F2FD
    style CD2 fill:#E3F2FD
    style CD3 fill:#E3F2FD
    style SC1 fill:#FFEBEE
    style SC2 fill:#FFEBEE
    style SC3 fill:#FFEBEE
    style TD1 fill:#E8F5E9
    style TD2 fill:#E8F5E9
    style TD3 fill:#E8F5E9
    style ST1 fill:#FFF3E0
    style ST2 fill:#FFF3E0
    style ST3 fill:#FFF3E0
```

### Data Classification

| Data Type | Classification | Sensitivity | Storage Location | Retention |
|-----------|---------------|-------------|------------------|-----------|
| Resource Organization Config | Internal | Low | Git Repository | Version controlled |
| Security Configuration | Confidential | Medium | Git Repository | Version controlled |
| DevCenter Configuration | Internal | Low | Git Repository | Version controlled |
| GitHub PAT Token | Secret | Critical | Azure Key Vault | 7-90 days (soft delete) |
| Managed Identity Tokens | Secret | Critical | Azure AD | Session-based |
| Deployment Logs | Internal | Medium | Log Analytics | 30-90 days |
| Resource Metrics | Internal | Low | Azure Monitor | 93 days |
| Deployment State | Internal | Medium | azd Environment | Until deleted |

---

## Configuration Data Model

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
|----------|------|-------------|-------------|
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

---

## Secrets Management

### Secret Types

| Secret | Purpose | Storage | Rotation |
|--------|---------|---------|----------|
| **GitHub PAT** | Catalog authentication for private repos | Key Vault | Manual (recommended: 90 days) |
| **Azure DevOps PAT** | ADO catalog authentication | Key Vault | Manual (recommended: 90 days) |
| **Service Principal** | CI/CD deployment | GitHub Secrets / Azure DevOps | OIDC (no rotation needed) |

### Key Vault Architecture

```mermaid
graph TB
    subgraph "Azure Key Vault"
        KV[contoso-*****-kv]
        SEC1[gha-token<br/>GitHub PAT]
    end
    
    subgraph "Access Patterns"
        DC[DevCenter<br/>Managed Identity]
        PROJ[Project<br/>Managed Identity]
        CICD[CI/CD Pipeline<br/>OIDC]
    end
    
    subgraph "Consumers"
        CAT1[DevCenter<br/>Catalogs]
        CAT2[Project<br/>Catalogs]
    end
    
    DC -->|Key Vault Secrets User| KV
    PROJ -->|Key Vault Secrets User| KV
    CICD -->|Key Vault Secrets Officer| KV
    
    KV --> SEC1
    SEC1 -->|secretIdentifier| CAT1
    SEC1 -->|secretIdentifier| CAT2
    
    style KV fill:#0078D4,color:#fff
    style SEC1 fill:#D32F2F,color:#fff
```

### Secret Lifecycle

```mermaid
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

---

## Telemetry & Diagnostics

### Log Analytics Data Collection

```mermaid
graph LR
    subgraph "Data Sources"
        DC[DevCenter]
        KV[Key Vault]
        VNET[Virtual Network]
        LA[Log Analytics<br/>Workspace]
    end
    
    subgraph "Log Categories"
        LOGS[All Logs<br/>categoryGroup: allLogs]
        MET[All Metrics<br/>category: AllMetrics]
    end
    
    subgraph "Analytics"
        QRY[KQL Queries]
        WBK[Workbooks]
        ALR[Alerts]
    end
    
    DC -->|Diagnostic Settings| LOGS
    KV -->|Diagnostic Settings| LOGS
    VNET -->|Diagnostic Settings| LOGS
    
    DC -->|Diagnostic Settings| MET
    KV -->|Diagnostic Settings| MET
    VNET -->|Diagnostic Settings| MET
    
    LOGS --> LA
    MET --> LA
    
    LA --> QRY
    LA --> WBK
    LA --> ALR
    
    style LA fill:#68217A,color:#fff
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

---

## Data Flow Diagrams

### Configuration Loading Flow

```mermaid
flowchart TB
    subgraph "Source Control"
        YAML1[azureResources.yaml]
        YAML2[security.yaml]
        YAML3[devcenter.yaml]
    end
    
    subgraph "Bicep Compilation"
        MAIN[main.bicep]
        LOAD1[loadYamlContent<br/>resourceOrganization]
        LOAD2[loadYamlContent<br/>security]
        LOAD3[loadYamlContent<br/>workload]
    end
    
    subgraph "Azure Resources"
        RG1[Security RG]
        RG2[Monitoring RG]
        RG3[Workload RG]
    end
    
    YAML1 --> LOAD1
    YAML2 --> LOAD2
    YAML3 --> LOAD3
    
    MAIN --> LOAD1
    MAIN --> LOAD2
    MAIN --> LOAD3
    
    LOAD1 -->|createResourceGroupName| RG1
    LOAD1 -->|createResourceGroupName| RG2
    LOAD1 -->|createResourceGroupName| RG3
    
    LOAD2 -->|keyVault config| RG1
    LOAD3 -->|devCenter config| RG3
    
    style MAIN fill:#FF6B35,color:#fff
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

---

## Schema Documentation

### JSON Schema References

#### Security Schema (`security.schema.json`)

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

#### DevCenter Schema (`devcenter.schema.json`) - Key Definitions

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

### Schema Validation

Schemas are validated at authoring time using the `yaml-language-server` directive:

```yaml
# yaml-language-server: $schema=./security.schema.json
```

---

## References

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

---

## Glossary

| Term | Definition |
|------|------------|
| **loadYamlContent()** | Bicep function that loads YAML files as objects at compile time |
| **Secret Identifier** | URI to a specific version of a secret in Azure Key Vault |
| **Diagnostic Settings** | Azure configuration for routing logs and metrics to destinations |
| **Soft Delete** | Key Vault feature allowing recovery of deleted secrets within retention period |
| **Purge Protection** | Key Vault feature preventing permanent deletion during soft delete period |
| **RBAC Authorization** | Key Vault access control using Azure Role-Based Access Control instead of access policies |

---

*Document generated as part of TOGAF Architecture Documentation for DevExp-DevBox Landing Zone Accelerator*
