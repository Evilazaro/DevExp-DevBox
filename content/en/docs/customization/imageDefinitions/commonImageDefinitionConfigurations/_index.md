---
title: Common DSC Configuration for .NET Engineers Sample
description: >
    Dev Box Image Definitions
weight: 9
---

## Overview

This document provides a detailed explanation of the [**common-config.dsc.yaml**](https://github.com/Evilazaro/DevExp-DevBox/blob/main/.configuration/devcenter/workloads/common-config.dsc.yaml) PowerShell Desired State Configuration (DSC) file. This configuration sets up a standardized development environment for Microsoft Dev Box, optimized for Azure development scenarios. Each section below includes the YAML configuration, a plain-language explanation, and links to official documentation for further reference.

---

## Default Configuration

```yaml

# yaml-language-server: $schema=https://aka.ms/configuration-dsc-schema/0.2
#
# Microsoft Dev Box landing zone accelerator Common Configuration
# =================================
#
# Purpose:
#   This DSC configuration sets up a standard development environment with:
#   - Development storage using Dev Drive
#   - Source control tools (Git, GitHub CLI)
#   - Development runtimes (.NET 9 SDK and Runtime)
#   - Development tools (VS Code, Node.js)
#
# Prerequisites:
#   - Windows 10/11 with admin privileges
#   - Internet connectivity for package downloads
#
# Maintainers: DevExp Team

properties:
  configurationVersion: "0.2.0"
  resources:
    
    - resource: Disk
      id: DevDrive1
      directives:
        module: StorageDsc
        allowPrerelease: true
        description: Configure Dev Drive with ReFS format
      settings:
        DiskId: "0"
        DiskIdType: "Number"
        DriveLetter: "Z"
        FSLabel: "Dev Drive 1"
        DevDrive: true
        AllowDestructive: true
        FSFormat: "ReFS"
        Size: "50Gb"
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Git.Git
      directives:
        allowPrerelease: true
        description: Install Git version control system
      settings:
        id: Git.Git
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: GitHub.cli
      directives:
        allowPrerelease: true
        description: Install GitHub command-line interface
      settings:
        id: GitHub.cli
      dependsOn:
        - Git.Git
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.DotNet.SDK.9
      directives:
        allowPrerelease: true
        description: Install .NET 9 SDK for application development
      settings:
        id: Microsoft.DotNet.SDK.9
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.DotNet.Runtime.9
      directives:
        allowPrerelease: true
        description: Install .NET 9 Runtime
      settings:
        id: Microsoft.DotNet.Runtime.9
      dependsOn:
        - Microsoft.DotNet.SDK.9
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: OpenJS.NodeJS
      directives:
        allowPrerelease: true
        description: Install Node.js JavaScript runtime
      settings:
        id: OpenJS.NodeJS
    
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.VisualStudioCode
      directives:
        allowPrerelease: true
        description: Install Visual Studio Code editor
      settings:
        id: Microsoft.VisualStudioCode
```

## Table of Contents

- [Overview](#overview)
- [Storage Configuration](#storage-configuration)
  - [Dev Drive](#dev-drive)
- [Source Control Tools](#source-control-tools)
  - [Git](#git)
  - [GitHub CLI](#github-cli)
- [Development Runtimes](#development-runtimes)
  - [.NET SDK 9](#net-sdk-9)
  - [.NET Runtime 9](#net-runtime-9)
  - [Node.js](#nodejs)
- [Development Tools](#development-tools)
  - [Visual Studio Code](#visual-studio-code)
- [Best Practices](#best-practices)
- [Additional Resources](#additional-resources)

---

## Overview

This DSC configuration automates the setup of a modern development environment, including storage, source control, runtimes, and tools, with a focus on Azure development best practices.

---

## Storage Configuration

### Dev Drive

```yaml
- resource: Disk
  id: DevDrive1
  directives:
    module: StorageDsc
    allowPrerelease: true
    description: Configure Dev Drive with ReFS format
  settings:
    DiskId: "0"
    DiskIdType: "Number"
    DriveLetter: "Z"
    FSLabel: "Dev Drive 1"
    DevDrive: true
    AllowDestructive: true
    FSFormat: "ReFS"
    Size: "50Gb"
```

**Explanation:**  
Configures a dedicated Dev Drive using the ReFS file system, optimized for development workloads. This improves performance for Git operations, build processes, and container workloads—especially beneficial for large Azure repositories and microservice architectures.

- **Key Features:**  
  - Uses ReFS for integrity and performance.
  - Enables Dev Drive optimizations.
  - Standardizes on drive letter `Z` for development.
  - Destroys existing data on the disk (use with caution).

**References:**  
- [Windows Dev Drive Overview](https://learn.microsoft.com/en-us/windows/dev-drive/)  
- [Optimize Dev Drive for Azure Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/how-to-optimize-dev-drive)

---

## Source Control Tools

### Git

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Git.Git
  directives:
    allowPrerelease: true
    description: Install Git version control system
  settings:
    id: Git.Git
```

**Explanation:**  
Installs Git, the essential version control system for source code management. Git is required for working with Azure DevOps, GitHub, and for managing infrastructure as code (e.g., Bicep templates).

**References:**  
- [Git Documentation](https://git-scm.com/doc)  
- [WinGet Git Package](https://winget.run/pkg/Git.Git)

---

### GitHub CLI

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: GitHub.cli
  directives:
    allowPrerelease: true
    description: Install GitHub command-line interface
  settings:
    id: GitHub.cli
  dependsOn:
    - Git.Git
```

**Explanation:**  
Installs the GitHub CLI, enabling automation and management of GitHub repositories, issues, pull requests, and GitHub Actions—all from the terminal. Essential for integrating GitHub workflows with Azure deployments.

**References:**  
- [GitHub CLI Documentation](https://cli.github.com/manual/)  
- [WinGet GitHub CLI Package](https://winget.run/pkg/GitHub.cli)

---

## Development Runtimes

### .NET SDK 9

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.DotNet.SDK.9
  directives:
    allowPrerelease: true
    description: Install .NET 9 SDK for application development
  settings:
    id: Microsoft.DotNet.SDK.9
```

**Explanation:**  
Installs the .NET 9 SDK, required for building, testing, and deploying .NET applications targeting Azure services. Includes tools for Azure Functions, Web Apps, and containerized workloads.

**References:**  
- [.NET SDK Documentation](https://learn.microsoft.com/en-us/dotnet/core/tools/)  
- [WinGet .NET SDK Package](https://winget.run/pkg/Microsoft.DotNet.SDK.9)

---

### .NET Runtime 9

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.DotNet.Runtime.9
  directives:
    allowPrerelease: true
    description: Install .NET 9 Runtime
  settings:
    id: Microsoft.DotNet.Runtime.9
  dependsOn:
    - Microsoft.DotNet.SDK.9
```

**Explanation:**  
Installs the .NET 9 Runtime, enabling execution of .NET applications and Azure tools that depend on .NET. Explicit installation ensures compatibility with tools and emulators.

**References:**  
- [.NET Runtime Documentation](https://learn.microsoft.com/en-us/dotnet/core/runtime/)  
- [WinGet .NET Runtime Package](https://winget.run/pkg/Microsoft.DotNet.Runtime.9)

---

### Node.js

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: OpenJS.NodeJS
  directives:
    allowPrerelease: true
    description: Install Node.js JavaScript runtime
  settings:
    id: OpenJS.NodeJS
```

**Explanation:**  
Installs Node.js, a JavaScript runtime essential for web development and Azure scenarios such as Static Web Apps, Azure Functions, and DevOps pipelines.

**References:**  
- [Node.js Documentation](https://nodejs.org/en/docs/)  
- [WinGet Node.js Package](https://winget.run/pkg/OpenJS.NodeJS)

---

## Development Tools

### Visual Studio Code

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.VisualStudioCode
  directives:
    allowPrerelease: true
    description: Install Visual Studio Code editor
  settings:
    id: Microsoft.VisualStudioCode
```

**Explanation:**  
Installs Visual Studio Code, the recommended editor for Azure development. VS Code offers rich integration with Azure services, extensions for resource management, and tools for authoring and deploying to Azure.

**References:**  
- [Visual Studio Code Documentation](https://code.visualstudio.com/docs)  
- [WinGet VS Code Package](https://winget.run/pkg/Microsoft.VisualStudioCode)

---

## Best Practices

- **Use WinGet for Secure Installations:** Ensures packages are sourced from trusted repositories.
- **Explicit Dependencies:** Use `dependsOn` to guarantee correct installation order.
- **Dev Drive Optimization:** Store source code and build artifacts on Dev Drive for maximum performance.
- **Separation of Concerns:** Additional Azure-specific extensions and tools should be managed in separate configurations for modularity.

---

## Additional Resources

- [PowerShell DSC Documentation](https://learn.microsoft.com/en-us/powershell/dsc/overview)
- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)

---

*Maintained by the DevExp Team. For questions or contributions, please refer to the official documentation links above.*