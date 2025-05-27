---
title: Back-End Engineering Development
description: >
    Configuration Sample for .NET Engineers
weight: 8
---

## Overview

This YAML file defines the **base image configuration** for backend engineers working on the [Identity Provider Project Demo](https://github.com/evilazaro/identityprovider) at Contoso, using the **Microsoft Dev Box Accelerator**. It specifies the tools, environment setup, and project-specific tasks required to provision a consistent, ready-to-code development environment in Azure Dev Box. The configuration ensures that all backend engineers have a standardized, secure, and productive workspace aligned with Contoso’s engineering requirements.

---

{{% pageinfo %}}  
> - **Common Engineering DSC Configuration File**: [Learn more](commontConfig.md) 
> - **Back-End Engineering DSC Configuration File**: [Learn more](backEndDscFile.md).  
{{% /pageinfo %}}

---

## Configurations

Below is a breakdown of each section and key in the YAML file, with explanations and YAML snippets.

### Metadata

```yaml
$schema: "1.0"
name: identityProvider-backend-engineer
description: "This image definition sets up a development environment for backend engineers."
image: microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2
```
- **$schema**: Version of the image definition schema.
- **name**: Unique identifier for this image definition.
- **description**: Human-readable summary of the image’s purpose.
- **image**: The Microsoft-provided base image (includes Visual Studio 2022, Windows 11, and M365).

---

### Tasks

Defines the **mandatory steps** to set up the environment.

#### Core Environment Setup

```yaml
- name: ~/powershell
  description: "Configure PowerShell environment and install DSC resources"
  parameters:
    command: |
      Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope Process
      Install-PackageProvider -Name NuGet -Force -Scope AllUsers
      Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
      Install-Module -Name PSDSCResources -Force -AllowClobber -Scope AllUsers
```
- Installs PowerShell DSC resources for consistent environment configuration.

#### Common Development Tools

```yaml
- name: ~/winget
  description: "Import common engineering tools and configurations"
  parameters:
    downloadUrl: "https://raw.githubusercontent.com/Evilazaro/DevExp-DevBox/refs/heads/main/.configuration/devcenter/workloads/common-config.dsc.yaml"
    configurationFile: "c:\\winget\\common-config.dsc.yaml"
```
- Imports a shared configuration file for common tools.

```yaml
- name: ~/winget
  description: "Install GitHub Desktop for visual Git management"
  parameters:
    package: "GitHub.GitHubDesktop"
```
- Installs GitHub Desktop for source control.

```yaml
- name: ~/git-clone
  description: "Clone the Identity Provider repository to the local workspace"
  parameters:
    repositoryUrl: https://github.com/Evilazaro/IdentityProvider.git
    directory: Z:\Workspaces
```
- Clones the project repository into the workspace.

#### Backend Development Environment

```yaml
- name: ~/winget
  description: "Install specialized backend development tools"
  parameters:
    downloadUrl: "https://raw.githubusercontent.com/Evilazaro/DevExp-DevBox/refs/heads/main/.configuration/devcenter/workloads/common-backend-config.dsc.yaml"
    configurationFile: "c:\\winget\\common-backend-config.dsc.yaml"
```
- Installs backend-specific tools (e.g., database, API, server utilities).

---

### User Tasks

Defines **optional tasks** that individual engineers can run as needed.

```yaml
userTasks:
  - name: ~/winget
    description: "Install additional backend-specific tools"
    parameters:
      downloadUrl: "https://raw.githubusercontent.com/Evilazaro/DevExp-DevBox/refs/heads/main/.configuration/devcenter/workloads/common-backend-usertasks-config.dsc.yaml"
      configurationFile: "c:\\winget\\common-backend-usertasks-config.dsc.yaml"
```
- Optional backend tools for specialized scenarios.

---

### Environment Maintenance

```yaml
- name: ~/powershell
  description: "Update Winget Packages"
  parameters:
    command: |
      # Updates all packages, .NET workloads, restores NuGet, builds, and tests the solution
```
- Keeps all installed tools and packages up to date.
- Ensures the .NET solution is restored, built, and tested.

---

### Project Setup

```yaml
- name: ~/powershell
  description: "Build Identity Provider Solution"
  parameters:
    command: |
      # Restores, builds, and tests the solution to validate the environment
```
- Validates that the environment is ready for development by building and testing the main project.

---

## Examples and Use Cases

### Example: Provisioning a Dev Box for a New Engineer

1. **Dev Box Service** reads this YAML file.
2. **Base image** is provisioned with Visual Studio, Windows 11, and M365.
3. **Tasks** run automatically:
   - PowerShell DSC resources are installed.
   - Common and backend tools are set up via WinGet.
   - GitHub Desktop is installed.
   - The Identity Provider repository is cloned to `Z:\Workspaces`.
   - All packages are updated, and the solution is built and tested.
4. **User Tasks**: The engineer can optionally install additional backend tools as needed.

### Use Case: Ensuring Consistency Across Teams

- All backend engineers receive the same environment, reducing "works on my machine" issues.
- Updates and new tools can be rolled out by updating the YAML or referenced configuration files.

---

## Best Practices

- **Use Microsoft Base Images**: Ensures compatibility and support.
- **Leverage DSC and WinGet**: For idempotent, repeatable environment setup.
- **Centralize Tool Configurations**: Reference shared configuration files for consistency.
- **Separate Mandatory and Optional Tasks**: Keep the base image lean and allow customization.
- **Automate Updates and Validation**: Regularly update packages and validate the build/test pipeline as part of environment setup.
- **Use Trusted Sources**: Only install packages from trusted repositories and URLs.
- **Document Each Section**: Use comments in the YAML to explain the purpose of each task.
- **Follow Azure Dev Box Best Practices**: Such as using the Z: drive for workspaces and scoped execution policies for security.

---

**References:**
- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Azure Dev Box Best Practices](https://learn.microsoft.com/en-us/azure/dev-box/concepts-best-practices)
- [WinGet Documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)