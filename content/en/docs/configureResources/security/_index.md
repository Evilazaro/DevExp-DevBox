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

This security.yaml file is a modular configuration file used within the **Microsoft Dev Box Accelerator**. Its primary purpose is to define and manage the settings for an **Azure Key Vault** resource, which securely stores sensitive credentials and secrets (such as tokens, passwords, and certificates) for development environments. The configuration is designed to be decoupled and reusable, enabling teams to manage security resources consistently across multiple environments and projects.

---

## Configuration Sections & Keys

Below is a breakdown of each section and key in the YAML file:

### Root Level

- **create**  
  *Type:* `boolean`  
  *Description:* Indicates whether the Key Vault resource should be created as part of the deployment.  
  *Example:* `create: true`

- **keyVault**  
  *Type:* `object`  
  *Description:* Contains all settings related to the Azure Key Vault resource.

---

### `keyVault` Section

#### Basic Settings

- **name**  
  *Type:* `string`  
  *Description:* Globally unique name for the Key Vault.  
  *Example:* `name: contoso`

- **description**  
  *Type:* `string`  
  *Description:* Human-readable description of the Key Vault’s purpose.  
  *Example:* `description: Development Environment Key Vault`

- **secretName**  
  *Type:* `string`  
  *Description:* Name of the secret (e.g., a GitHub Actions token) to be stored in the Key Vault.  
  *Example:* `secretName: gha-token`

#### Security Settings

- **enablePurgeProtection**  
  *Type:* `boolean`  
  *Description:* Prevents permanent deletion of secrets, even by authorized users.  
  *Recommended:* `true` for production and sensitive environments.

- **enableSoftDelete**  
  *Type:* `boolean`  
  *Description:* Enables recovery of deleted secrets within a retention period.  
  *Recommended:* `true`

- **softDeleteRetentionInDays**  
  *Type:* `integer` (7–90)  
  *Description:* Number of days deleted secrets remain recoverable.  
  *Example:* `softDeleteRetentionInDays: 7`

- **enableRbacAuthorization**  
  *Type:* `boolean`  
  *Description:* Uses Azure RBAC for access control instead of legacy access policies.  
  *Recommended:* `true` for centralized access management.

#### Resource Organization

- **tags**  
  *Type:* `object`  
  *Description:* Key-value pairs for resource classification, ownership, and cost management.  
  *Keys include:*  
    - `environment` (e.g., dev, test, prod)  
    - `division` (e.g., Platforms)  
    - `team` (e.g., DevExP)  
    - `project` (e.g., Contoso-DevExp-DevBox)  
    - `costCenter` (e.g., IT)  
    - `owner` (e.g., Contoso)  
    - `landingZone` (e.g., security)  
    - `resources` (e.g., ResourceGroup)

---

## Examples & Use Cases

### Example 1: Creating a Dev Environment Key Vault

```yaml
create: true
keyVault:
  name: contoso-dev-kv
  description: Key Vault for Dev Box development secrets
  secretName: gha-token
  enablePurgeProtection: true
  enableSoftDelete: true
  softDeleteRetentionInDays: 14
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

**Use Case:**  
A development team needs a secure place to store GitHub Actions tokens and other secrets for their Dev Box environment. This configuration ensures secrets are protected, recoverable, and access is managed via Azure RBAC.

---

## Tips & Best Practices

- **Global Uniqueness:**  
  The `name` of the Key Vault must be globally unique within Azure.

- **Security:**  
  Always enable `enablePurgeProtection` and `enableSoftDelete` for production and critical environments to prevent accidental or malicious data loss.

- **RBAC:**  
  Prefer `enableRbacAuthorization: true` for modern, centralized access control.

- **Tagging:**  
  Use descriptive and consistent tags to simplify resource management, cost tracking, and compliance.

- **Secret Management:**  
  Regularly review and rotate secrets stored in the Key Vault. Use automation where possible.

- **Schema Validation:**  
  The file references a JSON schema (`security.schema.json`) for validation. Use tools that support schema validation to catch configuration errors early.

---

## References

- [Azure Key Vault Documentation](https://learn.microsoft.com/azure/key-vault/)
- [Microsoft Dev Box Accelerator](https://learn.microsoft.com/azure/dev-box/)
- [Best Practices for Azure Resource Tagging](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-resources)
