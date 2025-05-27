---
title: Common Configuration 
description: >
    Sample for .NET Engineers
weight: 7
---

## Overview

This document provides comprehensive documentation for the PowerShell Desired State Configuration (DSC) YAML file: **common-config.dsc.yaml**. This configuration is designed to automate the setup of a standardized development environment for .NET engineers, with a strong focus on Azure development workflows. It provisions essential tools, runtimes, and storage optimizations to ensure a productive and performant developer experience on Windows 10/11.

---

## Table of Contents

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

---

## Storage Configuration

### Dev Drive

**YAML Configuration:**
````yaml
- resource: Disk
  id: DevDrive1
  directives:
    module: StorageDsc
    allowPrerelease: true
    description: Configure Dev Drive with ReFS format
  settings:
    DiskId: "0" # First available disk (verify this matches your environment)
    DiskIdType: "Number"
    DriveLetter: "Z" # Standard letter for development drives
    FSLabel: "Dev Drive 1"
    DevDrive: true # Enables Windows Dev Drive optimizations
    AllowDestructive: true # Warning: Will format existing disk if present
    FSFormat: "ReFS" # Required for Dev Drive functionality
    Size: "50Gb" # Recommended minimum size for development workloads
````

**Explanation:**  
Configures a Windows Dev Drive using the ReFS file system, optimized for development workloads. Dev Drive provides improved performance for source control operations, build processes, and large solution files—especially beneficial for Azure microservice architectures. The configuration ensures the drive is formatted and mounted as `Z:`, with Dev Drive optimizations enabled.

**Official Documentation:**  
- [Windows Dev Drive](https://learn.microsoft.com/en-us/windows/dev-drive/)
- [Optimize Dev Drive for Azure Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/how-to-optimize-dev-drive)

---

## Source Control Tools

### Git

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Git.Git
  directives:
    allowPrerelease: true
    description: Install Git version control system
  settings:
    id: Git.Git
````

**Explanation:**  
Installs Git, the essential distributed version control system for source code management. Git is foundational for Azure DevOps, GitHub integration, and infrastructure-as-code workflows. It is also required for Azure Bicep, GitOps, and optimized for performance when used with Dev Drive.

**Official Documentation:**  
- [Git Documentation](https://git-scm.com/doc)
- [WinGet Git Package](https://winget.run/pkg/Git.Git)

---

### GitHub CLI

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: GitHub.cli
  directives:
    allowPrerelease: true
    description: Install GitHub command-line interface
  settings:
    id: GitHub.cli
  dependsOn:
    - Git.Git # Requires Git for full functionality
````

**Explanation:**  
Installs the GitHub CLI (`gh`), enabling command-line management of GitHub repositories, issues, pull requests, and GitHub Actions. This tool streamlines Azure DevOps integration and automates workflows for Azure deployments. It depends on Git for core functionality.

**Official Documentation:**  
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [WinGet GitHub CLI Package](https://winget.run/pkg/GitHub.cli)

---

## Development Runtimes

### .NET SDK 9

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.DotNet.SDK.9
  directives:
    allowPrerelease: true
    description: Install .NET 9 SDK for application development
  settings:
    id: Microsoft.DotNet.SDK.9
````

**Explanation:**  
Installs the .NET 9 SDK, which is central to Azure development. It provides tools for building, testing, and deploying applications targeting Azure services, including Azure Functions, Web Apps, and containerized workloads. The SDK includes Azure-specific templates and middleware.

**Official Documentation:**  
- [.NET SDK Documentation](https://learn.microsoft.com/en-us/dotnet/core/sdk)
- [WinGet .NET SDK Package](https://winget.run/pkg/Microsoft.DotNet.SDK.9)

---

### .NET Runtime 9

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.DotNet.Runtime.9
  directives:
    allowPrerelease: true
    description: Install .NET 9 Runtime
  settings:
    id: Microsoft.DotNet.Runtime.9
  dependsOn:
    - Microsoft.DotNet.SDK.9 # Runtime is included in SDK, but explicit dependency ensures correct order
````

**Explanation:**  
Installs the .NET 9 Runtime, required for running .NET applications and Azure tooling. This ensures compatibility with Azure PowerShell, Azure Functions Core Tools, and local emulators. Explicit installation guarantees availability for tools that require the runtime directly.

**Official Documentation:**  
- [.NET Runtime Documentation](https://learn.microsoft.com/en-us/dotnet/core/runtime)
- [WinGet .NET Runtime Package](https://winget.run/pkg/Microsoft.DotNet.Runtime.9)

---

### Node.js

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: OpenJS.NodeJS
  directives:
    allowPrerelease: true
    description: Install Node.js JavaScript runtime
  settings:
    id: OpenJS.NodeJS
````

**Explanation:**  
Installs Node.js, a JavaScript runtime essential for modern web development and many Azure scenarios. Node.js is required for Azure Static Web Apps, Azure Functions (JavaScript/TypeScript), and npm-based Azure SDKs. It also supports local development and testing of Azure App Service Node.js apps.

**Official Documentation:**  
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [WinGet Node.js Package](https://winget.run/pkg/OpenJS.NodeJS)

---

## Development Tools

### Visual Studio Code

**YAML Configuration:**
````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.VisualStudioCode
  directives:
    allowPrerelease: true
    description: Install Visual Studio Code editor
  settings:
    id: Microsoft.VisualStudioCode
````

**Explanation:**  
Installs Visual Studio Code (VS Code), Microsoft's recommended editor for Azure development. VS Code offers deep integration with Azure services through extensions, supports ARM/Bicep authoring, and provides tools for local Azure Functions and App Service development.

**Official Documentation:**  
- [Visual Studio Code Documentation](https://code.visualstudio.com/docs)
- [WinGet VS Code Package](https://winget.run/pkg/Microsoft.VisualStudioCode)

---

## Best Practices

- **Use Descriptive Comments:** Each component in the YAML is well-commented, explaining its purpose and relevance to Azure development.
- **Explicit Dependencies:** Where necessary, `dependsOn` is used to ensure correct installation order (e.g., GitHub CLI depends on Git).
- **Secure Installations:** All tools are installed via WinGet, ensuring verified and secure sources.
- **Optimized Storage:** Dev Drive is configured for maximum performance, especially for large Azure repositories and build workloads.
- **Modular Configuration:** Each tool or runtime is defined as a separate resource, making the configuration easy to maintain and extend.
- **Documentation Links:** Official documentation is provided for each component, enabling quick access to further information.
- **YAML Formatting:** Use of consistent indentation and structure for readability and maintainability.

---

**For further customization, consider adding Azure CLI, Azure Functions Core Tools, and specific VS Code extensions in separate configuration files to tailor the environment for specialized Azure scenarios.**