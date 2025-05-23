---
title: 'Security'
description: >
  How to configure Azure Key Vault and manage secrets for your Dev Box environment
tags:
  - azure
  - microsoft-dev-box
  - azure-key-vault
  - secrets-management
  - security
  - infrastructure-as-code
  - azure-rbac

weight: 7
---

## Overview

This document provides detailed security configuration information for the Dev Box Accelerator defined in `security.yaml`. The configuration describes an Azure Key Vault resource to be deployed for storing sensitive credentials and secrets in a development environment.

## Table of Contents

- [Security Components](#security-components)
- [Configuration Purpose](#configuration-purpose)
- [Default Configuration](#default-configuration)
- [Configuration Structure](#configuration-structure)
- [Detailed Configuration](#detailed-configuration)
  - [Creation Flag](#creation-flag)
  - [Basic Key Vault Settings](#basic-key-vault-settings)
  - [Security Settings](#security-settings)
  - [Resource Organization (Tags)](#resource-organization-tags)
- [Best Practices](#best-practices)
- [Considerations](#considerations)
- [Additional Resources](#additional-resources)

## Security Components

![Security Components](./security.pngsecurity.png)

## Configuration Purpose

Azure Key Vault in Dev Box environments serves several critical purposes:

1. **Centralized Secret Management**: Securely store and manage access to GitHub tokens, connection strings, certificates, and other secrets needed by Dev Box environments
2. **Controlled Access**: Implement role-based access control (RBAC) to restrict which developers and services can access specific secrets
3. **Audit Logging**: Track when and by whom secrets are accessed for security monitoring
4. **Secret Rotation**: Enable secure rotation of credentials without disrupting dependent applications
5. **Compliance Requirements**: Meet organizational security and compliance requirements for secret management

The Key Vault configuration is designed to follow Azure security best practices while providing flexibility for different development scenarios.

## Default Configuration

The default configuration is designed for a development environment with appropriate security controls. It includes:

```yaml
create: true
keyVault:
  name: contoso
  description: Development Environment Key Vault
  secretName: gha-token
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 90
  enableRbacAuthorization: true
  tags:
    environment: dev
    division: Platforms
    team: DevExP
    project: Contoso-DevExp-DevBox
    costCenter: IT
    owner: Contoso
    landingZone: security
    resources: ResourceGroup
```

This configuration establishes a baseline that can be customized according to your specific requirements.

## Configuration Structure

The configuration is organized into several sections:

1. **Creation Flag**
2. **Basic Key Vault Settings**
3. **Security Settings**
4. **Resource Organization (Tags)**

## Detailed Configuration

### Creation Flag

```yaml
create: true
```

| Parameter | Description | Value |
|-----------|-------------|-------|
| `create` | Determines whether the Key Vault resource should be created | `true` (resource will be created) |

### Basic Key Vault Settings

```yaml
keyVault:
  name: contoso
  description: Development Environment Key Vault
  secretName: gha-token
```

| Parameter | Description | Value | Notes |
|-----------|-------------|-------|-------|
| `name` | Name of the Key Vault | `contoso` | Must be globally unique across all of Azure. Should follow naming conventions (3-24 alphanumeric characters). |
| `description` | Purpose of this Key Vault | `Development Environment Key Vault` | Provides context for the resource's intended use. |
| `secretName` | Name of the GitHub Actions token secret | `gha-token` | Identifies the secret that will store GitHub Actions authentication token. |

### Security Settings

```yaml
enablePurgeProtection: true
enableSoftDelete: true
softDeleteRetentionInDays: 90
enableRbacAuthorization: true
```

| Parameter | Description | Value | Notes |
|-----------|-------------|-------|-------|
| `enablePurgeProtection` | Prevents permanent deletion of secrets | `true` | Provides additional protection against accidental or malicious deletion. |
| `enableSoftDelete` | Enables recovery of deleted secrets | `true` | Azure recommended security practice. |
| `softDeleteRetentionInDays` | Retention period for deleted items | `90` days | Maximum allowed value is 90 days. Minimum is 7 days. |
| `enableRbacAuthorization` | Authentication mechanism | `true` | Uses Azure RBAC instead of vault access policies for more granular control. |

### Resource Organization (Tags)

```yaml
tags:
  environment: dev
  division: Platforms
  team: DevExP
  project: Contoso-DevExp-DevBox
  costCenter: IT
  owner: Contoso
  landingZone: security
  resources: ResourceGroup
```

| Tag | Description | Value | Purpose |
|-----|-------------|-------|---------|
| `environment` | Deployment environment | `dev` | Identifies non-production environment (dev/test/staging/prod) |
| `division` | Organizational division | `Platforms` | Maps resource to organizational structure |
| `team` | Team ownership | `DevExP` | Identifies team responsible for the resource |
| `project` | Project association | `Contoso-DevExp-DevBox` | Links resource to specific project |
| `costCenter` | Financial allocation | `IT` | For billing and cost allocation purposes |
| `owner` | Resource owner | `Contoso` | Identifies organizational ownership |
| `landingZone` | Landing zone classification | `security` | Categorizes resource within Azure landing zone model |
| `resources` | Resource grouping | `ResourceGroup` | Identifies grouping strategy |

## Best Practices

This configuration implements several Azure Key Vault best practices:

1. **Data Protection**:
   - Soft delete enabled with 90-day retention period
   - Purge protection enabled to prevent permanent deletion

2. **Access Control**:
   - RBAC authorization enabled (more granular than access policies)

3. **Organization**:
   - Comprehensive tagging strategy for governance and management
   - Clear naming conventions

## Considerations

When working with this configuration, consider:

1. **Key Vault Name**: The `contoso` name must be globally unique across Azure
2. **Secret Management**: Additional access policies may need configuration
3. **Networking**: Consider adding network security rules for production environments
4. **Compliance**: Verify that the configuration meets your organization's compliance requirements

## Additional Resources

- [Azure Key Vault documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure Key Vault security best practices](https://docs.microsoft.com/en-us/azure/key-vault/general/security-best-practices)
- [Azure tagging best practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
