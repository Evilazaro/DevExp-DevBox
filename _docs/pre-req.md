---
title: Pre Requisites
tags: 
 - devbox
 - prereq
description: Dev Box Pre Requisites
---

## Pre-Requisites

Before deploying the Microsoft Dev Box solution to your Azure subscription, ensure you have the following prerequisites in place:

| Prerequisite                  | Windows Installation                                                                 | Linux Installation                                                                   | macOS Installation                                                                   |
|------------------------------|----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| **Azure CLI**                | [Install Azure CLI on Windows](https://learn.microsoft.com/cli/azure/install-azure-cli-windows) | [Install Azure CLI on Linux](https://learn.microsoft.com/cli/azure/install-azure-cli-linux) | [Install Azure CLI on macOS](https://learn.microsoft.com/cli/azure/install-azure-cli-macos) |
| **Azure Developer CLI (azd)**| [Install Azure Dev CLI on Windows](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd#windows) | [Install Azure Dev CLI on Linux](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd#linux) | [Install Azure Dev CLI on macOS](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd#macos) |
| **Bicep CLI**                | [Install Bicep on Windows](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#install-bicep-on-windows) | [Install Bicep on Linux](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#install-bicep-on-linux) | [Install Bicep on macOS](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#install-bicep-on-macos) |
| **Windows Subsystem for Linux (WSL)** | [Install WSL on Windows](https://learn.microsoft.com/windows/wsl/install) | N/A                                                                                   | N/A                                                                                   |
| **PowerShell**              | [Install PowerShell on Windows](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) | [Install PowerShell on Linux](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux) | [Install PowerShell on macOS](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos) |

**RBAC Roles**: Ensure you have the following roles assigned in your Azure subscription. For more details click [here](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-role-based-access-control):

![Azure Dev Box RBAC Roles](../assets/img/devboxrbacroles.png)

**Microsoft Entra ID**: Your organization must use Microsoft Entra ID (formerly Azure Active Directory) for identity and access management. More information can be found [here](https://learn.microsoft.com/en-us/azure/dev-box/).

**Microsoft Intune**: Your organization must use Microsoft Intune for device management. More details are available [here](https://learn.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune).

**User Licenses**: Ensure each user has the necessary licenses:
   - [Windows 11 Enterprise or Windows 10 Enterprise](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service)
   - [Microsoft Intune](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service)
   - [Microsoft Entra ID P1](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-configure-dev-box-service)

   These licenses are included in subscriptions like Microsoft 365 F3, E3, E5, A3, A5, Business Premium, and Education Student Use Benefit. More details can be found [here](https://azure.microsoft.com/en-us/pricing/details/dev-box/).

**Register Resource Provider**: Register the `Microsoft.DevCenter` resource provider in your Azure subscription. Instructions can be found [here](https://learn.microsoft.com/en-us/azure/dev-box/).

By ensuring these prerequisites are met, you'll be ready to deploy the Microsoft Dev Box solution to your Azure subscription.
