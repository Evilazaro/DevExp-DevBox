---
title: Quick Start
description: Deploy the Dev Box accelerator for demo and test environments
weight: 5
---

{{% pageinfo %}}
## Before starting  
> - **Prerequisites**: Ensure you have installed all the [prerequisites.](../prerequisites/Framework%20and%20Tools/)    
{{% /pageinfo %}}

This guide will help you quickly deploy the Dev Box accelerator in your Azure environment for evaluation and testing purposes.

## Installation

### Step 1: Fork the Required GitHub Repositories

Begin by forking the necessary GitHub repositories to your account.

```powershell
# Dev Box accelerator repository
gh repo fork Evilazaro/DevExp-DevBox --clone --remote

# Identity Provider solution demo repository
gh repo fork Evilazaro/IdentityProvider --clone --remote

# eShop solution demo repository
gh repo fork Evilazaro/eShop --clone --remote
```

### Step 2: Initialize Your Local Environment

Navigate to your cloned Dev Box repository directory and initialize the environment:

#### Windows (PowerShell)

```powershell
# Change to recommended region for your location
$location = "eastus2"
$envName = "prod"

# Verify GitHub authentication
if (-not (gh auth status 2>&1 | Select-String "Logged in")) {
    Write-Host "Please login to GitHub first with 'gh auth login'" -ForegroundColor Red
    exit 1
}

# Create Azure Developer CLI environment
azd env new $envName --no-prompt

# Configure environment settings
Set-Content -Path ".\.azure\$envName\.env" -Value "AZURE_ENV_NAME='$envName'"

# Securely retrieve GitHub token
$pat = gh auth token
Add-Content -Path ".\.azure\$envName\.env" -Value "KEY_VAULT_SECRET='$pat'"
Add-Content -Path ".\.azure\$envName\.env" -Value "AZURE_LOCATION='$location'"

# Show current configuration (validates setup)
azd config show
```

#### Linux/macOS (Bash)

```bash
# Change to recommended region for your location
location="eastus2"
envName="prod"

# Verify GitHub authentication
if ! gh auth status &>/dev/null; then
    echo "Please login to GitHub first with 'gh auth login'"
    exit 1
fi

# Create Azure Developer CLI environment
azd env new "$envName" --no-prompt

# Configure environment settings
mkdir -p .azure/"$envName"
echo "AZURE_ENV_NAME='$envName'" > .azure/"$envName"/.env
pat=$(gh auth token)
echo "KEY_VAULT_SECRET='$pat'" >> .azure/"$envName"/.env
echo "AZURE_LOCATION='$location'" >> .azure/"$envName"/.env

# Show current configuration (validates setup)
azd config show
```

### Step 3: Deploy the Accelerator

Once your environment is configured, deploy the accelerator:

```bash
# Deploy the accelerator
azd provision -e $envName
```