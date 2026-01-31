# Data Layer Architecture Document

---

## Document Control

| Attribute      | Value                                      |
| -------------- | ------------------------------------------ |
| Document Title | DevExp-DevBox Data Layer Architecture      |
| Version        | 1.0.0                                      |
| Last Updated   | 2026-01-31                                 |
| Author         | Enterprise Architecture Team               |
| Status         | Published                                  |
| Repository     | https://github.com/Evilazaro/DevExp-DevBox |
| Review Cycle   | Quarterly                                  |

### Version History

| Version | Date       | Author                       | Changes         |
| ------- | ---------- | ---------------------------- | --------------- |
| 1.0.0   | 2026-01-31 | Enterprise Architecture Team | Initial release |

---

## Executive Summary

The Data Layer for the DevExp-DevBox accelerator implements a
configuration-driven architecture that manages infrastructure-as-code data
through YAML configuration files, JSON schemas for validation, and Azure Key
Vault for secrets management. This layer follows TOGAF 10 principles for Data
Architecture (Phase C) and supports the Microsoft Dev Box platform deployment.

The architecture emphasizes:

- **Configuration as Data**: YAML files define resource organization, security
  settings, and workload configurations
- **Schema Validation**: JSON Schema (2020-12 draft) ensures data integrity and
  compliance
- **Secrets Management**: Azure Key Vault provides secure storage for sensitive
  data (tokens, credentials)
- **Metadata Governance**: Consistent tagging taxonomy across all configuration
  entities
- **Monitoring Data**: Log Analytics Workspace captures operational telemetry
  and diagnostics

This document defines the data entities, their relationships, storage
mechanisms, and governance policies that underpin the DevExp-DevBox
infrastructure deployment system.

---

## Scope and Objectives

### Scope Definition

| In Scope                                    | Out of Scope                            |
| ------------------------------------------- | --------------------------------------- |
| Configuration data entities (YAML/JSON)     | Application runtime data                |
| JSON Schema definitions for validation      | User-generated content within Dev Boxes |
| Azure Key Vault secrets structure           | Source code repository data             |
| Resource tagging taxonomy                   | Azure AD directory data                 |
| Log Analytics data collection configuration | Third-party integration data            |
| Network configuration data structures       | Business application databases          |
| Identity and role assignment data models    | End-user authentication tokens          |
| DevCenter catalog metadata                  | Container image binary data             |

### Objectives

| ID      | Objective                              | Success Criteria                               | Priority |
| ------- | -------------------------------------- | ---------------------------------------------- | -------- |
| OBJ-D01 | Define configuration data models       | All YAML entities documented with schemas      | HIGH     |
| OBJ-D02 | Establish secrets management patterns  | Key Vault integration fully documented         | HIGH     |
| OBJ-D03 | Document metadata governance (tagging) | Tagging taxonomy defined and validated         | MEDIUM   |
| OBJ-D04 | Define data validation mechanisms      | JSON Schemas documented for all configurations | HIGH     |
| OBJ-D05 | Map data flows between components      | All data relationships documented              | MEDIUM   |

---

## Data Architecture Principles

| ID     | Principle               | Statement                                                                      | Rationale                                           | Implications                                            |
| ------ | ----------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------- | ------------------------------------------------------- |
| DAP-01 | Configuration as Code   | All infrastructure configuration MUST be stored as version-controlled files    | Enables GitOps, auditability, and reproducibility   | YAML files in `/infra/settings/` directory              |
| DAP-02 | Schema-Validated Data   | All configuration files MUST be validated against JSON Schemas                 | Prevents deployment failures from invalid data      | JSON Schema files co-located with YAML configurations   |
| DAP-03 | Secrets Externalization | Sensitive data MUST NOT be stored in configuration files                       | Protects credentials and tokens                     | Azure Key Vault integration required                    |
| DAP-04 | Consistent Metadata     | All resources MUST use standardized tagging taxonomy                           | Enables cost management, governance, and operations | Tags schema defined in configuration schemas            |
| DAP-05 | Single Source of Truth  | Each configuration domain MUST have one authoritative YAML file                | Eliminates configuration drift and conflicts        | Separate files for security, workload, and resources    |
| DAP-06 | Data Locality           | Configuration data SHOULD be co-located with the Bicep modules that consume it | Improves maintainability and reduces coupling       | Settings in `infra/settings/`, schemas adjacent to YAML |

---

## Data Entities Catalog

### Configuration Data Entities

| Entity Name            | Description                                           | Primary Store                                                                  | Schema Location                                                                              | Owner  |
| ---------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------- | ------ |
| Azure Resources Config | Resource group organization and landing zone settings | [azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml) | [azureResources.schema.json](infra/settings/resourceOrganization/azureResources.schema.json) | DevExP |
| Security Config        | Key Vault configuration and security settings         | [security.yaml](infra/settings/security/security.yaml)                         | [security.schema.json](infra/settings/security/security.schema.json)                         | DevExP |
| DevCenter Config       | Dev Center, projects, catalogs, and pools settings    | [devcenter.yaml](infra/settings/workload/devcenter.yaml)                       | [devcenter.schema.json](infra/settings/workload/devcenter.schema.json)                       | DevExP |

### Secrets Data Entities

| Entity Name         | Description                                   | Primary Store   | Content Type | Retention           |
| ------------------- | --------------------------------------------- | --------------- | ------------ | ------------------- |
| GitHub Access Token | Personal Access Token for GitHub catalog sync | Azure Key Vault | text/plain   | Soft delete: 7 days |

### Operational Data Entities

| Entity Name     | Description                    | Primary Store           | Retention Policy |
| --------------- | ------------------------------ | ----------------------- | ---------------- |
| Diagnostic Logs | Azure resource diagnostic logs | Log Analytics Workspace | Platform default |
| Activity Logs   | Azure Activity solution logs   | Log Analytics Workspace | Platform default |
| Metrics         | Resource performance metrics   | Log Analytics Workspace | Platform default |

---

## Data Models

### Azure Resources Configuration Model

**Source**:
[azureResources.yaml](infra/settings/resourceOrganization/azureResources.yaml)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Resources Config                        │
├─────────────────────────────────────────────────────────────────┤
│ workload: ResourceGroup                                          │
│   ├── create: boolean                                            │
│   ├── name: string                                               │
│   ├── description: string                                        │
│   └── tags: Tags                                                 │
│                                                                  │
│ security: ResourceGroup                                          │
│   ├── create: boolean                                            │
│   ├── name: string                                               │
│   ├── description: string                                        │
│   └── tags: Tags                                                 │
│                                                                  │
│ monitoring: ResourceGroup                                        │
│   ├── create: boolean                                            │
│   ├── name: string                                               │
│   ├── description: string                                        │
│   └── tags: Tags                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Defined Resource Groups**:

| Resource Group | Name              | Landing Zone | Purpose                                   |
| -------------- | ----------------- | ------------ | ----------------------------------------- |
| Workload       | devexp-workload   | Workload     | DevCenter and project resources           |
| Security       | devexp-security   | Workload     | Key Vault and security-related resources  |
| Monitoring     | devexp-monitoring | Workload     | Log Analytics and observability resources |

### Security Configuration Model

**Source**: [security.yaml](infra/settings/security/security.yaml)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Configuration                        │
├─────────────────────────────────────────────────────────────────┤
│ create: boolean                                                  │
│                                                                  │
│ keyVault:                                                        │
│   ├── name: string (3-24 chars, alphanumeric + hyphens)         │
│   ├── description: string                                        │
│   ├── secretName: string                                         │
│   ├── enablePurgeProtection: boolean                            │
│   ├── enableSoftDelete: boolean                                  │
│   ├── softDeleteRetentionInDays: integer (7-90)                 │
│   ├── enableRbacAuthorization: boolean                          │
│   └── tags: Tags                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Current Security Settings**:

| Setting                   | Value     | Description                                   |
| ------------------------- | --------- | --------------------------------------------- |
| enablePurgeProtection     | true      | Prevents permanent deletion of secrets        |
| enableSoftDelete          | true      | Allows recovery of deleted secrets            |
| softDeleteRetentionInDays | 7         | Retention period for soft-deleted items       |
| enableRbacAuthorization   | true      | Uses Azure RBAC for data plane access control |
| secretName                | gha-token | GitHub Actions token secret identifier        |

### DevCenter Configuration Model

**Source**: [devcenter.yaml](infra/settings/workload/devcenter.yaml)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DevCenter Configuration                       │
├─────────────────────────────────────────────────────────────────┤
│ name: string                                                     │
│ catalogItemSyncEnableStatus: Enabled | Disabled                  │
│ microsoftHostedNetworkEnableStatus: Enabled | Disabled           │
│ installAzureMonitorAgentEnableStatus: Enabled | Disabled         │
│                                                                  │
│ identity:                                                        │
│   ├── type: SystemAssigned | UserAssigned                       │
│   └── roleAssignments:                                           │
│       ├── devCenter: RoleAssignment[]                           │
│       └── orgRoleTypes: OrgRoleType[]                           │
│                                                                  │
│ catalogs: Catalog[]                                              │
│ environmentTypes: EnvironmentType[]                              │
│ projects: Project[]                                              │
│ tags: Tags                                                       │
└─────────────────────────────────────────────────────────────────┘
```

**DevCenter Feature Status**:

| Feature                              | Status  | Description                                |
| ------------------------------------ | ------- | ------------------------------------------ |
| catalogItemSyncEnableStatus          | Enabled | Automatic synchronization of catalog items |
| microsoftHostedNetworkEnableStatus   | Enabled | Microsoft-hosted networking for Dev Boxes  |
| installAzureMonitorAgentEnableStatus | Enabled | Azure Monitor agent installation           |

### Project Data Model

```
┌─────────────────────────────────────────────────────────────────┐
│                         Project Entity                           │
├─────────────────────────────────────────────────────────────────┤
│ name: string                                                     │
│ description: string                                              │
│                                                                  │
│ network:                                                         │
│   ├── name: string                                               │
│   ├── create: boolean                                            │
│   ├── resourceGroupName: string                                  │
│   ├── virtualNetworkType: Managed | Unmanaged                   │
│   ├── addressPrefixes: string[]                                  │
│   └── subnets: Subnet[]                                          │
│                                                                  │
│ identity:                                                        │
│   ├── type: SystemAssigned | UserAssigned                       │
│   └── roleAssignments: RoleAssignment[]                         │
│                                                                  │
│ pools: Pool[]                                                    │
│ environmentTypes: EnvironmentType[]                              │
│ catalogs: Catalog[]                                              │
│ tags: Tags                                                       │
└─────────────────────────────────────────────────────────────────┘
```

**Defined Projects**:

| Project Name | Network Type | Network Address | Pools                               |
| ------------ | ------------ | --------------- | ----------------------------------- |
| eShop        | Managed      | 10.0.0.0/16     | backend-engineer, frontend-engineer |

### Catalog Data Model

```
┌─────────────────────────────────────────────────────────────────┐
│                        Catalog Entity                            │
├─────────────────────────────────────────────────────────────────┤
│ name: string                                                     │
│ type: gitHub | adoGit | environmentDefinition | imageDefinition  │
│ sourceControl: gitHub | adoGit                                   │
│ visibility: public | private                                     │
│ uri: string (URI format)                                         │
│ branch: string                                                   │
│ path: string                                                     │
└─────────────────────────────────────────────────────────────────┘
```

**Defined Catalogs**:

| Catalog Name | Type                  | Source Control | Visibility | Repository                                         |
| ------------ | --------------------- | -------------- | ---------- | -------------------------------------------------- |
| customTasks  | gitHub                | gitHub         | public     | https://github.com/microsoft/devcenter-catalog.git |
| environments | environmentDefinition | gitHub         | private    | https://github.com/Evilazaro/eShop.git             |
| devboxImages | imageDefinition       | gitHub         | private    | https://github.com/Evilazaro/eShop.git             |

### Pool Data Model

```
┌─────────────────────────────────────────────────────────────────┐
│                          Pool Entity                             │
├─────────────────────────────────────────────────────────────────┤
│ name: string                                                     │
│ imageDefinitionName: string                                      │
│ vmSku: string                                                    │
└─────────────────────────────────────────────────────────────────┘
```

**Defined Pools**:

| Pool Name         | Image Definition Name   | VM SKU                      |
| ----------------- | ----------------------- | --------------------------- |
| backend-engineer  | eShop-backend-engineer  | general_i_32c128gb512ssd_v2 |
| frontend-engineer | eShop-frontend-engineer | general_i_16c64gb256ssd_v2  |

### Environment Type Data Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    Environment Type Entity                       │
├─────────────────────────────────────────────────────────────────┤
│ name: string (dev | staging | UAT | prod)                        │
│ deploymentTargetId: string (subscription ID or empty)            │
└─────────────────────────────────────────────────────────────────┘
```

**Defined Environment Types**:

| Environment Type | Deployment Target    |
| ---------------- | -------------------- |
| dev              | Default subscription |
| staging          | Default subscription |
| UAT              | Default subscription |

---

## Metadata Governance (Tagging Taxonomy)

### Standard Tag Schema

All resources in the DevExp-DevBox accelerator MUST implement the following
tagging taxonomy:

| Tag Key     | Type   | Required | Description                         | Valid Values                       |
| ----------- | ------ | -------- | ----------------------------------- | ---------------------------------- |
| environment | string | Yes      | Deployment environment identifier   | dev, test, staging, prod           |
| division    | string | No       | Organizational division responsible | e.g., Platforms                    |
| team        | string | No       | Team responsible for the resource   | e.g., DevExP                       |
| project     | string | No       | Project name for cost allocation    | e.g., Contoso-DevExp-DevBox        |
| costCenter  | string | No       | Cost center for financial tracking  | e.g., IT                           |
| owner       | string | No       | Resource owner or responsible party | e.g., Contoso                      |
| landingZone | string | No       | Landing zone classification         | Workload, security                 |
| resources   | string | No       | Type of resources contained         | ResourceGroup, DevCenter, KeyVault |

### Current Tag Configuration

| Resource      | environment | division  | team   | project               | costCenter | owner   | landingZone |
| ------------- | ----------- | --------- | ------ | --------------------- | ---------- | ------- | ----------- |
| Workload RG   | dev         | Platforms | DevExP | Contoso-DevExp-DevBox | IT         | Contoso | Workload    |
| Security RG   | dev         | Platforms | DevExP | Contoso-DevExp-DevBox | IT         | Contoso | Workload    |
| Monitoring RG | dev         | Platforms | DevExP | Contoso-DevExp-DevBox | IT         | Contoso | Workload    |
| Key Vault     | dev         | Platforms | DevExP | Contoso-DevExp-DevBox | IT         | Contoso | security    |
| DevCenter     | dev         | Platforms | DevExP | DevExP-DevBox         | IT         | Contoso | -           |
| eShop Project | dev         | Platforms | DevExP | DevExP-DevBox         | IT         | Contoso | -           |

---

## Data Storage Architecture

### Configuration Data Storage

| Data Type             | Storage Location                       | Format | Validation            |
| --------------------- | -------------------------------------- | ------ | --------------------- |
| Resource Organization | `infra/settings/resourceOrganization/` | YAML   | JSON Schema (2020-12) |
| Security Settings     | `infra/settings/security/`             | YAML   | JSON Schema (2020-12) |
| Workload Settings     | `infra/settings/workload/`             | YAML   | JSON Schema (2020-12) |

### Secrets Storage

| Secret Type         | Storage         | Authentication   | Access Control |
| ------------------- | --------------- | ---------------- | -------------- |
| GitHub Access Token | Azure Key Vault | Managed Identity | Azure RBAC     |

**Key Vault Access Roles**:

| Role                      | Role ID                              | Scope         | Purpose                       |
| ------------------------- | ------------------------------------ | ------------- | ----------------------------- |
| Key Vault Secrets User    | 4633458b-17de-408a-b874-0445c86b69e6 | ResourceGroup | Read secrets for catalog sync |
| Key Vault Secrets Officer | b86a8fe4-44ce-4948-aee5-eccb2c155cd7 | ResourceGroup | Manage secrets                |

### Operational Data Storage

| Data Type       | Storage                 | SKU       | Purpose                            |
| --------------- | ----------------------- | --------- | ---------------------------------- |
| Diagnostic Logs | Log Analytics Workspace | PerGB2018 | Centralized logging and monitoring |
| Activity Logs   | Log Analytics Workspace | PerGB2018 | Azure Activity solution            |
| Metrics         | Log Analytics Workspace | PerGB2018 | Performance monitoring             |

---

## Data Flows

### Configuration Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         Configuration Data Flow                               │
└──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
  │  YAML Config    │     │  JSON Schema    │     │  Bicep Module   │
  │  Files          │────▶│  Validation     │────▶│  loadYamlContent│
  │                 │     │                 │     │                 │
  └─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                               │
         │                                               ▼
         │                                        ┌─────────────────┐
         │                                        │  Azure Resource │
         │                                        │  Deployment     │
         │                                        └─────────────────┘
         │                                               │
         ▼                                               ▼
  ┌─────────────────┐                            ┌─────────────────┐
  │  Git Repository │                            │  Azure Resources│
  │  (Version       │                            │  (Deployed)     │
  │   Control)      │                            │                 │
  └─────────────────┘                            └─────────────────┘
```

### Secrets Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Secrets Data Flow                                   │
└──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
  │  Deployment     │     │  Azure Key Vault│     │  DevCenter      │
  │  Parameter      │────▶│  Secret Storage │────▶│  Catalog Sync   │
  │  (secretValue)  │     │  (gha-token)    │     │                 │
  └─────────────────┘     └─────────────────┘     └─────────────────┘
                                 │
                                 │ secretIdentifier
                                 ▼
                          ┌─────────────────┐
                          │  Private GitHub │
                          │  Repository     │
                          │  Access         │
                          └─────────────────┘
```

### Monitoring Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Monitoring Data Flow                                 │
└──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
  │  Azure          │     │  Diagnostic     │     │  Log Analytics  │
  │  Resources      │────▶│  Settings       │────▶│  Workspace      │
  │                 │     │                 │     │                 │
  └─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                               │
         │ allLogs, AllMetrics                           │
         ▼                                               ▼
  ┌─────────────────┐                            ┌─────────────────┐
  │  Key Vault      │                            │  Azure Activity │
  │  Virtual Network│                            │  Solution       │
  │  Log Analytics  │                            │                 │
  └─────────────────┘                            └─────────────────┘
```

---

## Data Validation

### JSON Schema Specifications

| Schema File                | Schema Version | Purpose                               |
| -------------------------- | -------------- | ------------------------------------- |
| azureResources.schema.json | 2020-12        | Validate resource group configuration |
| security.schema.json       | 2020-12        | Validate Key Vault configuration      |
| devcenter.schema.json      | 2020-12        | Validate DevCenter configuration      |

### Schema Validation Rules

**Azure Resources Schema**:

- `workload`, `security`, `monitoring` are required properties
- Resource group names: 1-90 characters, pattern `^[a-zA-Z0-9._-]+$`
- `create` flag determines new vs existing resource group

**Security Schema**:

- `create` and `keyVault` are required properties
- Key Vault name: 3-24 characters, pattern `^[a-zA-Z0-9-]{3,24}$`
- `softDeleteRetentionInDays`: 7-90 days
- `environment` tag is required

**DevCenter Schema**:

- `name` is required (1-63 characters)
- GUID pattern validation:
  `^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`
- CIDR block pattern validation: `^(?:\d{1,3}\.){3}\d{1,3}\/\d{1,2}$`
- Environment type names: dev, staging, UAT, prod
- Virtual network types: Managed, Unmanaged

---

## Data Integration Patterns

### Bicep YAML Loading Pattern

Configuration data is loaded into Bicep modules using the `loadYamlContent()`
function:

| Module         | Configuration File                                      | Variable Name     |
| -------------- | ------------------------------------------------------- | ----------------- |
| main.bicep     | infra/settings/resourceOrganization/azureResources.yaml | landingZones      |
| workload.bicep | infra/settings/workload/devcenter.yaml                  | devCenterSettings |
| security.bicep | infra/settings/security/security.yaml                   | securitySettings  |

### Key Vault Secret Reference Pattern

Secrets are referenced using the `secretIdentifier` pattern:

```
Key Vault → Secret → secretUri → Catalog Configuration
```

The `secretIdentifier` output from the secret module is passed to catalog
configurations for private repository authentication.

---

## Data Governance

### Data Ownership Matrix

| Data Domain             | Owner Team | Steward           | Classification      |
| ----------------------- | ---------- | ----------------- | ------------------- |
| Resource Configuration  | DevExP     | Platform Engineer | Internal            |
| Security Configuration  | DevExP     | Security Engineer | Confidential        |
| DevCenter Configuration | DevExP     | Platform Engineer | Internal            |
| Secrets (Key Vault)     | DevExP     | Security Engineer | Highly Confidential |
| Monitoring Data         | DevExP     | Operations        | Internal            |

### Data Quality Rules

| Rule ID | Data Entity      | Rule Description                                  | Enforcement          |
| ------- | ---------------- | ------------------------------------------------- | -------------------- |
| DQ-01   | All YAML configs | Must pass JSON Schema validation                  | IDE + CI Pipeline    |
| DQ-02   | Resource names   | Must follow naming conventions in schema patterns | JSON Schema          |
| DQ-03   | GUID values      | Must be valid UUID format                         | JSON Schema pattern  |
| DQ-04   | CIDR blocks      | Must be valid CIDR notation                       | JSON Schema pattern  |
| DQ-05   | Tags             | environment tag is required on all resources      | JSON Schema required |

---

## Data Security

### Data Classification

| Classification      | Data Types                               | Protection Level          |
| ------------------- | ---------------------------------------- | ------------------------- |
| Highly Confidential | GitHub PAT, credentials                  | Azure Key Vault, RBAC     |
| Confidential        | Security configuration                   | Git repository, PR review |
| Internal            | Resource configuration, DevCenter config | Git repository            |
| Public              | Public catalog URIs                      | None                      |

### Security Controls

| Control               | Implementation                         | Data Types Affected |
| --------------------- | -------------------------------------- | ------------------- |
| Encryption at Rest    | Azure Key Vault managed keys           | Secrets             |
| Encryption in Transit | HTTPS for Git repositories             | Configuration files |
| Access Control        | Azure RBAC with managed identities     | Key Vault secrets   |
| Audit Logging         | Log Analytics with diagnostic settings | All Azure resources |
| Soft Delete           | 7-day retention for Key Vault          | Secrets             |
| Purge Protection      | Enabled on Key Vault                   | Secrets             |

---

## References

### Internal References

| Document               | Location                                                                                     |
| ---------------------- | -------------------------------------------------------------------------------------------- |
| Azure Resources Schema | [azureResources.schema.json](infra/settings/resourceOrganization/azureResources.schema.json) |
| Security Schema        | [security.schema.json](infra/settings/security/security.schema.json)                         |
| DevCenter Schema       | [devcenter.schema.json](infra/settings/workload/devcenter.schema.json)                       |

### External References

| Reference                     | URL                                                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------- |
| Microsoft Dev Box Accelerator | https://evilazaro.github.io/DevExp-DevBox/docs/configureresources/                                      |
| Azure Landing Zones           | https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/                    |
| Azure Key Vault               | https://learn.microsoft.com/en-us/azure/key-vault/general/basic-concepts                                |
| Azure Resource Groups         | https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal |
| Dev Center Documentation      | https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box                      |
| JSON Schema 2020-12           | https://json-schema.org/draft/2020-12/schema                                                            |

---

## Appendix A: Complete Type Definitions

### Tags Type Definition

```typescript
type Tags = {
  environment: 'dev' | 'test' | 'staging' | 'prod';
  division?: string;
  team?: string;
  project?: string;
  costCenter?: string;
  owner?: string;
  landingZone?: string;
  resources?: string;
};
```

### ResourceGroup Type Definition

```typescript
type ResourceGroup = {
  create: boolean;
  name: string; // 1-90 chars, pattern: ^[a-zA-Z0-9._-]+$
  description: string;
  tags: Tags;
};
```

### KeyVaultConfig Type Definition

```typescript
type KeyVaultConfig = {
  name: string; // 3-24 chars
  description?: string;
  secretName?: string; // 1-127 chars
  enablePurgeProtection: boolean;
  enableSoftDelete: boolean;
  softDeleteRetentionInDays: number; // 7-90
  enableRbacAuthorization: boolean;
  tags: Tags;
};
```

### Catalog Type Definition

```typescript
type Catalog = {
  name: string;
  type: 'gitHub' | 'adoGit' | 'environmentDefinition' | 'imageDefinition';
  sourceControl?: 'gitHub' | 'adoGit';
  visibility: 'public' | 'private';
  uri: string; // URI format
  branch: string;
  path: string;
};
```

### EnvironmentType Type Definition

```typescript
type EnvironmentType = {
  name: string; // dev, staging, UAT, prod
  deploymentTargetId: string;
};
```

### Pool Type Definition

```typescript
type Pool = {
  name: string;
  imageDefinitionName: string;
  vmSku: string;
};
```

---

_Document generated following TOGAF 10 ADM Phase C - Data Architecture
principles._
