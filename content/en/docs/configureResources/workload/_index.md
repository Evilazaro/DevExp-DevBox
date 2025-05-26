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

## Overview

The **devcenter.yaml** file is a core configuration file for the **Microsoft Dev Box Accelerator**. It defines the structure, governance, and operational settings for a centralized Dev Center resource in Azure. This file orchestrates developer workstation environments, project-specific settings, access controls, and resource tagging, enabling streamlined, secure, and role-based developer experiences. As part of the Dev Box Accelerator, it ensures that all Dev Box resources are provisioned, managed, and governed according to organizational standards and best practices.

---

## Table of Contents

- Dev Center Name (`name`)
- Azure Region (`location`)
- Catalog Item Sync (`catalogItemSyncEnableStatus`)
- Microsoft Hosted Network (`microsoftHostedNetworkEnableStatus`)
- Azure Monitor Agent (`installAzureMonitorAgentEnableStatus`)
- Identity Configuration (`identity`)
- Catalogs (`catalogs`)
- Environment Types (`environmentTypes`)
- Projects (`projects`)
- Top-level Tags (`tags`)

---

## Dev Center Name (`name`)

| Field | Example Value |
|-------|--------------|
| name  | `contoso-devcenter` |

### Purpose
Defines a globally unique identifier for the Dev Center resource.

### Default Configuration
```yaml
name: "contoso-devcenter"
```

### Detailed Configuration
The `name` field should follow a naming convention such as `[company]-[purpose]-[instance]` for clarity and uniqueness across Azure.

### Use Cases
- Identifying the Dev Center resource in Azure.
- Ensuring resource uniqueness in multi-tenant environments.

### Best Practices
- Use lowercase and hyphens for readability.
- Include company and purpose for easy identification.

### Considerations
- The name must be unique within Azure.
- Changing the name after deployment may require resource recreation.

---

## Azure Region (`location`)

| Field    | Example Value |
|----------|--------------|
| location | `eastus2`    |

### Purpose
Specifies the Azure region where the Dev Center and its resources are deployed.

### Default Configuration
```yaml
location: "eastus2"
```

### Detailed Configuration
Choose a region close to your development team to minimize latency and optimize performance.

### Use Cases
- Deploying resources near users for better performance.
- Meeting data residency requirements.

### Best Practices
- Select regions with high availability and required Azure services.
- Consider compliance and data sovereignty.

### Considerations
- Some features may not be available in all regions.
- Moving resources between regions is not supported.

---

## Catalog Item Sync (`catalogItemSyncEnableStatus`)

| Field                        | Example Value |
|------------------------------|--------------|
| catalogItemSyncEnableStatus  | `Enabled`    |

### Purpose
Controls automatic synchronization of catalog items from source repositories.

### Default Configuration
```yaml
catalogItemSyncEnableStatus: "Enabled"
```

### Detailed Configuration
When enabled, updates to catalog items are automatically applied when the source repository changes.

### Use Cases
- Keeping Dev Box configurations up to date.
- Automating environment updates.

### Best Practices
- Keep enabled for continuous integration of configuration changes.

### Considerations
- Disabling may require manual updates.
- Ensure repository access permissions are set correctly.

---

## Microsoft Hosted Network (`microsoftHostedNetworkEnableStatus`)

| Field                             | Example Value |
|-----------------------------------|--------------|
| microsoftHostedNetworkEnableStatus| `Enabled`    |

### Purpose
Determines if Dev Boxes use Microsoft-managed networking.

### Default Configuration
```yaml
microsoftHostedNetworkEnableStatus: "Enabled"
```

### Detailed Configuration
- `Enabled`: Simplifies network setup using Microsoft-managed networking.
- `Disabled`: Allows integration with custom VNets or on-premises networks.

### Use Cases
- Quick setup for development teams.
- Advanced networking for enterprise scenarios.

### Best Practices
- Use `Enabled` for simplicity unless custom networking is required.

### Considerations
- Custom networking may require additional configuration and permissions.

---

## Azure Monitor Agent (`installAzureMonitorAgentEnableStatus`)

| Field                              | Example Value |
|------------------------------------|--------------|
| installAzureMonitorAgentEnableStatus| `Enabled`    |

### Purpose
Controls automatic installation of the Azure Monitor agent on Dev Boxes.

### Default Configuration
```yaml
installAzureMonitorAgentEnableStatus: "Enabled"
```

### Detailed Configuration
Enables monitoring, security scanning, and compliance verification for all Dev Boxes.

### Use Cases
- Monitoring Dev Box health and usage.
- Enabling security and compliance checks.

### Best Practices
- Keep enabled for operational visibility and security.

### Considerations
- Disabling may reduce monitoring and security capabilities.

---

## Identity Configuration (`identity`)

| Field   | Example Value |
|---------|--------------|
| type    | `SystemAssigned` |

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
- `SystemAssigned`: Azure manages the identity lifecycle.
- `roleAssignments`: Assigns RBAC roles to the Dev Center and organizational groups.

### Use Cases
- Granting Dev Center permissions to manage resources.
- Delegating project admin roles to Azure AD groups.

### Best Practices
- Use Azure AD groups for role assignments.
- Assign least privilege required for operations.

### Considerations
- Ensure group memberships are up to date.
- Review RBAC assignments regularly.

---

## Catalogs (`catalogs`)

| Field | Example Value |
|-------|--------------|
| name  | `customTasks` |

### Purpose
Defines repositories containing Dev Box configurations and custom tasks.

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
Catalogs are version-controlled repositories (typically GitHub) containing scripts, templates, and configurations for Dev Box customization.

### Use Cases
- Centralizing configuration-as-code.
- Automating Dev Box provisioning tasks.

### Best Practices
- Store catalogs in source control.
- Use branches for environment-specific configurations.

### Considerations
- Ensure repository access for all users.
- Keep catalogs up to date with organizational standards.

---

## Environment Types (`environmentTypes`)

| Field | Example Value |
|-------|--------------|
| name  | `dev`        |

### Purpose
Defines deployment environments for applications (e.g., dev, staging).

### Default Configuration
```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
```

### Detailed Configuration
Each environment type represents a stage in the development lifecycle. `deploymentTargetId` can be set to target specific Azure subscriptions or resources.

### Use Cases
- Segregating development, testing, and production environments.
- Controlling deployment targets.

### Best Practices
- Align environment types with your SDLC.
- Use clear naming conventions.

### Considerations
- Ensure correct permissions for each environment.
- Avoid using production resources for development/testing.

---

## Projects (`projects`)

| Field | Example Value |
|-------|--------------|
| name  | `identityProvider` |

### Purpose
Defines distinct projects within the Dev Center, each with its own settings, pools, catalogs, and tags.

### Default Configuration
```yaml
projects:
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

### Detailed Configuration
Each project can define:
- Identity and RBAC assignments.
- Dev Box pools for different roles.
- Project-specific catalogs and environment types.
- Custom tags for governance.

### Use Cases
- Supporting multiple teams or applications.
- Customizing Dev Box environments per project.

### Best Practices
- Use separate projects for distinct teams or workloads.
- Apply consistent tagging for cost and resource tracking.

### Considerations
- Ensure RBAC assignments are scoped correctly.
- Keep project catalogs in sync with main repositories.

---

## Top-level Tags (`tags`)

| Field      | Example Value |
|------------|--------------|
| environment| `dev`        |

### Purpose
Applies consistent tags to the Dev Center resource for governance, cost management, and operational tracking.

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
Tags are key-value pairs used for resource organization, cost allocation, and reporting in Azure.

### Use Cases
- Filtering resources in the Azure portal.
- Generating cost and usage reports.

### Best Practices
- Apply tags consistently across all resources.
- Use tags for automation and policy enforcement.

### Considerations
- Tags are case-sensitive.
- Some Azure services have tag limits.

---

## References

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Azure Resource Manager Template Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/best-practices)
- [Azure Tagging Strategies](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)
