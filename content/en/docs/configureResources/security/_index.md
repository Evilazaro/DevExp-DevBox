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
*Part of Dev Box Accelerator Infrastructure Settings*

---

## Overview

The security.yaml file defines the configuration for an **Azure Key Vault** resource, which is a critical component of the Dev Box Accelerator's infrastructure settings. This file is located at security.yaml and is responsible for specifying how sensitive credentials and secrets are managed in the development environment. By centralizing secret management, the configuration ensures secure storage, access control, and compliance with organizational security policies.

The Key Vault configuration in this file enables teams to automate the provisioning and management of secrets, tokens, and other sensitive data, supporting secure DevOps workflows and protecting resources in the cloud.

---

## Table of Contents

- create
- keyVault
  - name
  - description
  - secretName
  - enablePurgeProtection
  - enableSoftDelete
  - softDeleteRetentionInDays
  - enableRbacAuthorization
  - tags

---

## Configuration Items

---

### `create`

| Property | Type    | Default | Required | Description                                 |
|----------|---------|---------|----------|---------------------------------------------|
| create   | boolean | true    | Yes      | Whether to create the Azure Key Vault       |

#### Purpose
Determines if the Key Vault resource should be provisioned as part of the deployment.

#### Default Configuration
```yaml
create: true
```

#### Detailed Configuration
- `true`: The Key Vault will be created during deployment.
- `false`: The Key Vault will not be created (useful if an existing vault is managed externally).

#### Use Cases
- Set to `true` for new environments.
- Set to `false` if using a pre-existing Key Vault.

#### Best Practices
- Use `true` for automated, repeatable deployments.
- Use `false` to avoid accidental overwrites in shared environments.

#### Considerations
- Ensure the value aligns with your infrastructure provisioning strategy.

---

### `keyVault`

#### Purpose
Defines all settings related to the Azure Key Vault resource.

#### Default Configuration
```yaml
keyVault:
  name: contoso
  description: Development Environment Key Vault
  secretName: gha-token
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 7
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

#### Detailed Configuration

##### `name`

| Property | Type   | Default  | Required | Description                                 |
|----------|--------|----------|----------|---------------------------------------------|
| name     | string | contoso  | Yes      | Globally unique name of the Key Vault       |

- **Purpose:** Identifies the Key Vault resource.
- **Best Practices:** Use a unique, descriptive name following naming conventions.
- **Considerations:** Must be globally unique in Azure.

##### `description`

| Property    | Type   | Default                         | Required | Description                      |
|-------------|--------|---------------------------------|----------|----------------------------------|
| description | string | Development Environment Key Vault | No       | Purpose of the Key Vault         |

- **Purpose:** Documents the intended use of the Key Vault.
- **Best Practices:** Keep descriptions clear and concise.

##### `secretName`

| Property   | Type   | Default    | Required | Description                         |
|------------|--------|------------|----------|-------------------------------------|
| secretName | string | gha-token  | Yes      | Name of the secret (e.g., token)    |

- **Purpose:** Specifies the name of a secret to be stored (e.g., GitHub Actions token).
- **Use Cases:** Store CI/CD tokens, API keys, etc.

##### `enablePurgeProtection`

| Property             | Type    | Default | Required | Description                                             |
|----------------------|---------|---------|----------|---------------------------------------------------------|
| enablePurgeProtection| boolean | true    | No       | Prevents permanent deletion of secrets                  |

- **Purpose:** Ensures secrets cannot be permanently deleted, even by authorized users.
- **Best Practices:** Always enable in production for compliance.

##### `enableSoftDelete`

| Property         | Type    | Default | Required | Description                                 |
|------------------|---------|---------|----------|---------------------------------------------|
| enableSoftDelete | boolean | true    | No       | Allows recovery of deleted secrets           |

- **Purpose:** Enables recovery of deleted secrets within a retention period.
- **Best Practices:** Enable to protect against accidental deletions.

##### `softDeleteRetentionInDays`

| Property                  | Type | Default | Required | Description                                         |
|---------------------------|------|---------|----------|-----------------------------------------------------|
| softDeleteRetentionInDays | int  | 7       | No       | Days deleted secrets remain recoverable (7-90 days)  |

- **Purpose:** Sets the retention period for soft-deleted secrets.
- **Considerations:** Choose a value that balances recovery needs and compliance.

##### `enableRbacAuthorization`

| Property                | Type    | Default | Required | Description                                         |
|-------------------------|---------|---------|----------|-----------------------------------------------------|
| enableRbacAuthorization | boolean | true    | No       | Uses Azure RBAC for access control                  |

- **Purpose:** Switches access control from vault policies to Azure RBAC.
- **Best Practices:** Use RBAC for centralized, scalable access management.

##### `tags`

| Property      | Type   | Default Value                  | Description                                 |
|---------------|--------|-------------------------------|---------------------------------------------|
| environment   | string | dev                           | Deployment environment                      |
| division      | string | Platforms                     | Organizational division                     |
| team          | string | DevExP                        | Team responsible                            |
| project       | string | Contoso-DevExp-DevBox         | Associated project                          |
| costCenter    | string | IT                            | Cost center for billing                     |
| owner         | string | Contoso                       | Resource owner                              |
| landingZone   | string | security                      | Azure landing zone classification           |
| resources     | string | ResourceGroup                 | Resource grouping identifier                |

- **Purpose:** Adds metadata for resource organization, billing, and management.
- **Best Practices:** Use consistent tagging across resources for governance.

---

## Best Practices

- **Security:** Always enable `enablePurgeProtection` and `enableSoftDelete` for production environments.
- **Access Control:** Prefer `enableRbacAuthorization` for scalable and auditable access management.
- **Naming:** Use clear, unique names for resources and secrets.
- **Tagging:** Apply consistent tags for cost management, ownership, and automation.
- **Documentation:** Keep descriptions up to date for operational clarity.
- **Retention:** Set `softDeleteRetentionInDays` according to compliance and recovery requirements.

---

## Considerations

- **Global Uniqueness:** The Key Vault name must be unique across Azure.
- **Compliance:** Some settings (like purge protection) may be required for regulatory compliance.
- **Automation:** Ensure the `create` flag aligns with your CI/CD and infrastructure-as-code workflows.
- **Cost:** Retention and protection features may impact resource costs.

---

## References

- [Azure Key Vault Documentation](https://learn.microsoft.com/azure/key-vault/general/)
- [Azure Key Vault Best Practices](https://learn.microsoft.com/azure/key-vault/general/best-practices)
- [Azure Resource Tagging](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-resources)