---
title: "createUsersAndAssignRole.ps1 Script"
description: "Assigns Azure DevCenter roles to the current signed-in user"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - scripts
  - azure
  - rbac
  - devcenter
---

# 👥 createUsersAndAssignRole.ps1

> **Assigns Azure DevCenter roles to the current signed-in user**

> [!NOTE]
> **Target Audience:** Azure Administrators, Platform Engineers  
> **Reading Time:** ~8 minutes

<details>
<summary>📍 Navigation</summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| [← createCustomRole.ps1](create-custom-role.md) | [Scripts Index](../README.md) | [deleteDeploymentCredentials.ps1 →](delete-deployment-credentials.md) |

</details>

---

## 📑 Table of Contents

- [🎯 Overview](#overview)
- [📊 Flow Visualization](#flow-visualization)
- [📝 Parameters](#parameters)
- [⚙️ Prerequisites](#prerequisites)
- [🔑 Assigned Roles](#assigned-roles)
- [🔧 Functions Reference](#functions-reference)
- [📝 Usage Examples](#usage-examples)
- [⚠️ Error Handling](#error-handling)
- [🔧 Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This script retrieves the current Azure AD signed-in user and assigns DevCenter-related RBAC roles at the subscription scope. Use this script when setting up a new user for DevCenter access or as part of environment initialization.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📊 Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([createUsersAndAssignRole.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph SubCheck["Subscription Resolution"]
        C{SubscriptionId provided?}:::decision
        D[(az account show)]:::external
    end
    
    subgraph UserLookup["User Identification"]
        E["New-UserRoleAssignments"]:::core
        F[(az ad signed-in-user show)]:::external
        G["Get current user Object ID"]:::core
    end
    
    subgraph RoleLoop["Role Assignment Loop"]
        H["For each DevCenter role"]:::core
        I["Set-AzureRole"]:::core
        I1{Role already assigned?}:::decision
        I2["Skip - already assigned"]:::core
        I3[(az role assignment create)]:::external
    end
    
    subgraph Exit["Script Exit"]
        J{All succeeded?}:::decision
        K[\Roles Assigned\]:::output
        L{{Error Handler}}:::error
    end
    
    A --> B --> C
    C -->|No| D --> E
    C -->|Yes| E
    E --> F --> G --> H
    H --> I --> I1
    I1 -->|Yes| I2 --> H
    I1 -->|No| I3 --> H
    H -->|All roles processed| J
    J -->|Yes| K
    J -->|No| L

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
| `-SubscriptionId` | `string` | No | Current subscription | `ValidatePattern` (GUID format) | Azure subscription ID for role scope |

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚙️ Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| Azure CLI (`az`) | Manage role assignments | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **Azure**: `Microsoft.Authorization/roleAssignments/write` at subscription scope
- Typically requires **Owner** or **User Access Administrator** role

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔑 Assigned Roles

The script assigns these DevCenter-specific roles:

| Role Name | Purpose |
|-----------|---------|
| `DevCenter Dev Box User` | Create and manage Dev Boxes |
| `DevCenter Project Admin` | Administer DevCenter projects |
| `Deployment Environments Reader` | View deployment environments |
| `Deployment Environments User` | Use deployment environments |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Functions Reference

### Function: `Set-AzureRole`

**Purpose:** Assigns an Azure RBAC role to a user, checking for existing assignment first.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `UserIdentityId` | `string` | Yes | Object ID of the user |
| `RoleName` | `string` | Yes | Name of the RBAC role |
| `PrincipalType` | `string` | Yes | Type: User, ServicePrincipal, or Group |
| `SubscriptionId` | `string` | Yes | Subscription ID for scope |

**Returns:** `[bool]` - `$true` if assignment succeeded or already exists, `$false` on error

**Behavior:**

1. Checks if role is already assigned using `az role assignment list`
2. If not assigned, creates new assignment
3. Skips with message if already assigned

---

### Function: `New-UserRoleAssignments`

**Purpose:** Creates all DevCenter role assignments for the current signed-in user.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `SubscriptionId` | `string` | Yes | Subscription ID for role assignments |

**Returns:** `[bool]` - `$true` if all assignments succeeded, `$false` otherwise

**Behavior:**

1. Retrieves current user's Object ID via `az ad signed-in-user show`
2. Iterates through predefined DevCenter roles
3. Calls `Set-AzureRole` for each role
4. Tracks success/failure of each assignment

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Usage Examples

### Basic Usage (Current Subscription)

```powershell
.\createUsersAndAssignRole.ps1
```

Assigns all DevCenter roles to the currently signed-in user.

### Specific Subscription

```powershell
.\createUsersAndAssignRole.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
```

<details>
<summary>Expected Output</summary>

```
Creating role assignments for user: a1b2c3d4-e5f6-7890-abcd-ef1234567890
Assigning 'DevCenter Dev Box User' role to identity a1b2c3d4-e5f6-7890-abcd-ef1234567890...
Role 'DevCenter Dev Box User' assigned successfully.
Assigning 'DevCenter Project Admin' role to identity a1b2c3d4-e5f6-7890-abcd-ef1234567890...
Role 'DevCenter Project Admin' assigned successfully.
Assigning 'Deployment Environments Reader' role to identity a1b2c3d4-e5f6-7890-abcd-ef1234567890...
Role 'Deployment Environments Reader' assigned successfully.
Assigning 'Deployment Environments User' role to identity a1b2c3d4-e5f6-7890-abcd-ef1234567890...
Role 'Deployment Environments User' assigned successfully.
All role assignments completed successfully for user: a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

</details>

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚠️ Error Handling

### Error Action Preference

```powershell
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All role assignments succeeded |
| `1` | One or more role assignments failed |

### Idempotency

The script is **idempotent** - running it multiple times will:

- Skip roles that are already assigned
- Only attempt to assign missing roles
- Not cause errors for existing assignments

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Failed to retrieve current subscription ID" | Not logged into Azure | Run `az login` |
| "Failed to retrieve current signed-in user's object ID" | Not logged into Azure AD | Run `az login` with Azure AD account |
| "Failed to assign role" | Insufficient permissions | Verify Owner/UAA role |
| Role already exists warning | Role previously assigned | This is expected - script continues |

### Verify Role Assignments

```powershell
# List current user's role assignments
$userId = az ad signed-in-user show --query id --output tsv
az role assignment list --assignee $userId --query "[].roleDefinitionName" --output table
```

## Security Considerations

- Script requires elevated Azure permissions to create role assignments
- Roles are assigned at **subscription scope** - consider if more restrictive scope is needed
- DevCenter roles grant access to Dev Box and Environment resources
- Review role capabilities before assignment

## Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `deleteUsersAndAssignedRoles.ps1` | Remove these role assignments | [delete-users-and-assigned-roles.md](delete-users-and-assigned-roles.md) |
| `createCustomRole.ps1` | Create custom role definitions | [create-custom-role.md](create-custom-role.md) |
| `generateDeploymentCredentials.ps1` | Create CI/CD service principal | [generate-deployment-credentials.md](generate-deployment-credentials.md) |

---

<div align="center">

[← createCustomRole.ps1](create-custom-role.md) | [⬆️ Back to Top](#-table-of-contents) | [deleteDeploymentCredentials.ps1 →](delete-deployment-credentials.md)

*DevExp-DevBox • createUsersAndAssignRole.ps1 Documentation*

</div>
