# cleanSetUp.ps1

> **Complete DevExp-DevBox infrastructure cleanup orchestrator**

## Overview

This script orchestrates the complete cleanup of DevExp-DevBox infrastructure, including Azure deployments, user role assignments, service principals, GitHub secrets, and resource groups. Use this script when you need to tear down an entire DevExp-DevBox environment.

## Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([cleanSetUp.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph Main["Main Orchestration"]
        C["Start-FullCleanup"]:::core
    end
    
    subgraph Deployments["Subscription Deployments"]
        D["Remove-SubscriptionDeployments"]:::core
        D1{Deployments exist?}:::decision
        D2["Delete each deployment"]:::core
        D3[\Deployments removed\]:::output
    end
    
    subgraph Users["User Cleanup"]
        E["Invoke-CleanupScript"]:::core
        E1["deleteUsersAndAssignedRoles.ps1"]:::external
    end
    
    subgraph Credentials["Credentials Cleanup"]
        F["Invoke-CleanupScript"]:::core
        F1["deleteDeploymentCredentials.ps1"]:::external
    end
    
    subgraph GitHub["GitHub Secret Cleanup"]
        G["Invoke-CleanupScript"]:::core
        G1["deleteGitHubSecretAzureCredentials.ps1"]:::external
    end
    
    subgraph Resources["Resource Groups"]
        H["Invoke-CleanupScript"]:::core
        H1["cleanUp.ps1"]:::external
    end
    
    subgraph Exit["Script Exit"]
        I{All succeeded?}:::decision
        J[\Success\]:::output
        K{{Error Handler}}:::error
    end
    
    A --> B --> C
    C --> D
    D --> D1
    D1 -->|Yes| D2 --> D3
    D1 -->|No| D3
    D3 --> E --> E1
    E1 --> F --> F1
    F1 --> G --> G1
    G1 --> H --> H1
    H1 --> I
    I -->|Yes| J
    I -->|No| K

    classDef entry fill:#2196F3,stroke:#1565C0,color:#fff
    classDef input fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef core fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef external fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef decision fill:#FFC107,stroke:#FFA000,color:#000
    classDef output fill:#2196F3,stroke:#1565C0,color:#fff
    classDef error fill:#F44336,stroke:#C62828,color:#fff
```

## Parameters

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `-EnvName` | `string` | No | `"gitHub"` | `ValidateNotNullOrEmpty` | The environment name used in resource naming |
| `-Location` | `string` | No | `"eastus2"` | `ValidateSet` | Azure region (eastus, eastus2, westus, westus2, westus3, northeurope, westeurope) |
| `-AppDisplayName` | `string` | No | `"ContosoDevEx GitHub Actions Enterprise App"` | `ValidateNotNullOrEmpty` | Display name of the Azure AD application to delete |
| `-GhSecretName` | `string` | No | `"AZURE_CREDENTIALS"` | `ValidateNotNullOrEmpty` | Name of the GitHub secret to delete |

## Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| Azure CLI (`az`) | Manage Azure resources and deployments | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| GitHub CLI (`gh`) | Manage GitHub secrets | [Install GitHub CLI](https://cli.github.com/) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **Azure**: Owner or Contributor + User Access Administrator on the subscription
- **Azure AD**: Application Administrator to delete service principals
- **GitHub**: Repository admin access to delete secrets

### Environment Variables

None required - all configuration via parameters.

## Functions Reference

### Function: `Remove-SubscriptionDeployments`

**Purpose:** Deletes all Azure Resource Manager deployments at the subscription level.

**Parameters:** None

**Returns:** `[bool]` - `$true` if successful, `$false` otherwise

**Behavior:**
1. Lists all subscription-level deployments using `az deployment sub list`
2. Iterates through each deployment and deletes it
3. Supports `-WhatIf` via `SupportsShouldProcess`
4. Continues on individual deployment failures

<details>
<summary>Example Output</summary>

```
Retrieving subscription deployments...
Deleting deployment: main-deployment-20240115
Deployment 'main-deployment-20240115' deleted.
```

</details>

---

### Function: `Invoke-CleanupScript`

**Purpose:** Executes a cleanup PowerShell script with proper error handling and path resolution.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `ScriptPath` | `string` | Yes | Relative path to the script from script directory |
| `Parameters` | `hashtable` | No | Parameters to pass to the invoked script |
| `Description` | `string` | Yes | Description for logging purposes |

**Returns:** `[bool]` - `$true` if successful or script not found (non-fatal), `$false` on execution failure

**Behavior:**
1. Resolves full path using `$Script:ScriptDirectory`
2. Validates script exists (returns `$true` with warning if missing)
3. Executes script with splatted parameters
4. Checks `$LASTEXITCODE` for success

---

### Function: `Start-FullCleanup`

**Purpose:** Orchestrates the complete cleanup process by calling all cleanup operations in sequence.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `AppDisplayName` | `string` | Yes | Azure AD application display name |
| `GhSecretName` | `string` | Yes | GitHub secret name |
| `EnvName` | `string` | Yes | Environment name |
| `Location` | `string` | Yes | Azure region |

**Returns:** `[bool]` - `$true` if all operations succeeded, `$false` otherwise

**Cleanup Sequence:**
1. Delete subscription deployments
2. Delete users and assigned roles
3. Delete deployment credentials (service principal)
4. Delete GitHub secret
5. Clean up resource groups

## Usage Examples

### Basic Cleanup (Default Parameters)

```powershell
.\cleanSetUp.ps1
```

Cleans up the environment using:
- Environment: `gitHub`
- Location: `eastus2`
- App: `ContosoDevEx GitHub Actions Enterprise App`
- Secret: `AZURE_CREDENTIALS`

### Production Environment Cleanup

```powershell
.\cleanSetUp.ps1 -EnvName "prod" -Location "westus2"
```

### Custom Application Cleanup

```powershell
.\cleanSetUp.ps1 -AppDisplayName "MyCompany DevOps Service Principal" -GhSecretName "AZURE_SP_CREDENTIALS"
```

### Dry Run (WhatIf)

```powershell
.\cleanSetUp.ps1 -WhatIf
```

Shows what would be deleted without making changes.

## Error Handling

### Error Action Preference

```powershell
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'
```

The script uses strict error handling - any unhandled error terminates execution.

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All cleanup operations completed successfully |
| `1` | One or more cleanup operations failed |

### Error Recovery

- Individual operation failures are logged but don't stop other cleanup operations
- The script tracks success/failure of each operation
- Final status reflects whether all operations succeeded

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Not logged into Azure" | Azure CLI not authenticated | Run `az login` before executing |
| "Failed to delete deployment" | Deployment in progress or locked | Wait for operations to complete or remove locks |
| Script not found warnings | Missing dependency scripts | Ensure all scripts exist in `.configuration` folder |
| Permission denied | Insufficient Azure/GitHub permissions | Verify role assignments |

### Debugging

Enable verbose output:

```powershell
.\cleanSetUp.ps1 -Verbose
```

## Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `setUp.ps1` | Initial environment setup (opposite of cleanup) | [setup.md](setup.md) |
| `deleteUsersAndAssignedRoles.ps1` | Remove user role assignments | [azure/delete-users-and-assigned-roles.md](azure/delete-users-and-assigned-roles.md) |
| `deleteDeploymentCredentials.ps1` | Remove service principals | [azure/delete-deployment-credentials.md](azure/delete-deployment-credentials.md) |
| `deleteGitHubSecretAzureCredentials.ps1` | Remove GitHub secrets | [github/delete-github-secret-azure-credentials.md](github/delete-github-secret-azure-credentials.md) |
| `cleanUp.ps1` | Remove Azure resource groups | [configuration/clean-up.md](configuration/clean-up.md) |
