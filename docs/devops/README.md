---
title: "DevOps Documentation"
description: "Comprehensive documentation for GitHub Actions workflows in the Dev Box Accelerator project"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - devops
  - github-actions
  - cicd
  - workflows
---

# 🔄 DevOps Documentation

> 📖 Comprehensive documentation for GitHub Actions workflows in the Dev Box Accelerator project.

> [!NOTE]
> **Target Audience:** DevOps Engineers, Platform Engineers, CI/CD Administrators  
> **Reading Time:** ~10 minutes

<details>
<summary>📍 Navigation</summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| — | [Docs Index](../README.md) | [CI Workflow →](ci.md) |

</details>

---

## 📑 Table of Contents

- [🎯 Overview](#-overview)
- [🏗️ Master Pipeline Architecture](#%EF%B8%8F-master-pipeline-architecture)
- [📚 Workflow Documentation](#-workflow-documentation)
- [⚡ Quick Reference](#-quick-reference)
- [🔄 Reusable Components](#-reusable-components)
- [🏷️ Versioning Strategy](#%EF%B8%8F-versioning-strategy)
- [✅ Best Practices](#-best-practices)
- [🔗 Related Documentation](#-related-documentation)

---

## 🎯 Overview

This folder contains detailed documentation for all CI/CD workflows that automate the build, test, and deployment processes for the Dev Box Accelerator infrastructure-as-code project.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🏗️ Master Pipeline Architecture

The following diagram shows the complete CI/CD pipeline architecture and how all workflows relate to each other:

```mermaid
---
title: Master Pipeline Architecture
---
flowchart TB
    %% ===== TRIGGERS =====
    subgraph Triggers["🎯 Triggers"]
        direction LR
        T1(["🌿 Push: feature/**"])
        T2(["🔧 Push: fix/**"])
        T3(["📝 PR to main"])
        T4(["🖱️ Manual: Deploy"])
        T5(["🖱️ Manual: Release"])
    end

    %% ===== CONTINUOUS INTEGRATION =====
    subgraph CI["🔄 Continuous Integration"]
        direction TB
        CI1["📊 generate-tag-version"]
        CI2["🔨 build"]
        CI1 -->|calculates| CI2
    end

    %% ===== DEPLOYMENT =====
    subgraph Deployment["🚀 Deployment"]
        direction TB
        D1["✅ Validate Variables"]
        D2["🔨 Build Bicep"]
        D3["🔐 Azure OIDC Auth"]
        D4["☁️ azd provision"]
        D1 -->|validates| D2 -->|authenticates| D3 -->|provisions| D4
    end

    %% ===== RELEASE =====
    subgraph Release["🏷️ Release"]
        direction TB
        R1["📊 generate-release"]
        R2["🔨 build"]
        R3["🎉 publish-release"]
        R4["📋 summary"]
        R1 -->|prepares| R2 -->|publishes| R3 -->|summarizes| R4
    end

    %% ===== OUTPUTS =====
    subgraph Outputs["📦 Outputs"]
        direction TB
        O1[/"✅ Versioned Artifacts"/]
        O2[/"🏷️ GitHub Release"/]
        O3[("☁️ Azure Resources")]
    end

    %% ===== CONNECTIONS =====
    T1 & T2 & T3 -->|triggers| CI1
    T4 -->|triggers| D1
    T5 -->|triggers| R1

    CI2 -->|produces| O1
    R3 -->|creates| O1
    R3 -->|creates| O2
    D4 -->|provisions| O3

    %% ===== STYLES =====
    classDef trigger fill:#818CF8,stroke:#4F46E5,color:#FFFFFF
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    classDef datastore fill:#F59E0B,stroke:#D97706,color:#000000
    classDef external fill:#6B7280,stroke:#4B5563,color:#FFFFFF,stroke-dasharray:5 5

    class T1,T2,T3,T4,T5 trigger
    class CI1,CI2 primary
    class D1,D2,D3,D4 secondary
    class R1,R2,R3,R4 datastore
    class O1,O2,O3 external
    
    %% ===== SUBGRAPH STYLES =====
    style Triggers fill:#EEF2FF,stroke:#4F46E5,stroke-width:2px
    style CI fill:#E0E7FF,stroke:#4F46E5,stroke-width:2px
    style Deployment fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style Release fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px
    style Outputs fill:#F3F4F6,stroke:#6B7280,stroke-width:2px
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📚 Workflow Documentation

| Workflow | File | Purpose | Trigger |
|----------|------|---------|---------|
| [Continuous Integration](ci.md) | `ci.yml` | Builds and validates Bicep templates | Push to `feature/**`, `fix/**`; PRs to `main` |
| [Deploy to Azure](deploy.md) | `deploy.yml` | Provisions infrastructure to Azure | Manual (`workflow_dispatch`) |
| [Branch-Based Release](release.md) | `release.yml` | Creates GitHub releases with versioned artifacts | Manual (`workflow_dispatch`) |

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚡ Quick Reference

### Trigger Summary

```mermaid
---
title: Trigger Summary
---
flowchart LR
    %% ===== AUTOMATIC TRIGGERS =====
    subgraph AutoTriggers["🔄 Automatic Triggers"]
        A1["🌿 Push to feature/**"] -->|triggers| CI["📊 CI Workflow"]
        A2["🔧 Push to fix/**"] -->|triggers| CI
        A3["📝 PR to main"] -->|triggers| CI
    end

    %% ===== MANUAL TRIGGERS =====
    subgraph ManualTriggers["🖱️ Manual Triggers"]
        M1["🖱️ workflow_dispatch"] -->|triggers| DEPLOY["🚀 Deploy Workflow"]
        M2["🖱️ workflow_dispatch"] -->|triggers| RELEASE["🏷️ Release Workflow"]
    end

    %% ===== STYLES =====
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    classDef trigger fill:#818CF8,stroke:#4F46E5,color:#FFFFFF
    classDef datastore fill:#F59E0B,stroke:#D97706,color:#000000

    class A1,A2,A3 secondary
    class M1,M2 trigger
    class CI,DEPLOY,RELEASE datastore
    
    %% ===== SUBGRAPH STYLES =====
    style AutoTriggers fill:#ECFDF5,stroke:#10B981,stroke-width:2px
    style ManualTriggers fill:#EEF2FF,stroke:#4F46E5,stroke-width:2px
```

### Required Secrets & Variables

| Name | Type | Used By | Description |
|------|------|---------|-------------|
| `AZURE_CLIENT_ID` | Variable | Deploy | Azure AD App Registration Client ID |
| `AZURE_TENANT_ID` | Variable | Deploy | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Variable | Deploy | Target Azure Subscription |
| `KEY_VAULT_SECRET` | Secret | Deploy | Key Vault secret value |
| `GITHUB_TOKEN` | Secret (Auto) | Release | Auto-provided for GitHub API access |

### Permissions Matrix

| Permission | CI | Deploy | Release | Purpose |
|------------|:--:|:------:|:-------:|---------|
| `contents: write` | ✅ | ❌ | ✅ | Create tags and releases |
| `contents: read` | ✅ | ✅ | ✅ | Checkout repository |
| `pull-requests: read` | ✅ | ❌ | ✅ | Access PR information |
| `id-token: write` | ❌ | ✅ | ❌ | OIDC authentication |
| `actions: read` | ❌ | ❌ | ✅ | Workflow introspection |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔄 Reusable Components

### Composite Actions

| Action | Location | Purpose |
|--------|----------|---------|
| Bicep Standard CI | `.github/actions/ci/bicep-standard-ci` | Builds Bicep templates and uploads artifacts |
| Generate Release | `.github/actions/ci/generate-release` | Calculates semantic versions based on branch strategy |

### Action Flow

```mermaid
---
title: Reusable Actions Flow
---
flowchart LR
    %% ===== GENERATE RELEASE ACTION =====
    subgraph GenerateRelease["🏷️ generate-release"]
        GR1["📋 Get Branch Info"]
        GR2["🏷️ Get Latest Tag"]
        GR3["🔍 Determine Release Type"]
        GR4["📊 Count Commits"]
        GR5["🔢 Calculate Version"]
        GR6["🏷️ Create Tag"]
        GR1 -->|gets| GR2 -->|determines| GR3 -->|counts| GR4 -->|calculates| GR5 -->|creates| GR6
    end

    %% ===== BICEP STANDARD CI ACTION =====
    subgraph BicepCI["🔨 bicep-standard-ci"]
        BC1["📦 Build Bicep"]
        BC2["📤 Upload Artifacts"]
        BC3["📊 Generate Summary"]
        BC1 -->|uploads| BC2 -->|summarizes| BC3
    end

    %% ===== STYLES =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    
    class GR1,GR2,GR3,GR4,GR5,GR6 primary
    class BC1,BC2,BC3 secondary
    
    %% ===== SUBGRAPH STYLES =====
    style GenerateRelease fill:#E0E7FF,stroke:#4F46E5,stroke-width:2px
    style BicepCI fill:#ECFDF5,stroke:#10B981,stroke-width:2px
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🏷️ Versioning Strategy

The project uses a **branch-based semantic versioning** strategy:

| Branch | Version Behavior | Example |
|--------|------------------|---------|
| `main` | Conditional major increment | `v2.0.0` |
| `feature/**` | Patch increment + suffix | `v1.2.4-feature.auth` |
| `fix/**` | Minor increment + suffix | `v1.3.0-fix.security` |

### Version Overflow Handling

- **Patch > 99**: Resets to 0, increments minor
- **Minor > 99**: Resets to 0, increments major

---

[⬆️ Back to Top](#-table-of-contents)

---

## ✅ Best Practices

### Security

- ✅ All actions pinned to SHA commits for supply chain security
- ✅ OIDC authentication used for Azure (no long-lived secrets)
- ✅ Least-privilege permissions configured per workflow
- ✅ Concurrency controls prevent conflicting operations

### Reliability

- ✅ Timeout limits set on all jobs
- ✅ Comprehensive error handling and validation
- ✅ Step summaries for visibility into workflow execution
- ✅ Artifact retention policies configured

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 Related Documentation

- [Deployment Architecture](../architecture/07-deployment-architecture.md) - Infrastructure deployment patterns
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/) - Tool used for deployments
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) - Security best practices

---

<div align="center">

[⬆️ Back to Top](#-devops-documentation) | [CI Workflow →](ci.md)

*DevExp-DevBox • DevOps Documentation*

</div>
