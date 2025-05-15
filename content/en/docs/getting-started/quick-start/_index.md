---
title: Quick Start
description: Deploy the Dev Box landing zone accelerator for demo and test  
weight: 5
---

## Instalation

### Fork the GitHub Repositories

Windows/Linux

Fork the following GitHub Repositories

Dev Box landing zone accelerator repository
```powershell
gh repo fork Evilazaro/DevExp-DevBox --clone --remote
```
Identity Provider solution demo repository
```powershell
gh repo fork Evilazaro/IdentityProvider --clone --remote
```
eShop solution demo repository
```powershell
gh repo fork Evilazaro/eShop --clone --remote
```

---

### Initialize local environment

Windows

```powershell
$location = "eastus2"
$envName = "prod"
$pat = gh auth token
azd env new $envName --no-prompt
Set-Content -Path ".\.azure\$EnvName\.env" -Value "AZURE_ENV_NAME='$envName'"
Add-Content -Path ".\.azure\$EnvName\.env" -Value "KEY_VAULT_SECRET='$pat'"
Add-Content -Path ".\.azure\$EnvName\.env" -Value "AZURE_LOCATION='$location'"
azd config show
```

Linux

```bash
location="eastus2"
envName="prod"
pat=$(gh auth token)
azd env new "$envName" --no-prompt
echo "AZURE_ENV_NAME='$envName'" > .azure/"$envName"/.env
echo "KEY_VAULT_SECRET='$pat'" >> .azure/"$envName"/.env
echo "AZURE_LOCATION='$location'" >> .azure/"$envName"/.env
azd config show
```
---

### Deploy Accelerator

Windows/Linux

```powershell
azd provision -e $envName
```