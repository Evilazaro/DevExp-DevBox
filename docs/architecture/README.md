# Architecture Documentation — DevExp-DevBox

This folder contains the architecture documentation for the **DevExp-DevBox**
platform, an Azure Dev Box Adoption & Deployment Accelerator that enables
platform engineering teams to deliver self-service developer workstations at
enterprise scale.

The documentation follows the **BDAT** (Business, Data, Application, Technology)
architecture framework, with each layer covered in a dedicated document.

---

## Documents

| Layer           | Document                                                   | Description                                                                                                  |
| --------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Business**    | [business-architecture.md](business-architecture.md)       | Strategy, capabilities, value streams, processes, services, roles, rules, and events driving the platform    |
| **Data**        | [data-architecture.md](data-architecture.md)               | Configuration data model, YAML/JSON Schema governance, data entities, flows, and quality assessment          |
| **Application** | [application-architecture.md](application-architecture.md) | 29 application components across Bicep modules, services, integration patterns, and deployment orchestration |
| **Technology**  | [technology-architecture.md](technology-architecture.md)   | 21 infrastructure components covering compute, networking, security, identity, and observability             |

---

## Architecture Overview

The platform is deployed via **Azure Developer CLI (`azd`)** using a modular
**Bicep** IaC approach. A subscription-scoped orchestrator
([infra/main.bicep](../../infra/main.bicep)) delegates to domain-specific
modules organized into five functional layers:

```
infra/main.bicep (orchestrator)
├── src/workload/       → DevCenter, Projects, Pools, Catalogs
├── src/security/       → Key Vault, Secrets, RBAC
├── src/connectivity/   → VNet, Subnets, Network Connections
├── src/identity/       → Role Assignments (Subscription, RG, Project)
└── src/management/     → Log Analytics, Diagnostics
```

Configuration is driven by three YAML files validated against companion JSON
Schemas:

| Config File                                                                          | Schema                                                                                             | Domain                |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | --------------------- |
| [devcenter.yaml](../../infra/settings/workload/devcenter.yaml)                       | [devcenter.schema.json](../../infra/settings/workload/devcenter.schema.json)                       | Workload              |
| [security.yaml](../../infra/settings/security/security.yaml)                         | [security.schema.json](../../infra/settings/security/security.schema.json)                         | Security              |
| [azureResources.yaml](../../infra/settings/resourceOrganization/azureResources.yaml) | [azureResources.schema.json](../../infra/settings/resourceOrganization/azureResources.schema.json) | Resource Organization |

---

## Key Architecture Characteristics

- **Deployment**: Fully declarative IaC (Bicep) via `azd provision`
- **Landing Zones**: Three isolated resource groups — workload, security,
  monitoring
- **Compute**: Azure DevCenter with managed Dev Box pools (no customer-managed
  VMs)
- **Identity**: System-Assigned Managed Identities + Azure AD group-based RBAC
- **Secrets**: Azure Key Vault with RBAC authorization, soft delete, and purge
  protection
- **Observability**: Centralized Log Analytics Workspace with diagnostic
  settings across all resources
- **Catalogs**: GitHub-sourced task catalogs and project-specific
  environment/image definitions
