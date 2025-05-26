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

# Azure Key Vault Configuration (security.yaml)

## Overview

The security.yaml file defines the configuration for an **Azure Key Vault** resource, which is used to securely store sensitive credentials and secrets in the development environment. This file is a core part of the **Dev Box Accelerator** infrastructure, enabling teams to manage secrets, tokens, and other confidential information in a secure, auditable, and compliant manner. By centralizing secret management, the configuration helps ensure that sensitive data is protected and accessible only to authorized users and services.

---

## Table of Contents

- Create
- Key Vault
  - Basic Settings
  - Security Settings
  - Resource Organization
- Best Practices
- Source

---

## Create

### Purpose

Determines whether the Azure Key Vault resource should be created as part of the deployment process.

### Default Configuration

```yaml
create: true
```

### Detailed Configuration

| Key    | Type    | Description                                            | Default |
|--------|---------|--------------------------------------------------------|---------|
| create | boolean | If `true`, the Key Vault resource will be provisioned. | true    |

### Use Cases

- **true**: When setting up a new environment or when the Key Vault does not exist.
- **false**: When reusing an existing Key Vault or managing it outside of this configuration.

### Best Practices

- Set to `true` for new deployments to ensure all required resources are provisioned.
- Set to `false` if you want to manage the Key Vault separately or avoid accidental overwrites.

### Considerations

- Ensure that setting this to `true` does not overwrite or conflict with existing resources.
- Proper permissions are required to create Azure resources.

---

## Key Vault

### Basic Settings

#### Purpose

Defines the identity and basic metadata for the Azure Key Vault resource.

#### Default Configuration

```yaml
keyVault:
  name: contoso
  description: Development Environment Key Vault
  secretName: gha-token
```

#### Detailed Configuration

| Key         | Type   | Description                                                      | Example Value                   |
|-------------|--------|------------------------------------------------------------------|---------------------------------|
| name        | string | Globally unique name for the Key Vault.                          | contoso                         |
| description | string | Human-readable description of the Key Vault's purpose.           | Development Environment Key Vault|
| secretName  | string | Name of the secret (e.g., GitHub Actions token) to be stored.    | gha-token                       |

#### Use Cases

- Naming conventions for easy identification and management.
- Descriptions for documentation and clarity.
- Storing specific secrets required by CI/CD pipelines.

#### Best Practices

- Use unique and descriptive names to avoid naming conflicts.
- Provide clear descriptions for future maintainers.
- Use meaningful secret names that reflect their purpose.

#### Considerations

- Key Vault names must be globally unique in Azure.
- Changing the name after creation requires resource recreation.

---

### Security Settings

#### Purpose

Configures security features to protect secrets and ensure compliance with organizational policies.

#### Default Configuration

```yaml
enablePurgeProtection: true
enableSoftDelete: true
softDeleteRetentionInDays: 7
enableRbacAuthorization: true
```

#### Detailed Configuration

| Key                      | Type    | Description                                                                 | Default/Example |
|--------------------------|---------|-----------------------------------------------------------------------------|-----------------|
| enablePurgeProtection    | boolean | Prevents permanent deletion of secrets, even by authorized users.           | true            |
| enableSoftDelete         | boolean | Enables recovery of deleted secrets within a retention period.               | true            |
| softDeleteRetentionInDays| integer | Number of days deleted secrets remain recoverable (7-90 days).               | 7               |
| enableRbacAuthorization  | boolean | Uses Azure RBAC for access control instead of vault access policies.         | true            |

#### Use Cases

- Enabling soft delete and purge protection to prevent accidental or malicious data loss.
- Using RBAC for centralized access management.

#### Best Practices

- Always enable soft delete and purge protection for production and critical environments.
- Use RBAC for scalable and auditable access control.
- Set an appropriate retention period based on compliance requirements.

#### Considerations

- Purge protection is irreversible once enabled.
- Soft delete retention must be between 7 and 90 days.
- RBAC requires proper role assignments in Azure.

---

### Resource Organization

#### Purpose

Tags and organizes the Key Vault resource for management, billing, and compliance.

#### Default Configuration

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

#### Detailed Configuration

| Key         | Type   | Description                                         | Example Value                |
|-------------|--------|-----------------------------------------------------|------------------------------|
| environment | string | Deployment environment (dev/test/staging/prod)      | dev                          |
| division    | string | Organizational division responsible                 | Platforms                    |
| team        | string | Team that owns the resource                         | DevExP                       |
| project     | string | Associated project                                  | Contoso-DevExp-DevBox        |
| costCenter  | string | Billing and chargeback cost center                  | IT                           |
| owner       | string | Resource owner                                      | Contoso                      |
| landingZone | string | Azure landing zone classification                   | security                     |
| resources   | string | Resource grouping identifier                        | ResourceGroup                |

#### Use Cases

- Tagging for cost allocation and reporting.
- Organizing resources for easier management and automation.
- Enabling policy enforcement and compliance tracking.

#### Best Practices

- Use consistent tagging across all resources.
- Include all relevant metadata for governance and billing.
- Regularly review and update tags as organizational structures change.

#### Considerations

- Inconsistent or missing tags can lead to management and billing challenges.
- Some tags may be required by organizational policies.

---

## Best Practices

- **Security**: Always enable soft delete and purge protection to safeguard secrets.
- **Access Control**: Prefer RBAC over access policies for scalable and auditable access management.
- **Tagging**: Apply comprehensive and consistent tags for all resources.
- **Documentation**: Keep descriptions and metadata up to date for clarity and maintainability.
- **Compliance**: Align retention and access settings with organizational and regulatory requirements.

---

## References

- [Azure Key Vault Documentation](https://learn.microsoft.com/azure/key-vault/general/)
- [Azure Resource Tagging Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-resources)
- [Azure RBAC for Key Vault](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Soft Delete and Purge Protection](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
