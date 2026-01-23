# deleteGitHubSecretAzureCredentials.ps1

> **Removes a GitHub repository secret**

## Overview

This script authenticates to GitHub using the GitHub CLI and removes a specified secret from the current repository. Typically used to remove the `AZURE_CREDENTIALS` secret during cleanup operations.

## Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([deleteGitHubSecretAzureCredentials.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph Auth["GitHub Authentication"]
        C["Connect-GitHubCli"]:::core
        D[(gh auth status)]:::external
        E{Authenticated?}:::decision
        F[(gh auth login)]:::external
    end
    
    subgraph SecretDeletion["Secret Deletion"]
        G["Remove-GitHubRepositorySecret"]:::core
        H[(gh secret remove)]:::external
        I{Secret existed?}:::decision
    end
    
    subgraph Exit["Script Exit"]
        J[\Secret Removed\]:::output
        K[\Secret Not Found - OK\]:::output
        L{{Error Handler}}:::error
    end
    
    A --> B --> C --> D --> E
    E -->|Yes| G
    E -->|No| F --> G
    G --> H --> I
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
| `-GhSecretName` | `string` | Yes | - | `ValidateNotNullOrEmpty` | Name of the GitHub secret to delete |

**Aliases:** `ghSecretName`

## Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| GitHub CLI (`gh`) | Manage repository secrets | [Install GitHub CLI](https://cli.github.com/) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **GitHub**: Repository admin or secrets delete permission
- Must be in a Git repository directory or specify repository

## Functions Reference

### Function: `Connect-GitHubCli`

**Purpose:** Ensures GitHub CLI is authenticated, prompting for login if needed.

**Parameters:** None

**Returns:** `[bool]` - `$true` if authenticated successfully, `$false` otherwise

**Behavior:**

1. Checks authentication status with `gh auth status`
2. If not authenticated, triggers `gh auth login` interactive flow
3. Returns success/failure status

---

### Function: `Remove-GitHubRepositorySecret`

**Purpose:** Removes a secret from the GitHub repository.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `SecretName` | `string` | Yes | Name of the secret to remove |

**Returns:** `[bool]` - `$true` if secret removed or didn't exist, `$false` on error

**Behavior:**

1. Supports `-WhatIf` for dry run
2. Attempts to remove secret via `gh secret remove`
3. Non-zero exit code treated as warning (secret may not exist)
4. Returns `$true` even if secret didn't exist (idempotent)

**Command:** `gh secret remove {SecretName}`

## Usage Examples

### Delete Default Azure Credentials Secret

```powershell
.\deleteGitHubSecretAzureCredentials.ps1 -GhSecretName "AZURE_CREDENTIALS"
```

### Delete Custom Secret

```powershell
.\deleteGitHubSecretAzureCredentials.ps1 -GhSecretName "MY_CUSTOM_SECRET"
```

### Dry Run (WhatIf)

```powershell
.\deleteGitHubSecretAzureCredentials.ps1 -GhSecretName "AZURE_CREDENTIALS" -WhatIf
```

<details>
<summary>Expected Output</summary>

```
Starting GitHub secret deletion...
Checking GitHub authentication status...
Already authenticated to GitHub.
Removing GitHub secret: AZURE_CREDENTIALS
GitHub secret 'AZURE_CREDENTIALS' removed successfully.

GitHub secret deletion completed.
```

</details>

## Error Handling

### Error Action Preference

```powershell
$ErrorActionPreference = 'Stop'
$WarningPreference = 'Stop'
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Secret removed or didn't exist |
| `1` | Critical failure (authentication, etc.) |

### Idempotency

The script is **idempotent**:

- If secret doesn't exist, returns success with warning
- Safe to run multiple times
- No error if already deleted

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Failed to authenticate to GitHub" | gh login failed | Run `gh auth login` manually |
| "Secret may not exist" | Secret already deleted | Expected - script continues |
| "Permission denied" | Insufficient repo permissions | Verify admin access |
| "Not a git repository" | Wrong working directory | Navigate to repository root |

### Verify Secret Deletion

```powershell
# List remaining repository secrets
gh secret list
```

### Check Before Deletion

```powershell
# View existing secrets
gh secret list | findstr "AZURE_CREDENTIALS"
```

## Security Considerations

### Immediate Effect

- Deleting the secret **immediately** affects workflow runs
- Any workflows using the secret will fail after deletion
- No grace period or rollback available

### Before Deletion Checklist

- [ ] Verify no workflows are actively using the secret
- [ ] Confirm CI/CD pipelines can tolerate temporary failures
- [ ] Have replacement credentials ready if needed

### Audit Trail

- GitHub audit logs record secret deletion
- Deletion cannot be undone - must recreate secret

## Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `createGitHubSecretAzureCredentials.ps1` | Create GitHub secret | [create-github-secret-azure-credentials.md](create-github-secret-azure-credentials.md) |
| `deleteDeploymentCredentials.ps1` | Remove service principal | [../azure/delete-deployment-credentials.md](../azure/delete-deployment-credentials.md) |
| `cleanSetUp.ps1` | Full environment cleanup | [../clean-setup.md](../clean-setup.md) |
