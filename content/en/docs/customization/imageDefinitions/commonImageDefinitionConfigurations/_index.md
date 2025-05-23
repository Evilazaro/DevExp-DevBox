---
title: Accelerator Common Engineer Image Configuration Documentation
description: >
    Dev Box Image Definitions
weight: 9
---

## Overview

This document provides comprehensive documentation for the common-config.dsc.yaml configuration file used in the Microsoft Dev Box landing zone accelerator. This Desired State Configuration (DSC) file establishes a standardized development environment with components optimized for Azure development.

## Contents

- Purpose and Scope
- Configuration Structure
- Dev Drive Configuration
- Source Control Tools
- Development Runtimes
- Development Tools
- Azure Integration Benefits
- Security Considerations
- Performance Optimizations

## Purpose and Scope

The common-config.dsc.yaml file defines a consistent development environment for Microsoft Dev Box with a focus on Azure development workflows. It includes:

- Optimized storage configuration using Dev Drive
- Essential source control tools for Azure DevOps and GitHub integration
- Development runtimes required for Azure application development
- Core development tools with Azure service integrations

This configuration ensures developers have the foundational tools needed for efficient Azure development while following best practices for performance and security.

## Configuration Structure

The file uses the DSC schema version 0.2.0 and is organized into logical sections:

```yaml
properties:
  configurationVersion: "0.2.0"
  resources:
    # Resources grouped by category
```

Each resource defines a component to be installed or configured and follows a consistent pattern:

- **Resource type**: Defines what kind of resource is being configured
- **ID**: Unique identifier for the resource
- **Directives**: Additional metadata and instructions
- **Settings**: Specific configuration for the resource
- **Dependencies**: Resources that must be installed first (where applicable)

## Dev Drive Configuration

```yaml
- resource: Disk
  id: DevDrive1
  directives:
    module: StorageDsc
    allowPrerelease: true
    description: Configure Dev Drive with ReFS format
  settings:
    DiskId: "0"
    DriveLetter: "Z"
    FSLabel: "Dev Drive 1"
    DevDrive: true
    AllowDestructive: true
    FSFormat: "ReFS"
    Size: "50Gb"
```

The Dev Drive configuration provides optimized filesystem performance specifically designed for development workloads:

- **ReFS (Resilient File System)** enables integrity streams and block cloning that significantly improve Git operations
- **50GB minimum size** provides sufficient space for typical development workloads
- **Drive letter Z:** is assigned as a standard for development drives
- **Block cloning** accelerates Docker container operations, beneficial for Azure container development

**Azure Benefits:**
- Faster Git operations when working with large Azure repositories
- Improved build performance for Azure services
- Optimized for large solution files common in microservice architectures

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

Git provides essential version control capabilities:

- Required for Azure DevOps repositories and GitHub integration
- Supports Azure Bicep template development and versioning
- Enables GitOps workflows with Azure Arc and Azure Kubernetes Service
- Performance is optimized when used with the configured Dev Drive

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

GitHub CLI enhances GitHub workflow automation:

- Manages GitHub repositories hosting Azure infrastructure code
- Creates and manages GitHub Actions workflows for Azure deployments
- Streamlines work with issues and pull requests for Azure service development
- Handles authentication to GitHub Container Registry for Azure container deployments

**Security Note:** Authentication tokens are securely stored in Windows Credential Manager

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

The .NET SDK provides core development capabilities for Azure:

- Azure SDK integration for all Azure services
- Built-in templates for Azure Functions and Web Apps
- Support for containerized applications on Azure Container Apps
- Tools for Microsoft Entra ID (formerly Azure AD) integration
- Azure-optimized middleware components

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

The .NET Runtime enables execution of .NET applications:

- Required by many Azure command-line tools (Azure PowerShell, etc.)
- Supports running Azure Functions core tools locally
- Needed for Azure Storage Emulator and other local emulators
- Enables testing of containerized .NET applications before Azure deployment

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

Node.js provides a JavaScript runtime essential for modern web development:

- Required for Azure Static Web Apps local development
- Used by Azure Functions for JavaScript/TypeScript function development
- Powers npm packages for Azure SDK for JavaScript
- Enables local development of Azure App Service Node.js applications
- Required for many Azure DevOps build pipelines

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

VS Code is Microsoft's recommended editor for Azure development:

- Direct Azure resource management through Azure extensions
- Integrated terminal for Azure CLI and PowerShell commands
- Azure Functions local development and debugging
- Azure App Service deployment integration
- Cosmos DB explorer and Storage explorer integrations
- ARM template and Bicep authoring and validation

Additional Azure extensions can be installed in separate configurations to provide targeted functionality for specific development scenarios.

## Azure Integration Benefits

This configuration provides several key benefits for Azure development:

1. **Performance Optimization**: Dev Drive significantly improves Git operations and build performance for Azure projects
2. **Streamlined Azure Workflows**: Tools like GitHub CLI enable efficient CI/CD for Azure deployments
3. **Comprehensive Runtime Support**: .NET SDK and Runtime provide the foundation for Azure service development
4. **Integrated Development Experience**: VS Code offers native integration with Azure services
5. **GitOps Enablement**: Git and GitHub CLI support modern GitOps practices for Azure resources

## Security Considerations

The configuration implements several security best practices:

- WinGet installation ensures packages come from trusted sources
- GitHub CLI stores authentication tokens securely in Windows Credential Manager
- Dependencies are explicitly declared to ensure proper installation order
- Prerelease flags are used for controlled updates of critical components

## Performance Optimizations

Several performance considerations are built into this configuration:

- **Dev Drive with ReFS**: Optimized for Git operations and large solutions
- **Tool Co-location**: All development tools and runtimes are installed to work together efficiently
- **Dependency Management**: Tools are installed in the correct order to ensure optimal configuration

---

*This documentation is part of the Microsoft Dev Box landing zone accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*