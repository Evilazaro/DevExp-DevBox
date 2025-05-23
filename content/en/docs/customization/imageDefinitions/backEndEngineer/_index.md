---
title: Backend Development Configuration Sample
description: >
    Dev Box Image Definitions
weight: 11
---

## Overview

This document provides comprehensive documentation for the Microsoft Dev Box landing zone accelerator Backend Development Configuration Sample. The [Desired State Configuration (DSC)](https://learn.microsoft.com/en-us/powershell/dsc/overview?view=dsc-3.0&source=recommendations). file sets up a standardized Azure backend development environment, ensuring developers have all necessary tools and best practices implemented.

## Configuration Details

**File:** common-backend-config.dsc.yaml
**Version:** 0.2.0
**Purpose:** Standardized Azure backend development environment setup

## Purpose and Scope

This configuration installs and configures essential tools for Azure backend development, including:
- Azure command-line tools (CLI, AZD, Bicep)
- Data management tools
- Local development emulators for Azure services

The configuration follows Azure best practices and ensures developers can immediately begin working with Azure services using recommended patterns and tools.

## Configuration Structure

The file is structured as a DSC configuration with properties and resources:

```yaml
properties:
  configurationVersion: "0.2.0"
  resources:
    # Multiple resources defined
```

Resources are organized into logical groups:
- Azure Command-Line Tools
- Local Development Emulators

## Azure Command-Line Tools

### Azure CLI

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.AzureCLI
  directives:
    allowPrerelease: true
    description: Install Azure CLI for managing Azure resources from the command line
  settings:
    id: Microsoft.AzureCLI
```

**Key Features:**
- Unified authentication with Microsoft Entra ID (formerly Azure AD)
- Support for service principals and managed identities
- JSON-based output for automation and scripting
- Cross-platform compatibility for consistent workflows

**Security Best Practices:**
- Use `az login --tenant` to explicitly specify tenants
- Leverage managed identities where available
- Apply RBAC with principle of least privilege
- Use service principals with certificate-based auth for automation
- Regularly update CLI using `az upgrade` command
- Avoid storing credentials in CLI cache in shared environments
- Configure CLI to use your organization's approved proxy if required

**Common Development Scenarios:**
- Resource provisioning via templates and scripts
- Querying resource status and configurations
- Integrated deployment workflows with CI/CD
- Management of secrets and connection strings

### Azure Developer CLI (azd)

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.Azd
  directives:
    allowPrerelease: true
    description: Install Azure Developer CLI (azd) for end-to-end application development
  settings:
    id: Microsoft.Azd
  dependsOn:
    - Microsoft.AzureCLI
```

**Key Features:**
- End-to-end application development lifecycle management
- Built-in templates for common Azure architectural patterns
- Automated environment provisioning with infrastructure as code
- Integration with GitHub Actions and Azure DevOps for CI/CD
- Application monitoring and logging setup

**Best Practices:**
- Use environment variables for secrets (`azd env set`)
- Leverage service templates for consistent architecture
- Implement standardized application structures
- Follow Azure landing zone principles for environments
- Store azd environment configurations in version control
- Use azd pipeline integration for repeatable deployments
- Include `.env.template` file but exclude `.env` files from source control

**Common Development Scenarios:**
- Setting up complete development environments
- Implementing production-ready services with best practices
- Consistent local-to-cloud development experience
- Orchestrating multi-service deployments

### Bicep CLI

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.Bicep
  directives:
    allowPrerelease: true
    description: Install Bicep CLI for Infrastructure as Code development on Azure
  settings:
    id: Microsoft.Bicep
  dependsOn:
    - Microsoft.AzureCLI
```

**Key Features:**
- Native integration with Azure Resource Manager
- Support for all Azure resource types and apiVersions
- Resource visualization capabilities
- Module composition for reusable infrastructure
- Built-in functions for dynamic deployments

**Infrastructure as Code Best Practices:**
- Use modules for reusable components
- Implement parameterization for environment flexibility
- Apply Azure Policy as Code for governance
- Use symbolic references instead of string manipulation
- Implement deployment validation with 'what-if'
- Structure Bicep modules with clear separation of concerns
- Validate Bicep files with `bicep build` before deployment
- Use linting tools to enforce conventions and best practices
- Test deployments in isolation before integrating

**Common Development Scenarios:**
- Defining infrastructure as code for Azure environments
- Creating reusable infrastructure modules
- Setting up complex multi-resource deployments
- Implementing infrastructure governance

### Azure Data CLI

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.Azure.DataCLI
  directives:
    allowPrerelease: true
    description: Install Azure Data CLI for managing Azure data services
  settings:
    id: Microsoft.Azure.DataCLI
```

**Key Features:**
- Management of SQL Database, SQL Managed Instance, and PostgreSQL
- Support for Synapse Analytics workspace operations
- Data migration tooling and automation
- Integrated data governance capabilities
- Azure Arc data services management

**Data Best Practices:**
- Implement proper data tiering strategies
- Apply column and row level security where needed
- Configure backup and disaster recovery
- Use connection pooling for database access
- Implement proper indexing strategies
- Follow data residency and sovereignty requirements
- Implement automated data classification and protection
- Use dedicated service endpoints for data services
- Enable advanced threat protection for sensitive data

**Common Development Scenarios:**
- Database creation and configuration
- Data migration between environments
- Query performance optimization
- Data masking and security implementation
- Hybrid data estate management with Arc

## Local Development Emulators

### Azure Storage Emulator

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.Azure.StorageEmulator
  directives:
    allowPrerelease: true
    description: Install Azure Storage Emulator for local development
  settings:
    id: Microsoft.Azure.StorageEmulator
```

**Key Features:**
- Local emulation of Blob, Queue, and Table storage
- Development connection string compatibility with Azure Storage
- Support for Azure Storage SDK integration
- Local debugging of storage-dependent applications
- Reduced development costs by minimizing cloud resource usage

**Best Practices:**
- Use consistent connection strings between local and cloud
- Validate local operations match cloud behavior
- Implement proper exception handling for both 