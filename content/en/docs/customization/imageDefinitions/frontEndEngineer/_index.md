---
title: Frontend Development Configuration Sample
description: >
    Dev Box Image Definitions
weight: 10
---

## Overview

This document provides comprehensive documentation for the Frontend Development Configuration Sample used in the Microsoft Dev Box landing zone accelerator. This configuration establishes a standardized Azure frontend development environment through Desired State Configuration (DSC).

## Configuration Details

**File:** common-frontend-usertasks-config.dsc.yaml
**Version:** 0.2.0
**Maintainer:** DevExp Team

## Purpose and Scope

This DSC configuration creates a complete Azure frontend development environment with:
- .NET development tools for cross-platform development
- API testing capabilities through Postman
- Visual Studio Code with Azure-optimized extensions

The configuration follows Azure best practices and ensures developers have the necessary tools to build frontend applications that integrate seamlessly with Azure services.

## Requirements

- Microsoft Dev Box with Windows 11
- Administrator access for tool installation
- Internet connectivity for package downloads

## Configuration Structure

The configuration follows a resource-based approach with detailed documentation for each component:

```yaml
properties:
  configurationVersion: 0.2.0
  resources:
    # Multiple resources defined here
```

Each resource is structured with:
- **Resource type**: The DSC resource provider
- **ID**: Unique identifier for the resource
- **Directives**: Additional metadata and execution context
- **Settings**: Resource-specific configuration

## Configured Components

### 1. Postman API Platform

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Postman.Postman
  directives:
    description: Install Postman API platform for designing, testing and documenting APIs
    allowPrerelease: true
  settings:
    id: Postman.Postman
```

**Purpose:**
- Test REST API endpoints from Azure services
- Create and manage API collections for consistent testing
- Generate API documentation for team collaboration
- Set up automated test suites for frontend-to-backend integration

**Azure Integration Benefits:**
- Simplifies testing of Azure Functions, API Management, and other Azure API endpoints
- Enables creation of environment-specific variables for dev/test/prod Azure environments
- Supports OAuth workflows for Microsoft Entra ID (Azure AD) authentication

### 2. .NET Workload Update

```yaml
- resource: PSDscResources/Script
  id: Dotnet.WorkloadUpdate
  directives:
    description: Update all installed .NET workloads
    securityContext: elevated
  settings:
    SetScript: |
      # Script content
    GetScript: return $false
    TestScript: return $false
```

**Purpose:**
- Ensures all installed .NET workloads are up-to-date
- Maintains compatibility with Azure services and security updates
- Follows Microsoft's recommendation for regular tooling updates

**Frontend-specific .NET workloads:**
- Blazor for interactive web applications
- MAUI for cross-platform desktop/mobile applications
- ASP.NET Core for web APIs and server-rendered applications
- Azure Static Web Apps tools for serverless hosting
- JavaScript/.NET interoperability tools

**Script Implementation:**
- Sets execution policy to bypass for automation
- Combines machine and user paths to ensure dotnet command accessibility
- Updates all workloads with fault tolerance for unavailable sources
- Implements proper error handling and verbose logging

### 3. Visual Studio Code Extensions

```yaml
- resource: PSDscResources/Script
  id: Microsoft.VisualStudioCode.Extensions
  directives:
    description: Install VS Code Extensions for Azure frontend development
    securityContext: elevated
    allowPrerelease: true
  settings:
    SetScript: |
      # Script content
    GetScript: return $false
    TestScript: return $false
```

**Purpose:**
- Installs essential extensions for frontend development with Azure integration
- Provides syntax highlighting, IntelliSense, debugging, and other features
- Follows Microsoft Dev Box landing zone accelerator best practices for developer productivity

**Installed Extensions:**

| Extension | Purpose | Azure Integration |
|-----------|---------|-------------------|
| ms-vscode.powershell | PowerShell language support | Azure automation scripts |
| ms-vscode-remote.remote-wsl | WSL integration | Linux-based Azure development |
| ms-dotnettools.csdevkit | C# development | Azure Functions, Web Apps |
| ms-vscode.vscode-typescript-next | Modern TypeScript | Azure Static Web Apps |
| redhat.vscode-yaml | YAML support | Azure Pipeline configurations |
| ms-azuretools.vscode-bicep | Bicep language | Azure infrastructure as code |
| ms-vscode.vscode-node-azure-pack | Azure Tools | Comprehensive Azure services |
| ms-vscode.azurecli | Azure CLI | Command-line Azure management |
| GitHub.remotehub | GitHub integration | Azure DevOps integration |
| GitHub.vscode-pull-request-github | PR integration | Code review workflows |
| Postman.postman-for-vscode | Postman integration | API testing in editor |

## Azure Best Practices

This configuration implements several Azure development best practices:

1. **Cross-Platform Development Support**:
   - WSL integration enables testing in Linux environments similar to Azure hosting
   - Ensures code works consistently across development and production platforms

2. **Infrastructure as Code**:
   - Bicep extension for declarative Azure resource management
   - YAML support for Azure Pipelines and GitHub Actions workflows

3. **Security-First Approach**:
   - PowerShell execution policy configured for automation security
   - Principle of least privilege applied through security contexts

4. **DevOps Integration**:
   - GitHub extensions for repository and pull request management
   - Automated tooling for continuous integration and delivery

5. **Modern Web Development**:
   - Latest TypeScript features for type-safe frontend development
   - Blazor tools for C#-based web applications on Azure

## Usage Scenarios

This configuration is ideal for developers working on:

1. **Azure Static Web Apps**:
   - Single-page applications with JavaScript frameworks
   - Blazor WebAssembly applications
   - Integration with Azure Functions backends

2. **Azure App Service Web Apps**:
   - Server-rendered applications with ASP.NET Core
   - Progressive Web Apps with offline capabilities
   - Hybrid applications leveraging Azure services

3. **Azure API-driven Applications**:
   - Applications consuming Azure API Management endpoints
   - Microservices architectures with Azure Container Apps
   - Serverless applications with Azure Functions backends

## Maintenance and Updates

The configuration ensures tooling remains up-to-date through:

- Allowance for prerelease versions when needed for latest features
- Automatic update of .NET workloads
- Installation of extension packs that receive regular updates

## Idempotency Note

The current implementation does not perform full idempotency checks. In production environments, the TestScript and GetScript properties should be enhanced to check for:
- Specific extension versions
- Current .NET workload states
- Required application versions

This would prevent unnecessary reinstallations during regular configuration refreshes.

---

*This documentation is part of the Microsoft Dev Box landing zone accelerator project. For more information, visit the Microsoft Azure Documentation.*