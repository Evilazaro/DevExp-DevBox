---
title: "setUp.ps1 Script"
description: "Azure Dev Box environment setup script with GitHub/Azure DevOps integration"
author: "DevExp Team"
date: 2026-01-23
version: "1.0.0"
tags:
  - scripts
  - setup
  - azure
  - azd
  - authentication
---

# ⚙️ setUp.ps1

> **Azure Dev Box environment setup with GitHub/Azure DevOps integration**

> [!NOTE]
> **Target Audience:** DevOps Engineers, Platform Engineers  
> **Reading Time:** ~15 minutes

<details>
<summary>📍 Navigation</summary>

| Previous | Index | Next |
|:---------|:-----:|-----:|
| [← Scripts Overview](README.md) | [Scripts Index](README.md) | [cleanSetUp.ps1 →](clean-setup.md) |

</details>

---

## 📑 Table of Contents

- [🎯 Overview](#overview)
- [📊 Flow Visualization](#flow-visualization)
- [🔒 Authentication Flow](#authentication-flow)
- [📝 Parameters](#parameters)
- [⚙️ Prerequisites](#prerequisites)
- [🔧 Functions Reference](#functions-reference)
- [📝 Usage Examples](#usage-examples)
- [⚠️ Error Handling](#error-handling)
- [🔐 Security Considerations](#security-considerations)
- [🔧 Troubleshooting](#troubleshooting)
- [🔗 Related Scripts](#related-scripts)

---

## 🎯 Overview

This script automates the setup of an Azure Developer CLI (azd) environment for Dev Box, handles source control authentication (GitHub or Azure DevOps), and prepares the environment for Azure resource provisioning. Use this script when initializing a new DevExp-DevBox environment.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📊 Flow Visualization

```mermaid
flowchart TD
    subgraph Entry["Script Entry"]
        A([setUp.ps1 Start]):::entry
        B[/"Parse Parameters"/]:::input
        C{Help requested?}:::decision
    end
    
    subgraph Validation["Argument Validation"]
        D["Test-Arguments"]:::validation
        D1{EnvName provided?}:::decision
        D2{SourceControl provided?}:::decision
        D3["Select-SourceControlPlatform"]:::core
        D4["Test-SourceControlValidation"]:::validation
    end
    
    subgraph Tools["Tool Verification"]
        E["Test-CommandAvailability"]:::validation
        E1[(az)]:::external
        E2[(azd)]:::external
        E3[(gh)]:::external
    end
    
    subgraph Auth["Authentication"]
        F["Test-AzureAuthentication"]:::validation
        F1{Platform?}:::decision
        F2["Test-GitHubAuthentication"]:::validation
        F3["Test-AdoAuthentication"]:::validation
    end
    
    subgraph Token["Token Retrieval"]
        G{Platform?}:::decision
        G1["Get-SecureGitHubToken"]:::core
        G2["Get-SecureAdoGitToken"]:::core
    end
    
    subgraph Init["Environment Init"]
        H["Initialize-AzdEnvironment"]:::core
        H1["Create .azure directory"]:::core
        H2["Write .env file"]:::core
        H3["Configure azd"]:::core
    end
    
    subgraph Exit["Script Exit"]
        I[\Success\]:::output
        J{{Error Handler}}:::error
    end
    
    A --> B --> C
    C -->|Yes| HELP[Show-Help] --> EXIT([Exit 0]):::entry
    C -->|No| D
    D --> D1
    D1 -->|No| J
    D1 -->|Yes| D2
    D2 -->|No| D3
    D2 -->|Yes| D4
    D3 --> D4
    D4 --> E
    E --> E1 & E2
    E --> F
    F --> F1
    F1 -->|github| E3 --> F2
    F1 -->|adogit| F3
    F2 --> G
    F3 --> G
    G -->|github| G1
    G -->|adogit| G2
    G1 --> H
    G2 --> H
    H --> H1 --> H2 --> H3 --> I

    classDef entry fill:#2196F3,stroke:#1565C0,color:#fff
    classDef input fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef core fill:#FF9800,stroke:#EF6C00,color:#fff
    classDef validation fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef external fill:#4CAF50,stroke:#2E7D32,color:#fff
    classDef decision fill:#FFC107,stroke:#FFA000,color:#000
    classDef output fill:#2196F3,stroke:#1565C0,color:#fff
    classDef error fill:#F44336,stroke:#C62828,color:#fff
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔒 Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant Script as setUp.ps1
    participant AzCLI as Azure CLI
    participant GhCLI as GitHub CLI
    participant AdoCLI as Azure DevOps CLI
    participant AzD as Azure Developer CLI

    User->>Script: Execute with parameters
    Script->>AzCLI: az account show
    AzCLI-->>Script: Subscription info
    
    alt GitHub Platform
        Script->>GhCLI: gh auth status
        GhCLI-->>Script: Auth status
        Script->>GhCLI: gh auth token
        GhCLI-->>Script: Personal Access Token
    else Azure DevOps Platform
        Script->>AdoCLI: az devops configure --list
        AdoCLI-->>Script: Config status
        Script->>User: Prompt for PAT
        User-->>Script: Enter PAT securely
    end
    
    Script->>Script: Store token in memory
    Script->>AzD: Create environment directory
    Script->>AzD: Write .env configuration
    Script-->>User: Setup complete
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Parameters

| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `-EnvName` | `string` | Yes* | - | - | Name of the Azure environment to create |
| `-SourceControl` | `string` | No | - | `ValidateSet("github", "adogit", "")` | Source control platform |
| `-Help` | `switch` | No | `$false` | - | Show help message |

*Required unless `-Help` is specified.

---

[⬆️ Back to Top](#-table-of-contents)

---

## ⚙️ Prerequisites

### Required Tools

| Tool | Purpose | Required For | Installation |
|------|---------|--------------|--------------|
| Azure CLI (`az`) | Azure authentication | All setups | [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| Azure Developer CLI (`azd`) | Environment management | All setups | [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) |
| GitHub CLI (`gh`) | GitHub authentication | GitHub source control | [Install GitHub CLI](https://cli.github.com/) |

### Required Permissions

- **Azure**: Valid subscription with Enabled state
- **GitHub**: Authenticated with `repo` scope (for GitHub platform)
- **Azure DevOps**: Valid PAT with appropriate scopes (for ADO platform)

### Environment Variables

| Variable | Purpose | Set By |
|----------|---------|--------|
| `KEY_VAULT_SECRET` | Stores PAT for azd | Script (in `.env` file) |
| `SOURCE_CONTROL_PLATFORM` | Tracks selected platform | Script (in `.env` file) |
| `AZURE_DEVOPS_EXT_PAT` | Azure DevOps authentication | Script (for ADO platform) |

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Functions Reference

### Function: `Write-LogMessage`

**Purpose:** Outputs formatted log messages with timestamps and colored output based on severity.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `Message` | `string` | Yes | The message text to log |
| `Level` | `string` | No | Severity level: Info, Warning, Error, Success |

**Output Format:**

```
✅ [2025-01-23 10:30:45] Operation completed successfully
❌ [2025-01-23 10:30:46] An error occurred
```

---

### Function: `Test-CommandAvailability`

**Purpose:** Verifies that a required command-line tool is available in PATH.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `Command` | `string` | Yes | Name of the command to check |

**Returns:** `[bool]` - `$true` if command exists, `$false` otherwise

---

### Function: `Test-AzureAuthentication`

**Purpose:** Validates Azure CLI authentication and subscription status.

**Returns:** `[bool]` - `$true` if authenticated with enabled subscription

**Checks:**

- User is logged into Azure CLI
- Current subscription is in "Enabled" state
- Outputs subscription details for verification

---

### Function: `Test-GitHubAuthentication`

**Purpose:** Validates GitHub CLI authentication status.

**Returns:** `[bool]` - `$true` if authenticated

**Uses:** `gh auth status`

---

### Function: `Test-AdoAuthentication`

**Purpose:** Validates Azure DevOps CLI extension is configured.

**Returns:** `[bool]` - `$true` if configured

**Uses:** `az devops configure --list`

---

### Function: `Get-SecureGitHubToken`

**Purpose:** Retrieves GitHub Personal Access Token securely.

**Returns:** `[bool]` - `$true` if token retrieved successfully

**Token Sources (in order):**

1. `KEY_VAULT_SECRET` environment variable
2. `gh auth token` command

**Security:** Token stored in `$Script:GitHubToken` (script scope)

---

### Function: `Get-SecureAdoGitToken`

**Purpose:** Retrieves Azure DevOps PAT securely.

**Returns:** `[bool]` - `$true` if token retrieved successfully

**Token Sources (in order):**

1. `KEY_VAULT_SECRET` environment variable
2. Secure prompt (`Read-Host -AsSecureString`)

**Security:**

- Token stored in `$Script:AdoToken` (script scope)
- Exported to `AZURE_DEVOPS_EXT_PAT` for Azure CLI

---

### Function: `Initialize-AzdEnvironment`

**Purpose:** Sets up the Azure Developer CLI environment with source control tokens.

**Returns:** `[bool]` - `$true` if initialization succeeded

**Creates:**

- Directory: `.azure\{EnvName}\`
- File: `.azure\{EnvName}\.env` with:

  ```
  KEY_VAULT_SECRET='<token>'
  SOURCE_CONTROL_PLATFORM='<platform>'
  ```

---

### Function: `Start-AzureProvisioning`

**Purpose:** Initiates Azure resource provisioning using `azd provision`.

**Returns:** `[bool]` - `$true` if provisioning succeeded

**Command:** `azd provision -e {EnvName}`

---

### Function: `Select-SourceControlPlatform`

**Purpose:** Interactive prompt for source control platform selection.

**Behavior:**

1. Displays options (Azure DevOps Git, GitHub)
2. Validates selection (1 or 2)
3. Sets `$Script:SourceControl` variable

---

### Function: `Invoke-Main`

**Purpose:** Main orchestration function that coordinates the entire setup process.

**Sequence:**

1. Process and validate arguments
2. Display configuration summary
3. Verify required tools
4. Verify Azure authentication
5. Verify source control authentication
6. Initialize azd environment
7. Display success message

---

[⬆️ Back to Top](#-table-of-contents)

---

## 📝 Usage Examples

### GitHub Setup

```powershell
.\setUp.ps1 -EnvName "prod" -SourceControl "github"
```

### Azure DevOps Setup

```powershell
.\setUp.ps1 -EnvName "dev" -SourceControl "adogit"
```

### Interactive Platform Selection

```powershell
.\setUp.ps1 -EnvName "demo"
# Script prompts for platform selection
```

### Show Help

```powershell
.\setUp.ps1 -Help
```

<details>
<summary>Expected Help Output</summary>

```
setUp.ps1 - Sets up Azure Dev Box environment with source control integration

USAGE:
    .\setUp.ps1 -EnvName ENV_NAME -SourceControl PLATFORM

PARAMETERS:
    -EnvName ENV_NAME           Name of the Azure environment to create
    -SourceControl PLATFORM     Source control platform (github or adogit)
    -Help                       Show this help message

EXAMPLES:
    .\setUp.ps1 -EnvName "prod" -SourceControl "github"
    .\setUp.ps1 -EnvName "dev" -SourceControl "adogit"

REQUIREMENTS:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
```

</details>

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
| `0` | Setup completed successfully (or help displayed) |
| `1` | Setup failed due to error |
| `130` | Script interrupted by user (Ctrl+C) |

### Trap Handler

```powershell
trap {
    Write-LogMessage "Script interrupted by user" "Warning"
    exit 130
}
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔐 Security Considerations

### Token Handling

- Tokens are stored in script-scoped variables (`$Script:GitHubToken`, `$Script:AdoToken`)
- PAT values are masked in logs (first 4 + last 2 characters visible)
- Azure DevOps PAT can be entered via secure prompt (no echo)
- Tokens written to `.env` file (ensure proper .gitignore)

### Credential Storage

The script stores tokens in `.azure\{EnvName}\.env`:

```
KEY_VAULT_SECRET='ghp_xxxx****xx'
SOURCE_CONTROL_PLATFORM='github'
```

> ⚠️ **Warning:** Ensure `.azure/` is in `.gitignore` to prevent token exposure.

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔧 Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Required command 'az' was not found" | Azure CLI not installed | Install Azure CLI |
| "Not logged into Azure" | Azure CLI not authenticated | Run `az login` |
| "Subscription not in 'Enabled' state" | Subscription suspended | Check Azure portal billing |
| "Not logged into GitHub" | GitHub CLI not authenticated | Run `gh auth login` |
| "Failed to retrieve GitHub token" | Token expired or revoked | Re-authenticate with `gh auth login` |

### Verbose Output

```powershell
# Set preference before running
$VerbosePreference = 'Continue'
.\setUp.ps1 -EnvName "debug-env" -SourceControl "github"
```

---

[⬆️ Back to Top](#-table-of-contents)

---

## 🔗 Related Scripts

| Script | Purpose | Link |
|--------|---------|------|
| `cleanSetUp.ps1` | Complete environment cleanup (opposite of setup) | [clean-setup.md](clean-setup.md) |
| `generateDeploymentCredentials.ps1` | Create service principal for CI/CD | [azure/generate-deployment-credentials.md](azure/generate-deployment-credentials.md) |
| `createUsersAndAssignRole.ps1` | Assign DevCenter roles | [azure/create-users-and-assign-role.md](azure/create-users-and-assign-role.md) |

---

<div align="center">

[← Scripts Overview](README.md) | [⬆️ Back to Top](#-table-of-contents) | [cleanSetUp.ps1 →](clean-setup.md)

*DevExp-DevBox • setUp.ps1 Documentation*

</div>
