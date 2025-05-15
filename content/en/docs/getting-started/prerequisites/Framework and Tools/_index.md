---
title: Framework and Tools requirements
description: >
  **Dev Box Landing Zone Accelerator –** Framework and Tools for development and deployment. 
tags:
  - azure
  - azure-cli
  - azure-developer-cli
  - azd
  - bicep
  - visual-studio-code
  - vs-code
  - cli-tools
  - developer-tools
  - azure-development
  - infrastructure-as-code
  - iac
  - windows
  - ubuntu
  - linux
  - cross-platform
  - dev-environment
  - automation
  - winget
  - apt
  - bash
  - powershell
  - installation-guide
  - toolchain
  - dev-setup
  - microsoft
  - azure-docs
  - open-source
weight: 6
---

# Overview

This document provides a reference table for key Azure development tools, along with direct links to their official documentation and installation guides.

| Title                        | Description                                           | Official Documentation Link                                             | How to Install Link                      |
|-----------------------------|-------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------|
| Microsoft Azure CLI         | Command-line tools for managing Azure resources       | [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/) | [How to install](#microsoft-azure-cli)         |
| Microsoft Azure Developer CLI | Command-line tools for developers working with Azure | [Azure Dev CLI Documentation](https://docs.microsoft.com/en-us/azure/dev-cli/) | [How to install](#microsoft-azure-developer-cli-azd) |
| Bicep                       | Domain-specific language for deploying Azure resources| [Bicep Documentation](https://docs.microsoft.com/en-us/azure/bicep/)   | [How to install](#bicep-cli)                   |
| VS Code                     | Source-code editor developed by Microsoft             | [VS Code Docs](https://code.visualstudio.com/docs)                      | [How to install](#visual-studio-code-vs-code)  |

---

## How to Install

### Windows (via PowerShell and winget)
```powershell
# Azure CLI
winget install --id Microsoft.AzureCLI

# Azure Developer CLI
winget install --id Microsoft.AzureDeveloperCLI

# Bicep CLI (requires Azure CLI)
az bicep install

# Visual Studio Code
winget install --id Microsoft.VisualStudioCode
```

### Ubuntu (via Bash)
```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure Developer CLI
curl -fsSL https://aka.ms/install-azd.sh | bash

# Bicep CLI (requires Azure CLI)
az bicep install

# Visual Studio Code
sudo apt update
sudo apt install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y
```