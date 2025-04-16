---
title: Pre Requisites
tags: 
 - devbox
 - prereq
description: Dev Box Pre Requisites
---

# Pre-requisites for Implementing and Configuring Microsoft Dev Box and Dev Center

This document lists all the pre-requisites for implementing and configuring Microsoft Dev Box and Dev Center. It includes the step-by-step installation process for both Windows and Linux. Each item has its link to the Official Documentation for further details. You also can run the pre-requisites installation scripts described [here](pre-req-scripts.md).

## Pre-requisites

1. **Azure CLI**
   - **Windows Installation:**
     1. Download the Azure CLI installer from [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows).
     2. Run the installer and follow the instructions.
     3. Verify the installation by running `az --version` in PowerShell.
     4. **Alternative:** Install using `winget`:
        ```powershell
        winget install Microsoft.AzureCLI
        ```
   - **Linux Installation:**
     1. Open your terminal.
     2. Run the following command to install Azure CLI:
        ```bash
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        ```
     3. Verify the installation by running `az --version`.
   - [Official Documentation](https://learn.microsoft.com/en-us/cli/azure/)

2. **Azure Developer CLI**
   - **Windows Installation:**
     1. Download the Azure Developer CLI installer from [here](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd).
     2. Run the installer and follow the instructions.
     3. Verify the installation by running `azd version` in PowerShell.
     4. **Alternative:** Install using `winget`:
        ```powershell
        winget install Microsoft.Azd
        ```
   - **Linux Installation:**
     1. Open your terminal.
     2. Run the following command to install Azure Developer CLI:
        ```bash
        curl -fsSL https://aka.ms/install-azd.sh | bash
        ```
     3. Verify the installation by running `azd version`.
   - [Official Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)

3. **Bicep CLI**
   - **Windows Installation:**
     1. Install Bicep CLI using Azure CLI:
        ```powershell
        az bicep install
        ```
     2. Verify the installation by running `az bicep version`.
     3. **Alternative:** Install using `winget`:
        ```powershell
        winget install Microsoft.Bicep
        ```
   - **Linux Installation:**
     1. Install Bicep CLI using Azure CLI:
        ```bash
        az bicep install
        ```
     2. Verify the installation by running `az bicep version`.
   - [Official Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

4. **Windows Subsystem for Linux (WSL)**
   - **Windows Installation:**
     1. Open PowerShell as Administrator.
     2. Run the following command to install WSL:
        ```powershell
        wsl --install
        ```
     3. Restart your computer if prompted.
     4. Verify the installation by running `wsl --list --online`.
   - **Linux Installation:** Not applicable.
   - [Official Documentation](https://learn.microsoft.com/en-us/windows/wsl/)

5. **PowerShell**
   - **Windows Installation:**
     1. Download the PowerShell installer from [here](https://learn.microsoft.com/en-us/powershell/).
     2. Run the installer and follow the instructions.
     3. Verify the installation by running `pwsh` in PowerShell.
     4. **Alternative:** Install using `winget`:
        ```powershell
        winget install Microsoft.Powershell
        ```
   - **Linux Installation:**
     1. Open your terminal.
     2. Run the following command to install PowerShell:
        ```bash
        sudo apt-get install -y powershell
        ```
     3. Verify the installation by running `pwsh`.
   - [Official Documentation](https://learn.microsoft.com/en-us/powershell/)

6. **VS Code**
   - **Windows Installation:**
     1. Download the VS Code installer from [here](https://code.visualstudio.com/Docs).
     2. Run the installer and follow the instructions.
     3. Verify the installation by running `code` in PowerShell.
     4. **Alternative:** Install using `winget`:
        ```powershell
        winget install Microsoft.VisualStudioCode
        ```
   - **Linux Installation:**
     1. Open your terminal.
     2. Run the following commands to install VS Code:
        ```bash
        sudo apt update
        sudo apt install -y code
        ```
     3. Verify the installation by running `code`.
   - [Official Documentation](https://code.visualstudio.com/Docs)

7. **VS Code Extensions**
   - **Windows and Linux Installation:**
     1. Open VS Code.
     2. Go to the Extensions view by clicking the Extensions icon in the Activity Bar on the side of the window or by pressing `Ctrl+Shift+X`.
     3. Search for and install the following extensions:
        - Azure Account
        - [Azure CLI Tools](https://marketplace.visualstudio.com/itemsstudio.com/items?itemName=mscom/items?itemName=ms-vscode.
   - [Official Documentation](https://code.visualstudio.com/docs/editor/re details, please refer to the Official Documentation linked above.
