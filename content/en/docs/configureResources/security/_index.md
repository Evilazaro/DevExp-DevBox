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

This document provides a comprehensive analysis of the [**security.yaml**](https://github.com/Evilazaro/DevExp-DevBox/blob/main/infra/settings/security/security.yaml) configuration file, a core component of the Microsoft Dev Box Accelerator. The Accelerator enables rapid, modular, and secure provisioning of development environments in Azure. The `security.yaml` file governs the setup and management of an Azure Key Vault resource, which is critical for securely storing sensitive credentials and secrets required by development teams. By decoupling security configuration, the Accelerator ensures best practices, compliance, and flexibility across environments.

---

## Table of Contents

- [Overview](#overview)
- [Configurations](#configurations)
  - [Resource Creation](#resource-creation)
  - [Key Vault Configuration](#key-vault-configuration)
  - [Security Settings](#security-settings)
  - [Resource Organization (Tags)](#resource-organization-tags)
- [Examples and Use Cases](#examples-and-use-cases)
  - [Example 1: Provisioning a Key Vault for a New Dev Environment](#example-1-provisioning-a-key-vault-for-a-new-dev-environment)
  - [Example 2: Reusing an Existing Key Vault](#example-2-reusing-an-existing-key-vault)
- [Best Practices](#best-practices)
- [References](#references)

---

## Configurations

Below is a detailed breakdown of each section and key in the `security.yaml` file, including their YAML representation and purpose.

### Resource Creation

```yaml
create: true
```
- **Purpose**: Indicates whether the Azure Key Vault resource should be created as part of the deployment.
- **Type**: Boolean (`true` or `false`)
- **Typical Use**: Set to `true` for initial deployments; set to `false` if the Key Vault already exists and should not be recreated.

---

### Key Vault Configuration

```yaml
keyVault:
  name: contoso
  description: Development Environment Key Vault
  secretName: gha-token
```
- **name**: Globally unique name for the Key Vault.
- **description**: Human-readable description of the Key Vault’s purpose.
- **secretName**: Name of the secret (e.g., a GitHub Actions token) to be stored in the Key Vault.

---

### Security Settings

```yaml
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 7
  enableRbacAuthorization: true
```
- **enablePurgeProtection**: Prevents permanent deletion of secrets, even by authorized users. Enhances data protection.
- **enableSoftDelete**: Allows recovery of deleted secrets within a retention period.
- **softDeleteRetentionInDays**: Number of days (7–90) that deleted secrets remain recoverable.
- **enableRbacAuthorization**: Uses Azure Role-Based Access Control (RBAC) for access management instead of legacy access policies.

---

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
- **Purpose**: Tags provide metadata for resource organization, cost management, and governance.
- **Common Tags**:
  - `environment`: Deployment environment (e.g., dev, test, prod)
  - `division`, `team`, `project`: Organizational context
  - `costCenter`: For billing and chargeback
  - `owner`: Resource owner
  - `landingZone`: Azure landing zone classification
  - `resources`: Resource grouping identifier

---

## Examples and Use Cases

### Example 1: Provisioning a Key Vault for a New Dev Environment

A new development team needs a secure place to store secrets for CI/CD pipelines. By setting `create: true` and specifying the `secretName`, the Accelerator will provision a Key Vault and store the required GitHub Actions token.

```yaml
create: true
keyVault:
  name: devbox-kv-001
  description: Dev Box Key Vault for Team Alpha
  secretName: gha-token
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 14
  enableRbacAuthorization: true
  tags:
    environment: dev
    team: Alpha
    project: DevBox
    costCenter: IT
    owner: TeamAlphaLead
    landingZone: security
    resources: ResourceGroup
```

### Example 2: Reusing an Existing Key Vault

If the Key Vault already exists, set `create: false` to avoid redeployment:

```yaml
create: false
keyVault:
  name: existing-kv
  # ...other settings...
```

---

## Best Practices

- **Unique Naming**: Ensure the `name` is globally unique within Azure to avoid deployment failures.
- **Retention Period**: Adjust `softDeleteRetentionInDays` based on your organization’s compliance and recovery requirements.
- **RBAC vs. Access Policies**: Prefer `enableRbacAuthorization: true` for modern, scalable access control.
- **Tagging**: Use descriptive and consistent tags to simplify resource management, cost tracking, and automation.
- **Security**: Always enable `enablePurgeProtection` and `enableSoftDelete` for production environments to prevent accidental or malicious loss of secrets.
- **Schema Validation**: Use the provided `$schema` directive for IDE validation and to prevent misconfiguration.

---

## References

- [Microsoft Dev Box Accelerator Security Docs](https://evilazaro.github.io/DevExp-DevBox/docs/configureresources/security/)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/basic-concepts)
- [Azure Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)

