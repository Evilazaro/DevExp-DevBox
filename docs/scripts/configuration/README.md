---
title: "Configuration PowerShell Scripts"
description: "Documentation for Azure resource cleanup and Windows configuration scripts"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - scripts
  - configuration
  - azure
  - windows
  - cleanup
---

# ⚙️ Configuration PowerShell Scripts

> **Documentation for Azure resource cleanup and Windows configuration scripts**

> [!NOTE]
> **Target Audience:** Azure Administrators, System Administrators, DevOps Engineers  
> **Reading Time:** ~3 minutes

<details>
<summary>📍 Navigation</summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| [← GitHub Scripts](../github/README.md) | [Docs Index](../../README.md) | — |

</details>

---

## 📑 Table of Contents

- [🎯 Overview](#-overview)
- [📜 Scripts Inventory](#-scripts-inventory)
- [🔄 Workflow Diagram](#-workflow-diagram)
- [⚙️ Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [🔗 Related Documentation](#-related-documentation)

---

## 🎯 Overview

This folder contains PowerShell scripts for managing Azure resource groups and configuring Windows environments. These utility scripts support environment cleanup and Dev Box workload configuration.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📜 Scripts Inventory

| Script | Purpose | Documentation |
|:-------|:--------|:--------------|
| 🧹 `cleanUp.ps1` | Deletes Azure resource groups for DevExp-DevBox | [clean-up.md](clean-up.md) |
| 📦 `winget-update.ps1` | Updates Microsoft Store applications silently | [winget-update.md](winget-update.md) |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔄 Workflow Diagram

```mermaid
---
title: Configuration Scripts Workflow
---
flowchart TB
    %% ===== CLEANUP SCRIPTS =====
    subgraph Cleanup["🗑️ Azure Cleanup"]
        direction TB
        A["🧹 cleanUp.ps1"]
        A1["Delete resource groups"]
        A2["Remove deployments"]
    end
    
    %% ===== CONFIGURATION SCRIPTS =====
    subgraph Config["📦 Windows Configuration"]
        direction TB
        B["📦 winget-update.ps1"]
        B1["Update Store apps"]
        B2["Multi-pass upgrade"]
    end
    
    %% ===== CONNECTIONS =====
    A --> A1 --> A2
    B --> B1 --> B2

    %% ===== NODE STYLES =====
    classDef primary fill:#4F46E5,stroke:#3730A3,color:#FFFFFF
    classDef secondary fill:#10B981,stroke:#059669,color:#FFFFFF
    
    class A,A1,A2 primary
    class B,B1,B2 secondary

    %% ===== SUBGRAPH STYLES =====
    style Cleanup fill:#FEE2E2,stroke:#F44336,stroke-width:2px
    style Config fill:#ECFDF5,stroke:#10B981,stroke-width:2px
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚙️ Prerequisites

> [!IMPORTANT]
> Each script has specific requirements. See individual documentation for details.

### cleanUp.ps1 Requirements

| Tool | Purpose | Installation |
|:-----|:--------|:-------------|
| Azure CLI (`az`) | Delete Azure resources | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### winget-update.ps1 Requirements

| Tool | Purpose | Installation |
|:-----|:--------|:-------------|
| Windows Package Manager (`winget`) | Package management | [App Installer](https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |
| Administrator privileges | Machine-wide updates | Run as Administrator |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🚀 Quick Start

### Resource Group Cleanup

> [!CAUTION]
> This operation is **destructive** and cannot be undone.

```powershell
# 1. Login to Azure
az login

# 2. Run cleanup with default parameters
.\cleanUp.ps1

# 3. Or specify environment and location
.\cleanUp.ps1 -EnvName "prod" -Location "westus2"
```

### Windows Store App Updates

> [!TIP]
> Run as Administrator for machine-wide updates.

```powershell
# Run with elevated privileges
Start-Process powershell -Verb RunAs -ArgumentList "-File `".\winget-update.ps1`""
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 Related Documentation

| Document | Description |
|:---------|:------------|
| [Scripts Index](../README.md) | Main scripts documentation |
| [cleanSetUp.ps1](../clean-setup.md) | Full environment cleanup orchestrator |
| [Azure Scripts](../azure/README.md) | Azure RBAC and credential management |
| [GitHub Scripts](../github/README.md) | GitHub secret management |

---

[⬆️ Back to Top](#-table-of-contents)

---

<div align="center">

[← GitHub Scripts](../github/README.md) | [⬆️ Back to Top](#-table-of-contents)

*DevExp-DevBox • Configuration Scripts Documentation*

</div>
