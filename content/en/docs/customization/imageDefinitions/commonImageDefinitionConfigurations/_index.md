---
title: Common DSC Configuration for .NET Engineers Sample
description: >
    Dev Box Image Definitions
weight: 9
---

## Overview

This document provides comprehensive documentation for the PowerShell Desired State Configuration (DSC) YAML file: **common-config.dsc.yaml**. This configuration is designed to automate the setup of a standardized development environment for .NET engineers, with a strong focus on Azure development workflows. It provisions essential tools, runtimes, and storage optimizations to streamline development, testing, and deployment of modern cloud applications.

---

## Table of Contents

- [Dev Drive (Storage Configuration)](#dev-drive-storage-configuration)
- [Git (Source Control Tool)](#git-source-control-tool)
- [GitHub CLI](#github-cli)
- [.NET 9 SDK](#net-9-sdk)
- [.NET 9 Runtime](#net-9-runtime)
- [Node.js](#nodejs)
- [Visual Studio Code](#visual-studio-code)

---

## Component Details

---

### Dev Drive (Storage Configuration)

#### YAML Configuration

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

#### Explanation

This component provisions a dedicated Dev Drive using the ReFS file system, optimized for development workloads. Dev Drive offers improved performance for source control operations (especially with large Azure repositories), build processes, and container operations. The configuration ensures the drive is formatted and mounted as `Z:`, with Dev Drive optimizations enabled.

- **Purpose:** Accelerates Git, build, and Docker operations for Azure development.
- **Azure Context:** Recommended for Azure Dev Box and large solution files in microservice architectures.

#### Official Documentation

- [Windows Dev Drive](https://learn.microsoft.com/en-us/windows/dev-drive/)
- [Optimize Dev Drive for Azure Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/how-to-optimize-dev-drive)

---

### Git (Source Control Tool)

#### YAML Configuration

````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Git.Git
  directives:
    allowPrerelease: true
    description: Install Git version control system
  settings:
    id: Git.Git
````

#### Explanation

Installs Git, the essential distributed version control system. Git is foundational for source code management, CI/CD, and infrastructure-as-code workflows. It is required for working with Azure DevOps, GitHub, and GitOps scenarios in Azure Arc and AKS.

- **Purpose:** Enables source control, collaboration, and automation.
- **Azure Context:** Required for Azure Repos, Bicep templates, and GitOps workflows.

#### Official Documentation

- [Git Documentation](https://git-scm.com/doc)
- [Azure Repos with Git](https://learn.microsoft.com/en-us/azure/devops/repos/git/)

---

### GitHub CLI

#### YAML Configuration

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

#### Explanation

Installs the GitHub CLI (`gh`), which streamlines GitHub workflows directly from the terminal. It enables management of repositories, issues, pull requests, and GitHub Actions, all of which are critical for Azure DevOps and CI/CD automation.

- **Purpose:** Automates GitHub workflows and integrates with Azure deployments.
- **Azure Context:** Used for managing Azure infrastructure code, GitHub Actions for Azure, and authenticating to GitHub Container Registry.

#### Official Documentation

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub Actions for Azure](https://learn.microsoft.com/en-us/azure/developer/github/)

---

### .NET 9 SDK

#### YAML Configuration

````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.DotNet.SDK.9
  directives:
    allowPrerelease: true
    description: Install .NET 9 SDK for application development
  settings:
    id: Microsoft.DotNet.SDK.9
````

#### Explanation

Installs the .NET 9 SDK, which is essential for building, testing, and deploying .NET applications targeting Azure services. The SDK includes tools for Azure Functions, Web Apps, and containerized workloads.

- **Purpose:** Provides the development platform for modern .NET and Azure applications.
- **Azure Context:** Integrates with Azure SDKs, templates, and supports Azure Functions and container apps.

#### Official Documentation

- [.NET SDK Documentation](https://learn.microsoft.com/en-us/dotnet/core/sdk/)
- [Azure for .NET Developers](https://learn.microsoft.com/en-us/dotnet/azure/)

---

### .NET 9 Runtime

#### YAML Configuration

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

#### Explanation

Installs the .NET 9 Runtime, required for running .NET applications and Azure tools that depend on .NET. While the SDK includes the runtime, explicit installation ensures compatibility for tools that require the runtime directly.

- **Purpose:** Enables execution of .NET applications and Azure tooling.
- **Azure Context:** Required for Azure PowerShell, Azure Functions Core Tools, and local emulators.

#### Official Documentation

- [.NET Runtime Documentation](https://learn.microsoft.com/en-us/dotnet/core/runtime/)
- [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)

---

### Node.js

#### YAML Configuration

````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: OpenJS.NodeJS
  directives:
    allowPrerelease: true
    description: Install Node.js JavaScript runtime
  settings:
    id: OpenJS.NodeJS
````

#### Explanation

Installs Node.js, a JavaScript runtime essential for modern web development and many Azure scenarios. Node.js is required for Azure Static Web Apps, Azure Functions (JavaScript/TypeScript), and npm-based Azure SDKs.

- **Purpose:** Supports JavaScript/TypeScript development and Azure tooling.
- **Azure Context:** Required for Azure Static Web Apps, Azure Functions, and DevOps pipelines.

#### Official Documentation

- [Node.js Documentation](https://nodejs.org/en/docs/)
- [Azure Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/)
- [Azure Functions JavaScript](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-node)

---

### Visual Studio Code

#### YAML Configuration

````yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.VisualStudioCode
  directives:
    allowPrerelease: true
    description: Install Visual Studio Code editor
  settings:
    id: Microsoft.VisualStudioCode
````

#### Explanation

Installs Visual Studio Code (VS Code), the recommended editor for Azure development. VS Code offers deep integration with Azure services through extensions, supports ARM/Bicep authoring, and provides a powerful terminal for Azure CLI and PowerShell.

- **Purpose:** Provides a modern, extensible code editor for cloud development.
- **Azure Context:** Enables direct Azure resource management, debugging, and deployment.

#### Official Documentation

- [Visual Studio Code Documentation](https://code.visualstudio.com/docs)
- [Azure Tools for VS Code](https://learn.microsoft.com/en-us/azure/developer/vscode/)

---

## Best Practices

- **Use Descriptive Comments:** Each component is documented with purpose, Azure context, and security/performance notes.
- **Explicit Dependencies:** Use `dependsOn` to ensure correct installation order.
- **Secure Installations:** All packages are installed via WinGet, ensuring verified sources.
- **Drive Optimization:** Dev Drive is configured for maximum performance with ReFS and Dev Drive features.
- **Extensibility:** Additional Azure extensions for VS Code should be managed in separate configurations for modularity.
- **Documentation Links:** Each component includes links to official documentation for further reference.

---

**For further customization, review the [Microsoft Configuration DSC Schema](https://aka.ms/configuration-dsc-schema/0.2) and [Azure Dev Box documentation](https://learn.microsoft.com/en-us/azure/dev-box/).**