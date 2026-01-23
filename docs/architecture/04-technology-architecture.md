# ☁️ Technology Architecture

> **DevExp-DevBox Landing Zone Accelerator**

| Property | Value |
|:---------|:------|
| **Version** | 1.0.0 |
| **Last Updated** | 2026-01-23 |
| **Author** | DevExp Team |
| **Status** | Published |

---

## 📑 Table of Contents

- [📊 Technology Overview](#technology-overview)
- [📦 Azure Service Catalog](#azure-service-catalog)
- [🏗️ Landing Zone Design](#landing-zone-design)
- [🌐 Network Architecture](#network-architecture)
- [💻 Compute Architecture](#compute-architecture)
- [🔄 CI/CD Infrastructure](#cicd-infrastructure)
- [📶 Monitoring Infrastructure](#monitoring-infrastructure)
- [📏 Infrastructure Sizing](#infrastructure-sizing)
- [📜 Technology Standards](#technology-standards)
- [🔗 References](#references)

---

## 📊 Technology Overview

The DevExp-DevBox accelerator leverages Azure's Platform as a Service (PaaS) offerings with a strong emphasis on managed services, security by default, and enterprise governance patterns.

### Technology Stack Overview

```mermaid
flowchart TB
    subgraph Developer["Developer Tooling"]
        VSC["VS Code"]
        GH["GitHub"]
        AZD["Azure Developer CLI"]
    end
    
    subgraph IaC["Infrastructure as Code"]
        BICEP["Azure Bicep"]
        YAML["YAML Configuration"]
        PS["PowerShell/Bash"]
    end
    
    subgraph CI/CD["CI/CD Platform"]
        GHA["GitHub Actions"]
        OIDC["OIDC Federation"]
    end
    
    subgraph Azure["Azure Platform"]
        subgraph Compute["Compute Services"]
            DC["Azure DevCenter"]
            DB["Dev Boxes"]
        end
        
        subgraph Security["Security Services"]
            KV["Key Vault"]
            RBAC["Azure RBAC"]
            MI["Managed Identities"]
        end
        
        subgraph Network["Network Services"]
            VNET["Virtual Network"]
            NC["Network Connections"]
        end
        
        subgraph Monitor["Monitoring Services"]
            LA["Log Analytics"]
            MON["Azure Monitor"]
        end
    end
    
    Developer --> IaC
    IaC --> CI/CD
    CI/CD --> Azure
    
    style Developer fill:#2196F3,color:#fff
    style IaC fill:#FF9800,color:#fff
    style CI/CD fill:#9C27B0,color:#fff
    style Azure fill:#4CAF50,color:#fff
```

### Technology Decision Matrix

| Category | Technology | Rationale | Alternatives Considered |
|----------|------------|-----------|-------------------------|
| IaC Language | Azure Bicep | Native Azure, type-safe, modular | Terraform, ARM Templates |
| Configuration | YAML | Human-readable, schema validation | JSON, HCL |
| CI/CD | GitHub Actions | Native GitHub integration, OIDC | Azure DevOps, Jenkins |
| Authentication | OIDC Federation | No stored secrets, short-lived tokens | Service Principal + Secret |
| Secrets | Azure Key Vault | Native Azure, RBAC, HSM-backed | GitHub Secrets, HashiCorp Vault |
| Monitoring | Log Analytics | Unified Azure telemetry | Splunk, Datadog |
| Compute | Azure DevCenter | Managed Dev Box service | Azure VMs, AVD |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📦 Azure Service Catalog

### Primary Azure Services

| Service | Resource Type | Purpose | Tier/SKU |
|---------|--------------|---------|----------|
| **Azure DevCenter** | `Microsoft.DevCenter/devcenters` | Developer workstation management | N/A (PaaS) |
| **Dev Box Projects** | `Microsoft.DevCenter/devcenters/projects` | Project-level Dev Box organization | N/A |
| **Dev Box Pools** | `Microsoft.DevCenter/projects/pools` | Dev Box VM allocation | Variable |
| **Azure Key Vault** | `Microsoft.KeyVault/vaults` | Secrets and credential storage | Standard |
| **Log Analytics** | `Microsoft.OperationalInsights/workspaces` | Centralized logging | PerGB2018 |
| **Virtual Network** | `Microsoft.Network/virtualNetworks` | Network isolation | N/A |
| **Network Connection** | `Microsoft.DevCenter/networkConnections` | Dev Box network config | N/A |

### Service Relationships

```mermaid
flowchart TB
    subgraph Management["Management Plane"]
        ARM["Azure Resource Manager"]
        SUB["Subscription"]
    end
    
    subgraph ResourceGroups["Resource Groups"]
        RG_SEC["rg-security"]
        RG_MON["rg-monitoring"]
        RG_WL["rg-workload"]
    end
    
    subgraph SecurityZone["Security Landing Zone"]
        KV["Key Vault"]
        SEC["Secrets"]
    end
    
    subgraph MonitoringZone["Monitoring Landing Zone"]
        LA["Log Analytics\nWorkspace"]
        SOL["Solutions"]
    end
    
    subgraph WorkloadZone["Workload Landing Zone"]
        DC["DevCenter"]
        PROJ["Projects"]
        POOL["Pools"]
        CAT["Catalogs"]
    end
    
    subgraph NetworkZone["Network"]
        VNET["Virtual Network"]
        SUBNET["Subnets"]
        NC["Network Connection"]
    end
    
    ARM --> SUB
    SUB --> ResourceGroups
    
    RG_SEC --> SecurityZone
    RG_MON --> MonitoringZone
    RG_WL --> WorkloadZone
    RG_WL --> NetworkZone
    
    KV -.->|secretIdentifier| CAT
    LA -.->|diagnostics| KV
    LA -.->|diagnostics| DC
    LA -.->|diagnostics| VNET
    
    NC --> VNET
    DC --> PROJ
    PROJ --> POOL
    
    style Management fill:#E91E63,color:#fff
    style ResourceGroups fill:#9C27B0,color:#fff
    style SecurityZone fill:#F44336,color:#fff
    style MonitoringZone fill:#4CAF50,color:#fff
    style WorkloadZone fill:#2196F3,color:#fff
    style NetworkZone fill:#FF9800,color:#fff
```

### API Versions Used

| Resource Type | API Version | Preview/GA |
|--------------|-------------|------------|
| `Microsoft.DevCenter/devcenters` | 2024-08-01-preview | Preview |
| `Microsoft.DevCenter/devcenters/catalogs` | 2024-08-01-preview | Preview |
| `Microsoft.DevCenter/devcenters/projects` | 2024-08-01-preview | Preview |
| `Microsoft.DevCenter/projects/pools` | 2024-08-01-preview | Preview |
| `Microsoft.DevCenter/networkConnections` | 2024-08-01-preview | Preview |
| `Microsoft.KeyVault/vaults` | 2023-07-01 | GA |
| `Microsoft.KeyVault/vaults/secrets` | 2023-07-01 | GA |
| `Microsoft.OperationalInsights/workspaces` | 2022-10-01 | GA |
| `Microsoft.Network/virtualNetworks` | 2023-09-01 | GA |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | GA |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🏗️ Landing Zone Design

### Azure Landing Zone Alignment

The accelerator implements a simplified Azure Landing Zone pattern with three primary zones plus networking.

```mermaid
flowchart TB
    subgraph Subscription["Azure Subscription"]
        subgraph Security["Security Landing Zone"]
            direction TB
            RG_S["Resource Group:\ndevexp-security-{env}"]
            KV_R["Key Vault"]
            SEC_R["Secrets"]
        end
        
        subgraph Monitoring["Monitoring Landing Zone"]
            direction TB
            RG_M["Resource Group:\ndevexp-monitoring-{env}"]
            LA_R["Log Analytics"]
            SOL_R["Solutions"]
        end
        
        subgraph Workload["Workload Landing Zone"]
            direction TB
            RG_W["Resource Group:\ndevexp-workload-{env}"]
            DC_R["DevCenter"]
            PROJ_R["Projects"]
            POOL_R["Pools"]
        end
        
        subgraph Network["Connectivity"]
            direction TB
            VNET_R["Virtual Network"]
            NC_R["Network Connection"]
        end
    end
    
    Security --> Monitoring
    Monitoring --> Workload
    Network --> Workload
    
    style Security fill:#F44336,color:#fff
    style Monitoring fill:#4CAF50,color:#fff
    style Workload fill:#2196F3,color:#fff
    style Network fill:#FF9800,color:#fff
```

### Resource Group Naming Convention

| Landing Zone | Resource Group Pattern | Example |
|--------------|----------------------|---------|
| Security | `{base}-security-{env}` | `devexp-security-dev` |
| Monitoring | `{base}-monitoring-{env}` | `devexp-monitoring-dev` |
| Workload | `{base}-workload-{env}` | `devexp-workload-dev` |

### Resource Naming Convention

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| DevCenter | `{name}-{uniqueString}` | `devexp-devcenter-abc123` |
| Key Vault | `kv-{name}-{uniqueString}` | `kv-contoso-xyz789` |
| Log Analytics | `law-{name}-{uniqueString}` | `law-devexp-def456` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-eshop-dev` |
| Subnet | `snet-{purpose}` | `snet-devbox` |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🌐 Network Architecture

### Network Topology

```mermaid
flowchart TB
    subgraph Internet["Internet"]
        DEV["Developer\n(Remote)"]
        GH["GitHub.com"]
        ADO["Azure DevOps"]
    end
    
    subgraph Azure["Azure"]
        subgraph VNet["Virtual Network (10.0.0.0/16)"]
            subgraph Subnet["DevBox Subnet (10.0.1.0/24)"]
                DB1["Dev Box 1"]
                DB2["Dev Box 2"]
                DB3["Dev Box N"]
            end
        end
        
        NC["Network Connection\n(Managed/Unmanaged)"]
        DC["DevCenter"]
    end
    
    subgraph MSHosted["Microsoft-Hosted Network"]
        MHN["Microsoft Managed\nNetwork"]
    end
    
    DEV -->|"RDP/HTTPS"| DB1
    DEV -->|"RDP/HTTPS"| DB2
    
    DB1 -->|"HTTPS"| GH
    DB1 -->|"HTTPS"| ADO
    
    DC -->|"networkConnectionId"| NC
    NC -->|"subnetId"| Subnet
    
    DC -.->|"Alternative"| MHN
    
    style Internet fill:#E91E63,color:#fff
    style VNet fill:#2196F3,color:#fff
    style MSHosted fill:#9C27B0,color:#fff
```

### Network Configuration Options

| Option | Configuration | Use Case |
|--------|--------------|----------|
| **Microsoft-Hosted** | `microsoftHostedNetworkEnableStatus: Enabled` | Quick start, no VNet management |
| **Azure VNet (Managed)** | `virtualNetworkType: Managed` | Organization VNet, auto-provisioned |
| **Azure VNet (Unmanaged)** | `virtualNetworkType: Unmanaged` | Existing VNet, full control |

### VNet Configuration (from devcenter.yaml)

```yaml
network:
  name: eShop
  create: true
  virtualNetworkType: Managed
  addressPrefixes:
    - "10.0.0.0/16"
  subnets:
    - name: eShop-subnet
      properties:
        addressPrefix: 10.0.1.0/24
```

### Network Security Controls

| Control | Implementation | Purpose |
|---------|---------------|---------|
| NSG | Default Azure NSG | Subnet-level filtering |
| Private Endpoints | Optional | Key Vault private access |
| Service Endpoints | Optional | PaaS service access |
| NAT Gateway | Optional | Outbound connectivity |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 💻 Compute Architecture

### Dev Box Architecture

```mermaid
flowchart TB
    subgraph DevCenter["Azure DevCenter"]
        DC["DevCenter Resource"]
        
        subgraph Images["Image Definitions"]
            IMG1["eShop-backend-engineer"]
            IMG2["eShop-frontend-engineer"]
        end
        
        subgraph Projects["Projects"]
            PROJ["eShop Project"]
        end
        
        subgraph Pools["Dev Box Pools"]
            P1["backend-engineer\ngeneral_i_32c128gb512ssd_v2"]
            P2["frontend-engineer\ngeneral_i_16c64gb256ssd_v2"]
        end
    end
    
    subgraph Runtime["Runtime Environment"]
        DB1["Dev Box Instance\n(Windows 11)"]
        DB2["Dev Box Instance\n(Windows 11)"]
    end
    
    DC --> Images
    DC --> Projects
    Projects --> Pools
    P1 --> DB1
    P2 --> DB2
    
    IMG1 -->|imageDefinition| P1
    IMG2 -->|imageDefinition| P2
    
    style DevCenter fill:#2196F3,color:#fff
    style Runtime fill:#4CAF50,color:#fff
```

### Dev Box SKU Options

| SKU | vCPU | Memory | Storage | Use Case |
|-----|------|--------|---------|----------|
| `general_i_8c32gb256ssd_v2` | 8 | 32 GB | 256 GB | Light development |
| `general_i_16c64gb256ssd_v2` | 16 | 64 GB | 256 GB | Frontend development |
| `general_i_16c64gb512ssd_v2` | 16 | 64 GB | 512 GB | General development |
| `general_i_32c128gb512ssd_v2` | 32 | 128 GB | 512 GB | Backend/heavy workloads |
| `general_i_32c128gb1024ssd_v2` | 32 | 128 GB | 1024 GB | Data/ML development |

### Image Management

Dev Box images are managed through DevCenter catalogs containing image definitions:

```mermaid
flowchart LR
    subgraph Catalog["DevCenter Catalog"]
        GIT["Git Repository"]
        IMG_DEF["Image Definitions\n(YAML/JSON)"]
        DSC["DSC Configurations\n(Optional)"]
    end
    
    subgraph DevCenter["DevCenter"]
        CAT["Catalog Sync"]
        IMG["Image Gallery"]
    end
    
    subgraph Pool["Dev Box Pool"]
        VM["Dev Box VMs"]
    end
    
    GIT --> CAT
    CAT --> IMG_DEF
    IMG_DEF --> IMG
    IMG --> VM
    DSC --> IMG
    
    style Catalog fill:#FF9800,color:#fff
    style DevCenter fill:#2196F3,color:#fff
    style Pool fill:#4CAF50,color:#fff
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔄 CI/CD Infrastructure

### GitHub Actions Architecture

```mermaid
flowchart TB
    subgraph GitHub["GitHub"]
        REPO["Repository"]
        
        subgraph Actions["GitHub Actions"]
            WF_BUILD["build.yml"]
            WF_DEPLOY["deploy.yml"]
            WF_RELEASE["release.yml"]
        end
        
        subgraph Secrets["GitHub Configuration"]
            VARS["Variables:\n- AZURE_CLIENT_ID\n- AZURE_TENANT_ID\n- AZURE_SUBSCRIPTION_ID"]
            SECS["Secrets:\n- AZURE_CREDENTIALS"]
        end
    end
    
    subgraph Azure["Azure"]
        OIDC["OIDC Provider\n(Microsoft Entra ID)"]
        ARM["Azure Resource Manager"]
        SUB["Subscription"]
    end
    
    REPO --> Actions
    Actions --> OIDC
    OIDC -->|"Token Exchange"| ARM
    ARM --> SUB
    
    VARS --> Actions
    SECS --> Actions
    
    style GitHub fill:#9C27B0,color:#fff
    style Azure fill:#2196F3,color:#fff
```

### Workflow Pipeline Structure

```mermaid
flowchart LR
    subgraph Build["build.yml"]
        B1["Checkout"]
        B2["Setup azd"]
        B3["Login (OIDC)"]
        B4["azd provision"]
    end
    
    subgraph Deploy["deploy.yml"]
        D1["Checkout"]
        D2["Setup azd"]
        D3["Login (OIDC)"]
        D4["Download Artifacts"]
        D5["azd deploy"]
    end
    
    subgraph Release["release.yml"]
        R1["Get Version"]
        R2["Create Tag"]
        R3["Create Release"]
        R4["Generate Notes"]
    end
    
    Build -->|"artifacts"| Deploy
    Deploy -->|"on success"| Release
    
    style Build fill:#FF9800,color:#fff
    style Deploy fill:#4CAF50,color:#fff
    style Release fill:#2196F3,color:#fff
```

### Pipeline Components

| Component | Purpose | Configuration |
|-----------|---------|---------------|
| `build.yml` | Provision infrastructure | OIDC auth, azd provision |
| `deploy.yml` | Deploy applications | Artifact download, azd deploy |
| `release.yml` | Create releases | Semantic versioning, release notes |

### OIDC Federation Configuration

```yaml
# GitHub Actions OIDC Configuration
permissions:
  id-token: write    # Required for OIDC
  contents: read     # Required for checkout

steps:
  - uses: azure/login@v2
    with:
      client-id: ${{ vars.AZURE_CLIENT_ID }}
      tenant-id: ${{ vars.AZURE_TENANT_ID }}
      subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📶 Monitoring Infrastructure

### Log Analytics Architecture

```mermaid
flowchart TB
    subgraph Sources["Telemetry Sources"]
        DC["DevCenter\nLogs & Metrics"]
        KV["Key Vault\nLogs & Metrics"]
        VN["Virtual Network\nLogs & Metrics"]
        DB["Dev Box\nAgent Metrics"]
    end
    
    subgraph Collection["Collection Layer"]
        DS["Diagnostic Settings"]
        AMA["Azure Monitor Agent"]
    end
    
    subgraph LAW["Log Analytics Workspace"]
        subgraph Tables["Tables"]
            DIAG["AzureDiagnostics"]
            MET["AzureMetrics"]
            ACT["AzureActivity"]
        end
        
        subgraph Solutions["Solutions"]
            AA["AzureActivity Solution"]
        end
    end
    
    subgraph Consumers["Consumers"]
        DASH["Dashboards"]
        ALERT["Alerts"]
        WB["Workbooks"]
    end
    
    DC --> DS
    KV --> DS
    VN --> DS
    DB --> AMA
    
    DS --> Tables
    AMA --> Tables
    
    Tables --> Solutions
    Tables --> Consumers
    
    style Sources fill:#FF9800,color:#fff
    style Collection fill:#9C27B0,color:#fff
    style LAW fill:#2196F3,color:#fff
    style Consumers fill:#4CAF50,color:#fff
```

### Diagnostic Settings Configuration

| Resource | Log Categories | Metrics |
|----------|---------------|---------|
| DevCenter | allLogs | AllMetrics |
| Key Vault | AuditEvent, AzurePolicyEvaluationDetails | AllMetrics |
| Virtual Network | VMProtectionAlerts | AllMetrics |
| Log Analytics | Audit | AllMetrics |

### Retention and Costs

| Data Type | Retention | Cost Model |
|-----------|-----------|------------|
| Logs | 90 days | PerGB2018 |
| Metrics | 93 days | Included |
| Activity | 90 days | Free (first 5GB) |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📏 Infrastructure Sizing

### Resource Sizing Guidelines

| Resource | Small | Medium | Large |
|----------|-------|--------|-------|
| **DevCenter Projects** | 1-5 | 5-20 | 20+ |
| **Dev Box Pools** | 1-2 per project | 3-5 per project | 5+ per project |
| **Concurrent Dev Boxes** | 10-50 | 50-200 | 200+ |
| **Log Analytics** | 5 GB/day | 10 GB/day | 50+ GB/day |
| **Key Vault Operations** | 1K/month | 10K/month | 100K+/month |

### Scaling Considerations

| Component | Scaling Method | Limits |
|-----------|----------------|--------|
| DevCenter | Horizontal (add projects) | 10 projects/DevCenter |
| Pools | Horizontal (add pools) | 5 pools/project |
| Dev Boxes | Auto (pool settings) | Based on quota |
| Network | VNet peering | Regional |
| Key Vault | Automatic | 25K ops/vault/region |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📜 Technology Standards

### Bicep Coding Standards

| Standard | Requirement |
|----------|-------------|
| API Versions | Use latest stable or preview as needed |
| Parameters | Use `@description` decorator |
| Secure Values | Use `@secure()` decorator |
| Naming | camelCase for resources, PascalCase for modules |
| Outputs | Document all outputs with descriptions |
| Modules | Single responsibility principle |

### YAML Configuration Standards

| Standard | Requirement |
|----------|-------------|
| Schema | All YAML files must reference JSON schema |
| Comments | Document complex configurations |
| Validation | Schema validation in CI/CD |
| Structure | Consistent property ordering |

### Version Control Standards

| Standard | Requirement |
|----------|-------------|
| Branching | Feature branches from main |
| Commits | Conventional commits |
| PRs | Required reviews |
| CODEOWNERS | Define for all paths |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 References

### 📚 Internal References

- [Business Architecture](01-business-architecture.md)
- [Data Architecture](02-data-architecture.md)
- [Application Architecture](03-application-architecture.md)
- [Security Architecture](05-security-architecture.md)

### 🌐 External References

- [Azure DevCenter Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Log Analytics Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)
