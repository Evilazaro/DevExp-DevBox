---
title: 'Dev Center'
tags:
  - microsoft-dev-box
  - dev-center
  - dev-box-projects
  - azure-rbac
  - azure-managed-identity
  - developer-experience
  - infrastructure-as-code


description: >
  How to configure the Core, Identity and Access Management, Catalogs, Environments and Projects settings for the Dev Center
weight: 9
---

..## Overview

This document provides comprehensive documentation for the devcenter.yaml configuration file, which is a core component of the Microsoft Dev Box Accelerator. The file defines the structure, access controls, environments, and resource governance for a centralized developer workstation platform in Azure. It enables organizations to manage Dev Center resources, projects, environments, and developer access in a scalable, secure, and automated manner.

The configuration leverages Azure best practices for resource management, identity, and governance, and is designed to support multiple teams, projects, and stages of the software development lifecycle (SDLC).

---

## Table of Contents

- Dev Center Name
- Location
- Catalog Item Sync Enable Status
- Microsoft Hosted Network Enable Status
- Install Azure Monitor Agent Enable Status
- Identity
- Catalogs
- Environment Types
- Projects
  - Identity Provider Project
  - eShop Project
- Tags

---

## Dev Center Name

| Key   | Type   | Example Value         | Required | Description                                      |
|-------|--------|----------------------|----------|--------------------------------------------------|
| name  | string | contoso-devcenter    | Yes      | Globally unique identifier for the Dev Center    |

### Purpose

Defines the unique name for the Dev Center resource, ensuring clear identification and management within Azure.

### Default Configuration

```yaml
name: "contoso-devcenter"
```

### Detailed Configuration

The `name` should follow a naming convention such as `[company]-[purpose]-[instance]` for clarity and uniqueness.

### Use Cases

- Identifying the Dev Center in Azure Portal and scripts.
- Enforcing naming standards across environments.

### Best Practices

- Use descriptive, unique names.
- Align with organizational naming conventions.

### Considerations

- The name must be globally unique within Azure.

---

## Location

| Key      | Type   | Example Value | Required | Description                                 |
|----------|--------|--------------|----------|---------------------------------------------|
| location | string | eastus2      | Yes      | Azure region for Dev Center deployment      |

### Purpose

Specifies the Azure region where the Dev Center and its resources will be deployed.

### Default Configuration

```yaml
location: "eastus2"
```

### Detailed Configuration

Choose a region close to your development team for optimal performance and compliance.

### Use Cases

- Reducing latency for developers.
- Meeting data residency requirements.

### Best Practices

- Select a region with available Dev Box resources.
- Consider compliance and data sovereignty.

### Considerations

- Some features may not be available in all regions.

---

## catalogItemSyncEnableStatus

| Key                         | Type   | Example Value | Required | Description                                        |
|-----------------------------|--------|---------------|----------|----------------------------------------------------|
| catalogItemSyncEnableStatus | string | Enabled       | Yes      | Enables automatic sync of catalog items from repos  |

### Purpose

Controls whether catalog items are automatically updated when source repositories change.

### Default Configuration

```yaml
catalogItemSyncEnableStatus: "Enabled"
```

### Detailed Configuration

When enabled, Dev Box configurations and scripts are kept up-to-date automatically.

### Use Cases

- Ensuring developers always have the latest configurations.
- Reducing manual update overhead.

### Best Practices

- Keep enabled for automation.
- Monitor for breaking changes in catalogs.

### Considerations

- Disabling may require manual updates.

---

## microsoftHostedNetworkEnableStatus

| Key                              | Type   | Example Value | Required | Description                                         |
|----------------------------------|--------|---------------|----------|-----------------------------------------------------|
| microsoftHostedNetworkEnableStatus | string | Enabled      | Yes      | Use Microsoft-managed networking for Dev Boxes       |

### Purpose

Determines if Dev Boxes use Microsoft-managed networking or custom VNets.

### Default Configuration

```yaml
microsoftHostedNetworkEnableStatus: "Enabled"
```

### Detailed Configuration

- `Enabled`: Simplifies network setup.
- `Disabled`: Use for custom or on-premises network integration.

### Use Cases

- Quick setup for small teams.
- Enterprise integration with custom networks.

### Best Practices

- Use `Enabled` for simplicity.
- Use `Disabled` for advanced scenarios.

### Considerations

- Custom networking requires additional configuration.

---

## installAzureMonitorAgentEnableStatus

| Key                                 | Type   | Example Value | Required | Description                                         |
|-------------------------------------|--------|---------------|----------|-----------------------------------------------------|
| installAzureMonitorAgentEnableStatus | string | Enabled      | Yes      | Installs Azure Monitor agent on Dev Boxes           |

### Purpose

Enables monitoring, security scanning, and compliance verification on Dev Boxes.

### Default Configuration

```yaml
installAzureMonitorAgentEnableStatus: "Enabled"
```

### Detailed Configuration

Automatically installs the Azure Monitor agent for operational visibility.

### Use Cases

- Security and compliance monitoring.
- Troubleshooting and diagnostics.

### Best Practices

- Keep enabled for visibility.
- Integrate with Azure Monitor dashboards.

### Considerations

- May incur additional Azure Monitor costs.

---

## Identity

| Key         | Type   | Example Value | Required | Description                                         |
|-------------|--------|---------------|----------|-----------------------------------------------------|
| identity    | object | See below     | Yes      | Managed identity and role assignments for Dev Center |

### Purpose

Defines how the Dev Center authenticates and what permissions it has.

### Default Configuration

```yaml
identity:
  type: "SystemAssigned"
  roleAssignments:
    devCenter:
      - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
        name: "Contributor"
      - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
        name: "User Access Administrator"
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: "8dae87fa-87b2-460b-b972-a4239fbd4a96"
        azureADGroupName: "Dev Manager"
        azureRBACRoles:
          - name: "DevCenter Project Admin"
            id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"
```

### Detailed Configuration

- `type`: Managed identity type (`SystemAssigned` recommended).
- `roleAssignments`: Assigns Azure RBAC roles to the Dev Center and organizational groups.

### Use Cases

- Secure resource management.
- Delegated access for Dev Managers.

### Best Practices

- Use Azure AD groups for role assignments.
- Grant least privilege required.

### Considerations

- Review RBAC assignments regularly.

---

## Catalogs

| Key     | Type   | Example Value | Required | Description                                         |
|---------|--------|---------------|----------|-----------------------------------------------------|
| catalogs| array  | See below     | Yes      | Repositories containing Dev Box configurations      |

### Purpose

Defines Git repositories for Dev Box customization and configuration.

### Default Configuration

```yaml
catalogs:
  - name: "customTasks"
    type: "gitHub"
    uri: "https://github.com/Evilazaro/DevExP-DevBox.git"
    branch: "main"
    path: ".configuration/devcenter/tasks"
```

### Detailed Configuration

Each catalog specifies its name, type, repository URI, branch, and path.

### Use Cases

- Centralized configuration management.
- Version control for Dev Box scripts.

### Best Practices

- Use Git for configuration-as-code.
- Organize catalogs by function.

### Considerations

- Ensure repository access permissions.

---

## Environment Types

| Key             | Type   | Example Value | Required | Description                                         |
|-----------------|--------|---------------|----------|-----------------------------------------------------|
| environmentTypes| array  | See below     | Yes      | Defines deployment environments for applications    |

### Purpose

Specifies the SDLC stages (e.g., dev, staging) for application deployment.

### Default Configuration

```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
```

### Detailed Configuration

Each environment type can have a unique deployment target.

### Use Cases

- Isolating development and staging environments.
- Supporting multiple SDLC stages.

### Best Practices

- Align with organizational SDLC.
- Use clear, descriptive names.

### Considerations

- Add more environments as needed (e.g., prod, test).

---

## Projects

### Identity Provider Project

| Key     | Type   | Example Value | Required | Description                                         |
|---------|--------|---------------|----------|-----------------------------------------------------|
| projects| array  | See below     | Yes      | Defines distinct projects within the Dev Center     |

#### Purpose

Defines a project for authentication/authorization services, with its own identity, pools, environments, catalogs, and tags.

#### Default Configuration

```yaml
- name: "identityProvider"
  description: "Identity Provider project."
  identity:
    type: SystemAssigned
    roleAssignments:
      - azureADGroupId: "331f48d7-4a23-4ec4-b03a-4af29c9c6f34"
        azureADGroupName: "identityProvider Developers"
        azureRBACRoles:
          - name: "Contributor"
            id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
          - name: "Dev Box User"
            id: "45d50f46-0b78-4001-a660-4198cbe8cd05"
          - name: "Deployment Environment User"
            id: "18e40d4e-8d2e-438d-97e1-9528336e149c"
  pools:
    - name: "backend-engineer"
      imageDefinitionName: "identityProvider-backend-engineer"
    - name: "frontend-engineer"
      imageDefinitionName: "identityProvider-frontend-engineer"
  environmentTypes:
    - name: "dev"
      deploymentTargetId: ""
    - name: "staging"
      deploymentTargetId: ""
  catalogs:
    environmentDefinition:
      name: "environments"
      type: "gitHub"
      uri: "https://github.com/Evilazaro/identityProvider.git"
      branch: "main"
      path: ".configuration/devcenter/environments"
    imageDefinition:
      name: "imageDefinitions"
      type: "gitHub"
      uri: "https://github.com/Evilazaro/identityProvider.git"
      branch: "main"
      path: ".configuration/devcenter/imageDefinitions"
  tags:
    environment: "dev"
    division: "Platforms"
    team: "DevExP"
    project: "DevExP-DevBox"
    costCenter: "IT"
    owner: "Contoso"
    resources: "Project"
```

#### Detailed Configuration

- **identity**: Project-level managed identity and RBAC.
- **pools**: Dev Box pools for backend and frontend engineers.
- **environmentTypes**: Available deployment environments.
- **catalogs**: Project-specific configuration and image catalogs.
- **tags**: Resource governance and cost allocation.

#### Use Cases

- Isolating authentication services development.
- Role-based Dev Box provisioning.

#### Best Practices

- Separate projects by team or workstream.
- Use pools for role-specific Dev Box images.

#### Considerations

- Ensure correct RBAC for each Azure AD group.

---

### eShop Project

Similar structure to the Identity Provider project, but for e-commerce application development. Includes additional RBAC for Key Vault access.

---

## Tags

| Key         | Type   | Example Value | Required | Description                                         |
|-------------|--------|---------------|----------|-----------------------------------------------------|
| tags        | object | See below     | Yes      | Top-level tags for resource governance              |

### Purpose

Applies consistent tags for cost management, ownership, and organization.

### Default Configuration

```yaml
tags:
  environment: "dev"
  division: "Platforms"
  team: "DevExP"
  project: "DevExP-DevBox"
  costCenter: "IT"
  owner: "Contoso"
  resources: "DevCenter"
```

### Detailed Configuration

Tags are key-value pairs applied to all resources created by the Dev Center.

### Use Cases

- Cost allocation.
- Resource tracking and governance.

### Best Practices

- Apply tags consistently.
- Use tags for automation and reporting.

### Considerations

- Tag values should be meaningful and standardized.

---

## References

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Azure RBAC Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Azure Resource Tagging Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)

