---
title: Pre Requisites Installation Scripts
tags: 
 - devbox
 - prereq
description: Dev Box Pre Requisites Installation Scripts
---

# Pre-requisites Installation Scripts

This document provides two scripts for installing all the pre-requisites for implementing and configuring Microsoft Dev Box and Dev Center. The scripts are provided for both Windows (PowerShell) and Linux (Bash).

## PowerShell Script

The PowerShell script installs Azure CLI, Azure Developer CLI, Bicep CLI, Windows Subsystem for Linux (WSL), PowerShell, and VS Code with their respective extensions.

### Script

```powershell
# PowerShell script to install Azure CLI, Azure Developer CLI, Bicep CLI, WSL, PowerShell, and VS Code with extensions

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$command
    )
    $exists = Get-Command $command -ErrorAction SilentlyContinue
    return $exists -ne $null
}

# Function to install Azure CLI
function Install-AzureCLI {
    Write-Output "Installing Azure CLI..."
    if (Command-Exists "az") {
        Write-Output "Azure CLI is already installed."
    } else {
        winget install Microsoft.AzureCLI -e
        if (Command-Exists "az") {
            Write-Output "Azure CLI installed successfully."
        } else {
            Write-Output "Failed to install Azure CLI."
        }
    }
}

# Function to install Azure Developer CLI
function Install-AzureDeveloperCLI {
    Write-Output "Installing Azure Developer CLI..."
    if (Command-Exists "azd") {
        Write-Output "Azure Developer CLI is already installed."
    } else {
        winget install Microsoft.Azd -e
        if (Command-Exists "azd") {
            Write-Output "Azure Developer CLI installed successfully."
        } else {
            Write-Output "Failed to install Azure Developer CLI."
        }
    }
}

# Function to install Bicep CLI
function Install-BicepCLI {
    Write-Output "Installing Bicep CLI..."
    if (Command-Exists "az bicep") {
        Write-Output "Bicep CLI is already installed."
    } else {
        az bicep install
        if (Command-Exists "az bicep") {
            Write-Output "Bicep CLI installed successfully."
        } else {
            Write-Output "Failed to install Bicep CLI."
        }
    }
}

# Function to install WSL
function Install-WSL {
    Write-Output "Installing WSL..."
    if (Command-Exists "wsl") {
        Write-Output "WSL is already installed."
    } else {
        wsl --install
        if (Command-Exists "wsl") {
            Write-Output "WSL installed successfully."
        } else {
            Write-Output "Failed to install WSL."
        }
    }
}

# Function to install PowerShell
function Install-PowerShell {
    Write-Output "Installing PowerShell..."
    if (Command-Exists "pwsh") {
        Write-Output "PowerShell is already installed."
    } else {
        winget install Microsoft.Powershell -e
        if (Command-Exists "pwsh") {
            Write-Output "PowerShell installed successfully."
        } else {
            Write-Output "Failed to install PowerShell."
        }
    }
}

# Function to install VS Code
function Install-VSCode {
    Write-Output "Installing VS Code..."
    if (Command-Exists "code") {
        Write-Output "VS Code is already installed."
    } else {
        winget install Microsoft.VisualStudioCode -e
        if (Command-Exists "code") {
            Write-Output "VS Code installed successfully."
        } else {
            Write-Output "Failed to install VS Code."
        }
    }
}

# Function to install VS Code extensions
function Install-VSCodeExtensions {
    Write-Output "Installing VS Code extensions..."
    $extensions = @(
        "ms-vscode.azure-account",
        "ms-vscode.azurecli",
        "ms-azuretools.vscode-bicep",
        "ms-vscode.powershell"
    )
    foreach ($extension in $extensions) {
        code --install-extension $extension
    }
    Write-Output "VS Code extensions installed successfully."
}

# Main script
Install-AzureCLI
Install-AzureDeveloperCLI
Install-BicepCLI
Install-WSL
Install-PowerShell
Install-VSCode
Install-VSCodeExtensions

Write-Output "All pre-requisites installed successfully."
```
### How to Run

1. Save the script to a file named install_prerequisites.ps1.
2. Open PowerShell as Administrator.
3. Navigate to the directory where the script is saved.
4. Run the script using the following command:
```powershell
.\install_prerequisites.ps1
```

## Bash Script

The Bash script installs Azure CLI, Azure Developer CLI, Bicep CLI, PowerShell, and VS Code with their respective extensions.

## Script
```bash
#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Azure CLI
install_azure_cli() {
    echo "Installing Azure CLI..."
    if command_exists az; then
        echo "Azure CLI is already installed."
    else
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        if [ $? -eq 0 ]; then
            echo "Azure CLI installed successfully."
        else
            echo "Failed to install Azure CLI."
            exit 1
        fi
    fi
}

# Function to install Azure Developer CLI
install_azure_dev_cli() {
    echo "Installing Azure Developer CLI..."
    if command_exists azd; then
        echo "Azure Developer CLI is already installed."
    else
        curl -fsSL https://aka.ms/install-azd.sh | bash
        if [ $? -eq 0 ]; then
            echo "Azure Developer CLI installed successfully."
        else
            echo "Failed to install Azure Developer CLI."
            exit 1
        fi
    fi
}

# Function to install Bicep CLI
install_bicep_cli() {
    echo "Installing Bicep CLI..."
    if az bicep version >/dev/null 2>&1; then
        echo "Bicep CLI is already installed."
    else
        az bicep install
        if [ $? -eq 0 ]; then
            echo "Bicep CLI installed successfully."
        else
            echo "Failed to install Bicep CLI."
            exit 1
        fi
    fi
}

# Function to install PowerShell
install_powershell() {
    echo "Installing PowerShell..."
    if command_exists pwsh; then
        echo "PowerShell is already installed."
    else
        sudo apt-get update
        sudo apt-get install -y powershell
        if [ $? -eq 0 ]; then
            echo "PowerShell installed successfully."
        else
            echo "Failed to install PowerShell."
            exit 1
        fi
    fi
}

# Function to install VS Code
install_vscode() {
    echo "Installing VS Code..."
    if command_exists code; then
        echo "VS Code is already installed."
    else
        sudo apt update
        sudo apt install -y code
        if [ $? -eq 0 ]; then
            echo "VS Code installed successfully."
        else
            echo "Failed to install VS Code."
            exit 1
        fi
    fi
}

# Function to install VS Code extensions
install_vscode_extensions() {
    echo "Installing VS Code extensions..."
    code --install-extension ms-vscode.azure-account
    code --install-extension ms-vscode.azurecli
    code --install-extension ms-azuretools.vscode-bicep
    code --install-extension ms-vscode.powershell
    if [ $? -eq 0 ]; then
        echo "VS Code extensions installed successfully."
    else
        echo "Failed to install VS Code extensions."
        exit 1
    fi
}

# Main script execution
install_azure_cli
install_azure_dev_cli
install_bicep_cli
install_powershell
install_vscode
install_vscode_extensions

echo "All pre-requisites installed successfully."
```
### How to Run

1. Save the script to a file named install_prerequisites.sh.
2. Open a terminal.
3. Navigate to the directory where the script is saved.
4. Make the script executable using the following command:
```bash
chmod +x install_prerequisites.sh
```
5. Run the script using the following command:
```bash
./install_prerequisites.sh
```