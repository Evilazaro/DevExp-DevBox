# generateDeploymentCredentials.ps1

> **Creates Azure service principal and GitHub secret for CI/CD pipelines**

## Overview

This script creates an Azure AD service principal with required roles for CI/CD pipelines and configures the credentials as a GitHub repository secret. Use this script when setting up GitHub Actions workflows that need to deploy Azure resources.

## Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([generateDeploymentCredentials.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
    end
    
    subgraph SPCreation["Service Principal Creation"]
        C["New-AzureDeploymentCredentials"]:::core
        D[(az ad sp create-for-rbac)]:::external
        E["Assign Contributor role"]:::core
        F[(az role assignment create)]:::external
        G["Assign User Access Administrator"]:::core
        H["Assign Managed Identity Contributor"]:::core
    end
    
    subgraph UserRoles["User Role Setup"]
        I["Invoke-UserRoleAssignment"]:::core
        J["createUsersAndAssignRole.ps1"]:::external
    end
    
    subgraph GitHubSecret["GitHub Secret Creation"]
        K["Invoke-GitHubSecretCreation"]:::core
        L["createGitHubSecretAzureCredentials.ps1"]:::external
    end
    
    subgraph Exit["Script Exit"]
        M{All succeeded?}:::decision
        N[\Credentials Created\]:::output
        O{{Warning: Partial failure}}:::error
    end
    
    A --> B --> C --> D --> E --> F --> G --> H
    H --> I --> J
    J --> K --> L --> M
    M -->|Yes| N
    M -->|No| O

    classDef entry fill:#2196F3,stroke:#1565C0,color:#fff
    classDef input fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef core fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef external fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef decision fill:#FFC107,stroke:#FFA000,color:#000
    classDef output fill:#2196F3,stroke:#1565C0,color:#fff
    classDef error fill:#F44336,stroke:#C62828,color:#fff
```

## Service Principal Creation Flow

```mermaid
sequenceDiagram
    participant Script as generateDeploymentCredentials.ps1
    participant AzCLI as Azure CLI
    participant AzAD as Azure AD
    participant GhCLI as GitHub CLI
    participant GhRepo as GitHub Repository

    Script->>AzCLI: az account show
    AzCLI-->>Script: Subscription ID
    
    Script->>AzCLI: az ad sp create-for-rbac
    AzCLI->>AzAD: Create App Registration
    AzAD-->>AzCLI: App ID + Secret
    AzCLI-->>Script: JSON credentials
    
    Script->>AzCLI: az role assignment create (UAA)
    Script->>AzCLI: az role assignment create (MIC)
    
    Script->>Script: createUsersAndAssignRole.ps1
    
    Script->>Script: createGitHubSecretAzureCredentials.ps1
    Script->>GhCLI: gh secret set AZURE_CREDENTIALS
    GhCLI->>GhRepo: Store encrypted secret
    GhRepo-->>Script: Secret created
```

## Parameters

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `-AppName` | `string` | Yes | - | `ValidateNotNullOrEmpty` | Name for the Azure AD application registration |
| `-DisplayName` | `string` | Yes | - | `ValidateNotNullOrEmpty` | Display name for the service principal |

## Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| Azure CLI (`az`) | Create service principal and roles | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| GitHub CLI (`gh`) | Create repository secret | [Install GitHub CLI](https://cli.github.com/) |
| PowerShell 5.1+ | Script execution | Pre-installed on Windows |

### Required Permissions

- **Azure**: Owner or Contributor + User Access Administrator on subscription
- **Azure AD**: `Application.ReadWrite.All` or Application Administrator
- **GitHub**: Repository admin access to create secrets

## Assigned Roles

The created service principal receives these roles at subscription scope:

| Role | Purpose |
|------|---------|
| `Contributor` | Deploy and manage Azure resources |
| `User Access Administrator` | Create role assignments for deployed resources |
| `Managed Identity Contributor` | Create and manage managed identities |

## Functions Reference

### Function: `New-AzureDeploymentCredentials`

**Purpose:** Creates an Azure service principal with required roles for CI/CD.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `AppName` | `string` | Yes | Application registration name |
| `DisplayName` | `string` | Yes | Service principal display name |

**Returns:** `[string]` - JSON credentials body for GitHub Actions, or `$null` on failure

**Created Credentials Format:**

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

---

### Function: `Invoke-UserRoleAssignment`

**Purpose:** Executes the `createUsersAndAssignRole.ps1` script to assign DevCenter roles.

**Returns:** `[bool]` - `$true` if successful, `$false` otherwise

**Called Script:** `createUsersAndAssignRole.ps1` (same directory)

---

### Function: `Invoke-GitHubSecretCreation`

**Purpose:** Executes the GitHub secret creation script.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `CredentialsJson` | `string` | Yes | JSON credentials to store as secret |

**Returns:** `[bool]` - `$true` if successful, `$false` otherwise

**Called Script:** `..\GitHub\createGitHubSecretAzureCredentials.ps1`

## Usage Examples

### Create Deployment Credentials

```powershell
.\generateDeploymentCredentials.ps1 -AppName "contoso-devbox-cicd" -DisplayName "Contoso DevBox CI/CD"
```

### With Verbose Output

```powershell
.\generateDeploymentCredentials.ps1 -AppName "myapp-deploy" -DisplayName "MyApp Deployment SP" -Verbose
```

<details>
<summary>Expected Output</summary>

```
Starting deployment credentials generation...
App Name: contoso-devbox-cicd
Display Name: Contoso DevBox CI/CD
Creating service principal 'Contoso DevBox CI/CD' in subscription: 12345678-1234-1234-1234-123456789012
Service principal created with App ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
Assigning additional roles...
Assigned: User Access Administrator
Assigned: Managed Identity Contributor
Role assignments completed successfully.

Service principal credentials (for reference):
{
  "clientId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "clientSecret": "xxx~xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "12345678-1234-1234-1234-123456789012",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

Creating user role assignments...
User role assignments completed successfully.
Creating GitHub secret for Azure credentials...
GitHub secret created successfully.

Deployment credentials generation completed.
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
| `0` | Credentials created (GitHub secret may have warnings) |
| `1` | Critical failure during credential creation |

### Partial Failure Handling

The script continues with warnings if:

- User role assignment fails (non-critical)
- GitHub secret creation fails (credentials still valid)

Credentials are displayed on console if GitHub secret creation fails.

## Security Considerations

### Credential Exposure

- Credentials are displayed on console during creation
- Ensure console output is not logged or captured
- Credentials are immediately stored as encrypted GitHub secret

### Secret Rotation

- Client secret has default 1-year expiration
- Plan for credential rotation before expiration
- Use `deleteDeploymentCredentials.ps1` to clean up old credentials

### Principle of Least Privilege

The service principal has elevated permissions:

- **User Access Administrator**: Can grant any role
- **Managed Identity Contributor**: Can create identities

Consider if these are necessary for your workflow.

### GitHub Secret Security

- Secret is encrypted at rest in GitHub
- Only accessible to repository workflows
- Secret value cannot be read after creation
- Audit logs track secret usage

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Failed to retrieve subscription ID" | Not logged into Azure | Run `az login` |
| "Failed to create service principal" | Insufficient Azure AD permissions | Verify Application Administrator role |
| "Failed to assign role" | Insufficient Azure permissions | Verify Owner/UAA role |
| "GitHub secret script not found" | Directory structure issue | Verify script paths |

### Verify Service Principal

```powershell
# List service principal details
az ad sp list --display-name "Contoso DevBox CI/CD" --query "[].{appId:appId, displayName:displayName}" --output table
```

### Verify GitHub Secret

```powershell
# List repository secrets
gh secret list
```

## Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `deleteDeploymentCredentials.ps1` | Remove service principal | [delete-deployment-credentials.md](delete-deployment-credentials.md) |
| `createUsersAndAssignRole.ps1` | Assign user roles | [create-users-and-assign-role.md](create-users-and-assign-role.md) |
| `createGitHubSecretAzureCredentials.ps1` | Create GitHub secret | [../github/create-github-secret-azure-credentials.md](../github/create-github-secret-azure-credentials.md) |
| `cleanSetUp.ps1` | Full environment cleanup | [../clean-setup.md](../clean-setup.md) |
