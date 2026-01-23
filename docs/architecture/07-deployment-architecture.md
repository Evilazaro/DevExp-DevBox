# 🚀 Deployment Architecture

> 📖 This document describes the deployment architecture and CI/CD pipeline design for the Dev Box Accelerator project.

---

## 📑 Table of Contents

- [🎯 Overview](#overview)
- [🏗️ High-Level Architecture](#high-level-architecture)
- [🔄 Pipeline Architecture](#pipeline-architecture)
- [🌍 Deployment Environments](#deployment-environments)
- [🔒 Security Architecture](#security-architecture)
- [📦 Infrastructure Components](#infrastructure-components)
- [💾 Artifact Management](#artifact-management)
- [🛠️ Deployment Process](#deployment-process)
- [📶 Monitoring & Observability](#monitoring--observability)
- [🔗 Related Documentation](#related-documentation)

---

## 🎯 Overview

The Dev Box Accelerator uses a modern GitOps-style deployment approach with GitHub Actions for continuous integration and continuous deployment (CI/CD). The infrastructure is defined as code using Bicep templates and deployed to Azure using the Azure Developer CLI (azd).

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🏗️ High-Level Architecture

```mermaid
flowchart TB
    subgraph "👨‍💻 Development"
        DEV1["Developer Workstation"]
        DEV2["VS Code + Bicep Extension"]
        DEV1 --> DEV2
    end

    subgraph "📦 Source Control"
        GH1["GitHub Repository"]
        GH2["Branch Strategy"]
        GH3["Pull Requests"]
        GH1 --> GH2
        GH2 --> GH3
    end

    subgraph "🔄 CI/CD Pipeline"
        direction TB
        CI["🔨 CI Workflow"]
        RELEASE["🏷️ Release Workflow"]
        DEPLOY["🚀 Deploy Workflow"]
    end

    subgraph "☁️ Azure"
        direction TB
        SUB["Azure Subscription"]
        RG["Resource Groups"]
        DC["Dev Center"]
        KV["Key Vault"]
        VNET["Virtual Network"]
        SUB --> RG
        RG --> DC & KV & VNET
    end

    DEV2 --> |"git push"| GH1
    GH2 --> |"feature/fix branches"| CI
    GH3 --> |"PR to main"| CI
    GH1 --> |"manual trigger"| RELEASE
    GH1 --> |"manual trigger"| DEPLOY
    DEPLOY --> |"azd provision"| SUB

    classDef dev fill:#E3F2FD,stroke:#1565C0,color:#000
    classDef gh fill:#F3E5F5,stroke:#6A1B9A,color:#000
    classDef cicd fill:#FFF3E0,stroke:#EF6C00,color:#000
    classDef azure fill:#E8F5E9,stroke:#2E7D32,color:#000

    class DEV1,DEV2 dev
    class GH1,GH2,GH3 gh
    class CI,RELEASE,DEPLOY cicd
    class SUB,RG,DC,KV,VNET azure
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔄 Pipeline Architecture

### Workflow Relationships

```mermaid
flowchart LR
    subgraph "Trigger Events"
        T1([Push to feature/**])
        T2([Push to fix/**])
        T3([PR to main])
        T4([Manual Dispatch])
    end

    subgraph "Workflows"
        direction TB
        W1["ci.yml<br>Continuous Integration"]
        W2["release.yml<br>Branch-Based Release"]
        W3["deploy.yml<br>Deploy to Azure"]
    end

    subgraph "Artifacts & Outputs"
        A1[/"Versioned Artifacts"/]
        A2[/"GitHub Release"/]
        A3[(Azure Resources)]
    end

    T1 & T2 --> W1
    T3 --> W1
    T4 --> W2
    T4 --> W3

    W1 --> A1
    W2 --> A1
    W2 --> A2
    W3 --> A3

    classDef trigger fill:#2196F3,stroke:#1565C0,color:#fff
    classDef workflow fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef artifact fill:#4CAF50,stroke:#2E7D32,color:#fff

    class T1,T2,T3,T4 trigger
    class W1,W2,W3 workflow
    class A1,A2,A3 artifact
```

### Detailed CI/CD Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant CI as CI Workflow
    participant Release as Release Workflow
    participant Deploy as Deploy Workflow
    participant Azure as Azure

    rect rgb(227, 242, 253)
        Note over Dev,GH: Feature Development
        Dev->>GH: Push to feature/** branch
        GH->>CI: Trigger CI workflow
        CI->>CI: Generate version tag
        CI->>CI: Build Bicep templates
        CI->>GH: Upload artifacts
    end

    rect rgb(243, 229, 245)
        Note over Dev,GH: Pull Request
        Dev->>GH: Create PR to main
        GH->>CI: Trigger CI workflow
        CI->>CI: Validate & build
        CI-->>GH: PR check status
    end

    rect rgb(255, 243, 224)
        Note over GH,Release: Release Creation
        Dev->>Release: Manual trigger
        Release->>Release: Calculate version
        Release->>Release: Build artifacts
        Release->>GH: Create GitHub Release
    end

    rect rgb(232, 245, 233)
        Note over Deploy,Azure: Deployment
        Dev->>Deploy: Manual trigger
        Deploy->>Deploy: Build Bicep
        Deploy->>Azure: OIDC Authentication
        Deploy->>Azure: azd provision
        Azure-->>Deploy: Deployment status
    end
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🌍 Deployment Environments

### Environment Strategy

| Environment | Trigger | Purpose | Approval Required |
|-------------|---------|---------|-------------------|
| `dev` | Manual | Development testing | No |
| `staging` | Manual | Pre-production validation | Optional |
| `prod` | Manual | Production deployment | Yes (recommended) |

### Environment Configuration

```mermaid
flowchart TB
    subgraph "GitHub Environments"
        direction LR
        ENV1["dev"]
        ENV2["staging"]
        ENV3["prod"]
    end

    subgraph "Azure Subscriptions"
        direction LR
        SUB1["Dev Subscription"]
        SUB2["Staging Subscription"]
        SUB3["Prod Subscription"]
    end

    ENV1 --> |OIDC| SUB1
    ENV2 --> |OIDC| SUB2
    ENV3 --> |OIDC| SUB3

    classDef env fill:#2196F3,stroke:#1565C0,color:#fff
    classDef azure fill:#4CAF50,stroke:#2E7D32,color:#fff

    class ENV1,ENV2,ENV3 env
    class SUB1,SUB2,SUB3 azure
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔒 Security Architecture

### Authentication Flow

```mermaid
flowchart LR
    subgraph "GitHub Actions"
        GH1["Workflow Run"]
        GH2["Request OIDC Token"]
    end

    subgraph "Azure AD"
        AD1["Validate Token"]
        AD2["Issue Access Token"]
        AD3["Federated Credential"]
    end

    subgraph "Azure Resources"
        AZ1["Subscription"]
        AZ2["Resource Group"]
    end

    GH1 --> GH2
    GH2 --> |"JWT"| AD1
    AD1 --> AD3
    AD3 --> AD2
    AD2 --> |"Bearer Token"| AZ1
    AZ1 --> AZ2

    classDef github fill:#24292E,stroke:#1B1F23,color:#fff
    classDef azure fill:#0078D4,stroke:#005A9E,color:#fff

    class GH1,GH2 github
    class AD1,AD2,AD3,AZ1,AZ2 azure
```

### Security Controls

| Control | Implementation | Purpose |
|---------|----------------|---------|
| OIDC Authentication | Federated credentials | No stored secrets |
| Action Pinning | SHA commit references | Supply chain security |
| Least Privilege | Minimal permissions | Reduced attack surface |
| Concurrency Control | Job grouping | Prevent race conditions |
| Environment Protection | GitHub Environments | Approval gates |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📦 Infrastructure Components

### Bicep Module Structure

```mermaid
flowchart TB
    subgraph "Entry Point"
        MAIN["main.bicep"]
    end

    subgraph "src/workload"
        W1["workload.bicep"]
        W2["core/devCenter.bicep"]
        W3["core/catalog.bicep"]
        W4["core/environmentType.bicep"]
        W5["project/project.bicep"]
        W6["project/projectPool.bicep"]
    end

    subgraph "src/connectivity"
        C1["connectivity.bicep"]
        C2["vnet.bicep"]
        C3["networkConnection.bicep"]
    end

    subgraph "src/security"
        S1["security.bicep"]
        S2["keyVault.bicep"]
        S3["secret.bicep"]
    end

    subgraph "src/identity"
        I1["devCenterRoleAssignment.bicep"]
        I2["projectIdentityRoleAssignment.bicep"]
    end

    MAIN --> W1 & C1 & S1 & I1
    W1 --> W2 & W3 & W4 & W5 & W6
    C1 --> C2 & C3
    S1 --> S2 & S3

    classDef main fill:#F44336,stroke:#C62828,color:#fff
    classDef workload fill:#2196F3,stroke:#1565C0,color:#fff
    classDef connectivity fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef security fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef identity fill:#9C27B0,stroke:#6A1B9A,color:#fff

    class MAIN main
    class W1,W2,W3,W4,W5,W6 workload
    class C1,C2,C3 connectivity
    class S1,S2,S3 security
    class I1,I2 identity
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 💾 Artifact Management

### Artifact Flow

```mermaid
flowchart LR
    subgraph "Build Stage"
        B1["Bicep Source"]
        B2["az bicep build"]
        B3["ARM Templates"]
        B1 --> B2 --> B3
    end

    subgraph "Storage"
        S1["GitHub Artifacts<br>30-day retention"]
        S2["GitHub Releases<br>Permanent"]
    end

    subgraph "Deployment"
        D1["azd provision"]
        D2["Azure Resources"]
        D1 --> D2
    end

    B3 --> S1
    B3 --> S2
    S1 --> D1
    S2 --> D1

    classDef build fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef storage fill:#2196F3,stroke:#1565C0,color:#fff
    classDef deploy fill:#4CAF50,stroke:#2E7D32,color:#fff

    class B1,B2,B3 build
    class S1,S2 storage
    class D1,D2 deploy
```

### Versioning Scheme

| Component | Format | Example |
|-----------|--------|---------|
| Main releases | `v{major}.{minor}.{patch}` | `v1.2.3` |
| Feature builds | `v{major}.{minor}.{patch}-feature.{name}` | `v1.2.4-feature.auth` |
| Fix builds | `v{major}.{minor}.{patch}-fix.{name}` | `v1.3.0-fix.security` |
| PR builds | `v{major}.{minor}.{patch}-{type}-pr{number}` | `v1.2.4-feature.auth-pr123` |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🛠️ Deployment Process

### Pre-Deployment Checklist

- [ ] Azure subscription configured with OIDC federation
- [ ] GitHub repository variables set (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`)
- [ ] GitHub secrets configured (`KEY_VAULT_SECRET`)
- [ ] Target region validated for resource availability
- [ ] Environment protection rules configured (optional)

### Deployment Steps

1. **Trigger Deployment**
   - Navigate to Actions → Deploy to Azure
   - Select environment and region
   - Run workflow

2. **Build Phase**
   - Validates Azure configuration
   - Compiles Bicep templates
   - Uploads build artifacts

3. **Authentication**
   - Requests OIDC token from GitHub
   - Exchanges for Azure access token
   - Authenticates with azd CLI

4. **Provision**
   - Runs `azd provision`
   - Creates/updates Azure resources
   - Generates deployment summary

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📶 Monitoring & Observability

### Workflow Monitoring

| Metric | Location | Purpose |
|--------|----------|---------|
| Workflow runs | GitHub Actions | Pipeline execution history |
| Job duration | GitHub Actions | Performance tracking |
| Step summaries | GitHub Actions | Detailed execution logs |
| Deployment status | Azure Portal | Resource provisioning status |

### Recommended Alerts

- Workflow failure notifications
- Long-running deployment alerts
- Azure resource health monitoring

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 Related Documentation

- [DevOps Workflows](../devops/README.md) - Detailed workflow documentation
- [CI Workflow](../devops/ci.md) - Continuous integration details
- [Deploy Workflow](../devops/deploy.md) - Deployment process
- [Release Workflow](../devops/release.md) - Release management
