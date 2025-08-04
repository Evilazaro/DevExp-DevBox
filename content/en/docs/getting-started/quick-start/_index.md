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
azd env new EnvName
```

#### Linux/macOS (Bash)

```bash
azd env new EnvName
```

### Step 3: Deploy the Accelerator

Once your environment is configured, deploy the accelerator:

#### Windows (PowerShell)

```powershell
azd provision -e EnvName
```

#### Linux/macOS (Bash)

```bash
azd provision -e EnvName
```
