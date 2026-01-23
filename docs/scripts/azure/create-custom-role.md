---
title: "createCustomRole.ps1 Script"
description: "Creates a custom Azure RBAC role for role assignment management"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - scripts
  - azure
  - rbac
  - security
---

# 🔑 createCustomRole.ps1

> **Creates a custom Azure RBAC role for role assignment management**

> [!IMPORTANT]
> This script requires **Owner** or **User Access Administrator** permissions on the target subscription.

> [!NOTE]
> **Target Audience:** Azure Administrators, Security Engineers  
> **Reading Time:** ~8 minutes

<details>
<summary>📍 Navigation</summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| [← cleanSetUp.ps1](../clean-setup.md) | [Scripts Index](../README.md) | [createUsersAndAssignRole.ps1 →](create-users-and-assign-role.md) |

</details>

---

## 📑 Table of Contents

- [🎯 Overview](#overview)
- [📊 Flow Visualization](#flow-visualization)
- [📝 Parameters](#parameters)
- [⚙️ Prerequisites](#prerequisites)
- [📜 Role Definition](#role-definition)
- [🔧 Functions Reference](#functions-reference)
- [📝 Usage Examples](#usage-examples)
- [⚠️ Error Handling](#error-handling)

---

## 🎯 Overview

This script creates a custom Azure RBAC role definition that grants permissions to manage role assignments. The role includes permissions to read, write, and delete role assignments within a specified subscription scope. Use this script when you need to delegate role assignment capabilities without granting full User Access Administrator permissions.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📊 Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([createCustomRole.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph SubCheck["Subscription Resolution"]
        C{SubscriptionId provided?}:::decision
        D["Get-CurrentSubscriptionId"]:::core
        E[(Azure CLI)]:::external
    end
    
    subgraph RoleCreation["Role Definition Creation"]
        F["New-CustomRoleDefinition"]:::core
        F1["Build role definition JSON"]:::core
        F2["Write to temp file"]:::core
        F3{Force flag set?}:::decision
        F4["Delete existing role"]:::core
        F5[(az role definition create)]:::external
    end
    
    subgraph Cleanup["Cleanup"]
        G["Remove temp file"]:::core
    end
    
    subgraph Exit["Script Exit"]
        H{Success?}:::decision
        I[\Role Created\]:::output
        J{{Error Handler}}:::error
    end
    
    A --> B --> C
    C -->|No| D --> E
    C -->|Yes| F
    E --> F
    F --> F1 --> F2 --> F3
    F3 -->|Yes| F4 --> F5
    F3 -->|No| F5
    F5 --> G --> H
    H -->|Yes| I
    H -->|No| J

    classDef entry fill:#2196F3,stroke:#1565C0,color:#fff
    classDef input fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef core fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef external fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef decision fill:#FFC107,stroke:#FFA000,color:#000
    classDef output fill:#2196F3,stroke:#1565C0,color:#fff
    classDef error fill:#F44336,stroke:#C62828,color:#fff
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Parameters

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `-RoleName` | `string` | No | `"Contoso DevBox - Role Assignment Writer"` | `ValidateNotNullOrEmpty` | Display name for the custom role |
| `-SubscriptionId` | `string` | No | Current subscription | `ValidatePattern` (GUID format) | Azure subscription ID for scope |
| `-Description` | `string` | No | `"Allows creating role assignments."` | - | Description for the custom role |
| `-Force` | `switch` | No | `$false` | - | Delete existing role before creating |

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚙️ Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| Azure CLI (`az`) | Create role definitions | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **Azure**: `Microsoft.Authorization/roleDefinitions/write` at subscription scope
- Typically requires **Owner** or **User Access Administrator** role

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📜 Role Definition

The created role includes these permissions:

```json
{
  "Name": "Contoso DevBox - Role Assignment Writer",
  "IsCustom": true,
  "Description": "Allows creating role assignments.",
  "Actions": [
    "Microsoft.Authorization/roleAssignments/write",
    "Microsoft.Authorization/roleAssignments/delete",
    "Microsoft.Authorization/roleAssignments/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/{subscriptionId}"
  ]
}
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Functions Reference

### Function: `Get-CurrentSubscriptionId`

**Purpose:** Retrieves the current Azure subscription ID from Azure CLI context.

**Parameters:** None

**Returns:** `[string]` - The subscription ID GUID

**Throws:** Error if not logged into Azure CLI

---

### Function: `New-CustomRoleDefinition`

**Purpose:** Creates a custom Azure RBAC role definition from a JSON template.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RoleName` | `string` | Yes | Name of the custom role |
| `SubscriptionId` | `string` | Yes | Subscription ID for scope |
| `Description` | `string` | No | Role description |
| `RemoveExisting` | `switch` | No | Delete existing role first |

**Returns:** `[bool]` - `$true` if successful, `$false` otherwise

**Behavior:**

1. Builds role definition hashtable
2. Converts to JSON and writes to temp file in `$env:TEMP`
3. Optionally deletes existing role with same name
4. Creates role via `az role definition create`
5. Cleans up temp file (in finally block)

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Usage Examples

### Basic Usage (Current Subscription)

```powershell
.\createCustomRole.ps1
```

Creates role with default name in the current subscription.

### Specific Subscription

```powershell
.\createCustomRole.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
```

### Custom Role Name

```powershell
.\createCustomRole.ps1 -RoleName "MyCompany - Role Writer" -Description "Custom role for CI/CD pipelines"
```

### Replace Existing Role

```powershell
.\createCustomRole.ps1 -Force
```

Deletes any existing role with the same name before creating.

### Dry Run (WhatIf)

```powershell
.\createCustomRole.ps1 -WhatIf
```

Shows what would be created without making changes.

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚠️ Error Handling

### Error Action Preference

```powershell
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Role created successfully |
| `1` | Role creation failed |

### Cleanup Guarantee

The temporary JSON file is always cleaned up via `finally` block, even if creation fails.

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Failed to retrieve current subscription ID" | Not logged into Azure | Run `az login` |
| "Failed to create custom role definition" | Insufficient permissions | Verify Owner/UAA role |
| Role already exists error | Role with same name exists | Use `-Force` parameter |
| Invalid subscription ID format | GUID validation failed | Check subscription ID format |

### Verify Role Creation

```powershell
# List custom roles
az role definition list --custom-role-only true --query "[?roleName=='Contoso DevBox - Role Assignment Writer']"
```

## Security Considerations

- Custom roles should follow **least privilege** principle
- The created role only grants role assignment permissions, not resource management
- Consider scope carefully - subscription-wide vs resource group specific
- Temporary JSON file is written to `$env:TEMP` and immediately deleted

## Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `createUsersAndAssignRole.ps1` | Assign DevCenter roles to users | [create-users-and-assign-role.md](create-users-and-assign-role.md) |
| `deleteUsersAndAssignedRoles.ps1` | Remove role assignments | [delete-users-and-assigned-roles.md](delete-users-and-assigned-roles.md) |
| `generateDeploymentCredentials.ps1` | Create CI/CD service principal | [generate-deployment-credentials.md](generate-deployment-credentials.md) |

---

<div align="center">

[← cleanSetUp.ps1](../clean-setup.md) | [⬆️ Back to Top](#-table-of-contents) | [createUsersAndAssignRole.ps1 →](create-users-and-assign-role.md)

*DevExp-DevBox • createCustomRole.ps1 Documentation*

</div>
