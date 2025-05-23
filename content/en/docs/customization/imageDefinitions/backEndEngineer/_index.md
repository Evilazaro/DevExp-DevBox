---
title: Common DSC Configuration for .NET Back-end Engineers Sample
description: >
    Dev Box Image Definitions
weight: 11
---

## Overview

This document explains the structure and purpose of the [**common-backend-config.dsc.yaml file**](https://github.com/Evilazaro/DevExp-DevBox/blob/main/.configuration/devcenter/workloads/common-backend-config.dsc.yaml), which defines a Desired State Configuration (DSC) for setting up a standardized Azure backend development environment. Each component is described with its YAML configuration, a detailed explanation, and a link to official documentation.

---

## Table of Contents

- [Overview](#overview)
- [Configuration Properties](#configuration-properties)
- [Azure Command-Line Tools](#azure-command-line-tools)
  - [Azure CLI](#azure-cli)
  - [Azure Developer CLI (azd)](#azure-developer-cli-azd)
  - [Bicep CLI](#bicep-cli)
  - [Azure Data CLI](#azure-data-cli)
- [Local Development Emulators](#local-development-emulators)
  - [Azure Storage Emulator](#azure-storage-emulator)
  - [Azure Cosmos DB Emulator](#azure-cosmos-db-emulator)
- [References](#references)

---

## Default Configuration

```yaml
# yaml-language-server: $schema=https://aka.ms/configuration-dsc-schema/0.2

properties:
  configurationVersion: "0.2.0"
  resources:
    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.AzureCLI
      directives:
        allowPrerelease: true
        description: Install Azure CLI for managing Azure resources from the command line
      settings:
        id: Microsoft.AzureCLI

    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.Azd
      directives:
        allowPrerelease: true
        description: Install Azure Developer CLI (azd) for end-to-end application development
      settings:
        id: Microsoft.Azd
      dependsOn:
        - Microsoft.AzureCLI

    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.Bicep
      directives:
        allowPrerelease: true
        description: Install Bicep CLI for Infrastructure as Code development on Azure
      settings:
        id: Microsoft.Bicep
      dependsOn:
        - Microsoft.AzureCLI

    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.Azure.DataCLI
      directives:
        allowPrerelease: true
        description: Install Azure Data CLI for managing Azure data services
      settings:
        id: Microsoft.Azure.DataCLI

    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.Azure.StorageEmulator
      directives:
        allowPrerelease: true
        description: Install Azure Storage Emulator for local development
      settings:
        id: Microsoft.Azure.StorageEmulator

    - resource: Microsoft.WinGet.DSC/WinGetPackage
      id: Microsoft.Azure.CosmosEmulator
      directives:
        allowPrerelease: true
        description: Install Azure Cosmos DB Emulator for local NoSQL database development
      settings:
        id: Microsoft.Azure.CosmosEmulator
```
---

## Configuration Properties

```yaml
properties:
  configurationVersion: "0.2.0"
```

**Explanation:**  
Defines the DSC schema version used for this configuration. Keeping this up to date ensures compatibility with the latest DSC features.

---

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

**Explanation:**  
Installs the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) tool, which is foundational for managing Azure resources, scripting, and automation. It supports unified authentication, RBAC, and is a dependency for other Azure tools.

- **Best Practices:** Use `az login --tenant`, leverage managed identities, and regularly update the CLI.
- **Official Docs:** [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)

---

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
    - Microsoft.AzureCLI # AZD requires Azure CLI to function properly
```

**Explanation:**  
Installs the [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/), which streamlines application development, deployment, and environment management on Azure. It depends on Azure CLI.

- **Best Practices:** Use environment variables for secrets, version control environment configs, and integrate with CI/CD.
- **Official Docs:** [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)

---

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
    - Microsoft.AzureCLI # Bicep extensions use Azure CLI for deployment
```

**Explanation:**  
Installs the [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/), a domain-specific language for deploying Azure resources with improved syntax and modularity over ARM templates.

- **Best Practices:** Use modules, parameterization, and validate files with `bicep build`.
- **Official Docs:** [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

---

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

**Explanation:**  
Installs the [Azure Data CLI (azdata)](https://learn.microsoft.com/en-us/sql/azdata/install/deploy-install-azdata), which provides commands for managing Azure data services, including SQL, PostgreSQL, and Synapse Analytics.

- **Best Practices:** Implement data tiering, security, and backup strategies.
- **Official Docs:** [Azure Data CLI Documentation](https://learn.microsoft.com/en-us/sql/azdata/install/deploy-install-azdata)

---

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

**Explanation:**  
Installs the [Azure Storage Emulator](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-emulator), which allows local development and testing of applications using Azure Storage APIs without requiring a cloud subscription.

- **Best Practices:** Use consistent connection strings, validate local/cloud parity, and consider using [Azurite](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite) for newer features.
- **Official Docs:** [Azure Storage Emulator Documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-emulator)

---

### Azure Cosmos DB Emulator

```yaml
- resource: Microsoft.WinGet.DSC/WinGetPackage
  id: Microsoft.Azure.CosmosEmulator
  directives:
    allowPrerelease: true
    description: Install Azure Cosmos DB Emulator for local NoSQL database development
  settings:
    id: Microsoft.Azure.CosmosEmulator
```

**Explanation:**  
Installs the [Azure Cosmos DB Emulator](https://learn.microsoft.com/en-us/azure/cosmos-db/local-emulator), providing a local instance of Cosmos DB for development and testing with multiple APIs (SQL, MongoDB, Gremlin, Cassandra).

- **Best Practices:** Never use emulator certificates in production, validate partition key strategies, and simulate production workloads.
- **Official Docs:** [Azure Cosmos DB Emulator Documentation](https://learn.microsoft.com/en-us/azure/cosmos-db/local-emulator)

---

## References

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Data CLI Documentation](https://learn.microsoft.com/en-us/sql/azdata/install/deploy-install-azdata)
- [Azure Storage Emulator Documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-emulator)
- [Azure Cosmos DB Emulator Documentation](https://learn.microsoft.com/en-us/azure/cosmos-db/local-emulator)
- [DSC Configuration Schema](https://aka.ms/configuration-dsc-schema/0.2)

---

*For more information, see the [DevExp-DevBox Repository](https://github.com/Evilazaro/DevExp-DevBox/).*