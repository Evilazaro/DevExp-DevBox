---
title: Workload Settings Documentation
tags: 
 - devbox
 - resources
 - subnet
description: Workload Settings Documentation
---

# Microsoft Dev Box Accelerator: Workload Settings Documentation

## Overview

This documentation provides a comprehensive explanation of the Microsoft Dev Box Accelerator defined in devcenter.yaml. Azure Dev Box is a managed service that enables organizations to provision, manage, and secure development workstations in the cloud, allowing developers to focus on code rather than environment setup.

## Table of Contents

- [Configuration Purpose](#configuration-purpose)
- [Core Settings](#core-settings)
  - [Dev Center Properties](#dev-center-properties)
  - [Feature Flags](#feature-flags)
- [Identity and Access Control](#identity-and-access-control)
  - [Managed Identity Configuration](#managed-identity-configuration)
  - [Role Assignments](#role-assignments)
  - [Organizational Roles](#organizational-roles)
- [Content Management](#content-management)
  - [Catalogs](#catalogs)
  - [Environment Types](#environment-types)
- [Project Configuration](#project-configuration)
  - [Project Structure](#project-structure)
  - [Identity and Access Control](#project-identity-and-access-control)
  - [Dev Box Pools](#dev-box-pools)
  - [Project Catalogs](#project-catalogs)
  - [Project Tagging](#project-tagging)
- [Resource Tagging](#resource-tagging)
- [Best Practices](#best-practices)
- [Default Settings](#default-configuration)
- [References](#references)

## Configuration Purpose

The devcenter.yaml file establishes a centralized developer workstation platform with role-specific configurations and appropriate access controls. It defines all aspects of the Azure Dev Box service, including the Dev Center resource, projects, environments, and access permissions.

## Core Settings

### Dev Center Properties

The foundation of the configuration is the Dev Center resource, which serves as the management plane for all Dev Box instances.

```yaml
name: "contoso-devexp2"
location: "eastus2"
```

| Property | Description | Best Practice |
|----------|-------------|---------------|
| `name` | Globally unique identifier for the Dev Center resource | Follow naming convention `[company]-[purpose]-[instance]` |
| `location` | Azure region where the Dev Center is deployed | Deploy to a region close to your development teams |

### Feature Flags

Dev Center behavior is controlled through several feature flags:

```yaml
catalogItemSyncEnableStatus: "Enabled"
microsoftHostedNetworkEnableStatus: "Enabled"
installAzureMonitorAgentEnableStatus: "Enabled"
```

| Flag | Description | Value | Best Practice |
|------|-------------|-------|---------------|
| `catalogItemSyncEnableStatus` | Controls automatic synchronization of catalog items | `Enabled` | Keep enabled for automated updates |
| `microsoftHostedNetworkEnableStatus` | Controls use of Microsoft-managed networking | `Enabled` | Use `Enabled` for simpler deployments, `Disabled` for enterprise network integration |
| `installAzureMonitorAgentEnableStatus` | Controls installation of Azure Monitor agent | `Enabled` | Keep enabled for operational visibility and security monitoring |

## Identity and Access Control

### Managed Identity Configuration

The Dev Center uses a managed identity to authenticate with other Azure services:

```yaml
identity:
  type: "SystemAssigned"
```

**SystemAssigned** identity means Azure automatically creates and manages the identity tied to the Dev Center resource lifecycle. This eliminates the need to manage service principal credentials.

### Role Assignments

The Dev Center requires specific permissions to operate:

```yaml
roleAssignments:
  devCenter:
    - id: "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
      name: "Owner"
    - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
      name: "Contributor"
    - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      name: "User Access Administrator"
```

| Role | ID | Purpose |
|------|------|---------|
| Owner | 8e3af657-a8ff-443c-a75c-2fe8c4bcb635 | Full access to manage resources |
| Contributor | b24988ac-6180-42a0-ab88-20f7382dd24c | Create/manage resources without granting access |
| User Access Administrator | 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9 | Manage user access to Azure resources |

> **Security Note**: In production environments, consider applying least-privilege principles by scoping these permissions more narrowly when possible.

### Organizational Roles

Organizational roles map Azure AD groups to Dev Box-specific roles:

```yaml
orgRoleTypes:
  - type: DevManager
    azureADGroupId: "8dae87fa-87b2-460b-b972-a4239fbd4a96"
    azureADGroupName: "Dev Manager"
    azureRBACRoles:
      - name: "DevCenter Project Admin"
        id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"
```

| Property | Description |
|----------|-------------|
| `type` | Dev Box organizational role type |
| `azureADGroupId` | ID of the Azure AD group to assign this role |
| `azureADGroupName` | Name of the Azure AD group |
| `azureRBACRoles` | RBAC roles assigned to this organizational role |

**Best Practice**: Use Azure AD groups rather than individual users to simplify access management.

## Content Management

### Catalogs

Catalogs define repositories that contain Dev Box customization resources:

```yaml
catalogs:
  - name: "customTasks"
    type: "gitHub"
    uri: "https://github.com/Evilazaro/DevExP-DevBox.git"
    branch: "main"
    path: ".configuration/devcenter/tasks"
```

| Property | Description |
|----------|-------------|
| `name` | Name of the catalog |
| `type` | Source repository type (gitHub, azureDevOps) |
| `uri` | Repository URL |
| `branch` | Git branch to use |
| `path` | Path within the repository |

**Best Practice**: Store Dev Box configurations in Git repositories to leverage version control and CI/CD workflows.

### Environment Types

Environment types define the deployment environments available to projects:

```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
```

| Property | Description |
|----------|-------------|
| `name` | Name of the environment type |
| `deploymentTargetId` | Target subscription ID (empty for default subscription) |

**Best Practice**: Create environment types that match your software development lifecycle stages (dev, test, staging, prod).

## Project Configuration

### Project Structure

Projects organize Dev Box resources for specific teams or workloads:

```yaml
projects:
  - name: "identityProvider"
    description: "Identity Provider project."
    # Additional project configuration follows
```

| Property | Description |
|----------|-------------|
| `name` | Name of the project |
| `description` | Description of the project purpose |

**Best Practice**: Create separate projects for different teams or workstreams to enable independent management and access control.

### Project Identity and Access Control

Each project has its own identity configuration:

```yaml
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
```

| Role | ID | Purpose |
|------|------|---------|
| Contributor | b24988ac-6180-42a0-ab88-20f7382dd24c | Manage resources within the project scope |
| Dev Box User | 45d50f46-0b78-4001-a660-4198cbe8cd05 | Create and use Dev Boxes |
| Deployment Environment User | 18e40d4e-8d2e-438d-97e1-9528336e149c | Use deployment environments |

**Best Practice**: Assign users to appropriate Azure AD groups and grant only the permissions needed for their role.

### Dev Box Pools

Dev Box pools define collections of developer workstations with specific configurations:

```yaml
pools:
  - name: "backend-engineer"
    imageDefinitionName: "identityProvider-backend-engineer"
  - name: "frontend-engineer"
    imageDefinitionName: "identityProvider-frontend-engineer"
```

| Property | Description |
|----------|-------------|
| `name` | Name of the Dev Box pool |
| `imageDefinitionName` | Reference to the image definition to use for Dev Boxes in this pool |

**Best Practice**: Create role-specific pools with tools and configurations tailored to different developer personas (backend, frontend, data, etc.).

### Project Catalogs

Projects can have their own catalogs for environment and image definitions:

```yaml
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
```

**Best Practice**: Store project-specific environment and image definitions in the same repository as the application code to maintain cohesion.

### Project Tagging

Projects have their own tag sets for resource governance:

```yaml
tags:
  environment: "dev"
  division: "Platforms"
  team: "DevExP"
  project: "DevExP-DevBox"
  costCenter: "IT"
  owner: "Contoso"
  resources: "Project"
```

## Resource Tagging

The Dev Center resource has top-level tags for governance and organization:

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

| Tag | Description |
|-----|-------------|
| `environment` | Deployment environment (dev, test, staging, prod) |
| `division` | Organizational division responsible for the resource |
| `team` | Team responsible for implementation |
| `project` | Project name for cost allocation |
| `costCenter` | Financial tracking designation |
| `owner` | Resource ownership |
| `resources` | Resource type identifier |

**Best Practice**: Apply consistent tags across all resources for improved governance, cost management, and operational visibility.

## Best Practices

### Security

- Use managed identities rather than service principals with credentials
- Follow the principle of least privilege when assigning roles
- Use Azure AD groups for role assignments instead of individual users
- Regularly audit role assignments and remove unnecessary permissions

### Organization

- Create separate projects for distinct teams or application workloads
- Use environment types that match your deployment pipeline stages
- Apply consistent naming conventions to all resources
- Use tags to support governance, cost allocation, and operations

### Configuration Management

- Store all configuration in Git repositories
- Use branch policies to control changes to configuration
- Implement CI/CD pipelines for configuration deployment
- Keep catalog synchronization enabled for automation

### Dev Box Design

- Create role-specific Dev Box images for different developer personas
- Standardize on common tools and configurations across teams
- Deploy Dev Box resources in regions close to development teams
- Enable monitoring for security and performance insights

## Default Settings

```yaml
# yaml-language-server: $schema=./devcenter.schema.json
#
# Microsoft Dev Box Accelerator: Dev Center Configuration
# ======================================
#
# Purpose: Defines the Dev Center resource and associated projects for Microsoft Dev Box Accelerator.
# This configuration establishes a centralized developer workstation platform with
# role-specific configurations and appropriate access controls.
#
# References:
# - Dev Center documentation: https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box
# - Azure RBAC roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

# Dev Center name - globally unique identifier for your Dev Center resource
# Best practice: Follow naming convention [company]-[purpose]-[instance] for clarity
name: "contoso-devexp2"

# Azure region where the Dev Center will be deployed
# Best practice: Deploy to a region close to your development team for optimal performance
location: "eastus2"

# Controls automatic synchronization of catalog items from repositories
# Enabled: Updates catalog items automatically when source repositories change
# Best practice: Keep enabled for automated updates to developer environments
catalogItemSyncEnableStatus: "Enabled"

# Controls whether Dev Boxes use Microsoft-managed networking
# Enabled: Simplifies network configuration by using Microsoft-managed networking
# Disabled: Use for connecting to custom VNets or on-premises resources
# Best practice: Use Enabled for simpler deployments, Disabled for enterprise network integration
microsoftHostedNetworkEnableStatus: "Enabled"

# Controls automatic installation of Azure Monitor agent on Dev Boxes
# Enables monitoring, security scanning, and compliance verification
# Best practice: Keep enabled for operational visibility and security monitoring
installAzureMonitorAgentEnableStatus: "Enabled"

# Identity configuration for the Dev Center resource
# Defines how the Dev Center authenticates and what permissions it has
identity:
  # Managed identity type for the Dev Center
  # SystemAssigned: Azure automatically manages the identity lifecycle
  # Best practice: Use SystemAssigned for simplified identity management
  type: "SystemAssigned"

  # Role assignments section - defines permissions for Dev Center operation
  roleAssignments:
    # Roles assigned to the Dev Center managed identity
    # These permissions allow the Dev Center to manage related resources
    devCenter:
      # Owner role grants full access to manage all resources
      # Required for Dev Center to manage projects and environments
      # Security note: Follow least-privilege principle in production environments
      - id: "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
        name: "Owner"
      
      # Contributor role allows creating/managing resources without granting access
      # Needed for Dev Center to deploy and configure Dev Box resources
      - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
        name: "Contributor"
      
      # User Access Administrator allows managing user access to resources
      # Required for Dev Center to assign appropriate permissions to projects
      - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
        name: "User Access Administrator"

    # Organizational role definitions - maps Azure AD groups to Dev Center roles
    # Best practice: Use Azure AD groups instead of individual users for simplified management
    orgRoleTypes:
      # Dev Manager role - for users who manage Dev Box deployments
      # These users can configure Dev Box definitions but typically don't use Dev Boxes
      - type: DevManager
        # Azure AD group ID for the Dev Manager role
        # All members of this group will receive Dev Manager permissions
        azureADGroupId: "8dae87fa-87b2-460b-b972-a4239fbd4a96"
        azureADGroupName: "Dev Manager"
        
        # RBAC roles assigned to Dev Managers
        azureRBACRoles:
          # DevCenter Project Admin role allows managing project settings
          - name: "DevCenter Project Admin"
            id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"

# Catalogs section - defines repositories containing Dev Box configurations
# These catalogs provide centralized, version-controlled configuration
# Best practice: Use Git repositories for configuration-as-code approach
catalogs:
  # Custom tasks catalog - contains scripts and actions for Dev Box customization
  # Tasks are executed during or after Dev Box provisioning to configure environments
  - name: "customTasks"
    type: "gitHub"
    uri: "https://github.com/Evilazaro/DevExP-DevBox.git"
    branch: "main"
    path: ".configuration/devcenter/tasks"

# Environment Types section - defines deployment environments for applications
# Each environment type represents a different stage in the development lifecycle
# Best practice: Create environments that match your SDLC stages (dev, test, prod)
environmentTypes:
  # Development environment - for development and initial testing
  - name: "dev"
    deploymentTargetId: ""  # Empty for default subscription target
  
  # Staging environment - for pre-production validation
  - name: "staging"
    deploymentTargetId: ""  # Empty for default subscription target

# Projects section - defines distinct projects within the Dev Center
# Each project has its own Dev Box configurations, catalogs, and permissions
# Best practice: Create separate projects for different teams or workstreams
projects:
  # Identity Provider project - for authentication/authorization services
  - name: "identityProvider"
    description: "Identity Provider project."

    # Project identity configuration - controls project-level security
    identity:
      type: SystemAssigned
      roleAssignments:
        # Role assignments for Identity Provider developers
        # Grants appropriate permissions to developers working on this project
        - azureADGroupId: "331f48d7-4a23-4ec4-b03a-4af29c9c6f34"
          azureADGroupName: "identityProvider Developers"
          azureRBACRoles:
            # Contributor role allows resource management within the project scope
            - name: "Contributor"
              id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
            
            # Dev Box User role allows creating and using Dev Boxes
            - name: "Dev Box User"
              id: "45d50f46-0b78-4001-a660-4198cbe8cd05"
            
            # Deployment Environment User allows using environments for deployments
            - name: "Deployment Environment User"
              id: "18e40d4e-8d2e-438d-97e1-9528336e149c"
    
    # Dev Box pools - collections of Dev Boxes with specific configurations
    # Best practice: Create role-specific pools with appropriate tools and settings
    pools:
      # Backend engineer pool - optimized for server-side development
      # Includes backend-specific tools, SDKs, and configurations
      - name: "backend-engineer"
        imageDefinitionName: "identityProvider-backend-engineer"
      
      # Frontend engineer pool - optimized for client-side development
      # Includes frontend frameworks, design tools, and browser testing tools
      - name: "frontend-engineer"
        imageDefinitionName: "identityProvider-frontend-engineer"

    # Project-specific environment types
    # Defines which deployment environments are available to the project
    environmentTypes:
      - name: "dev"
        deploymentTargetId: ""
      - name: "staging"
        deploymentTargetId: ""

    # Project-specific catalogs - repositories containing project configurations
    catalogs:
      # Environment definition catalog - contains IaC templates for environments
      # Best practice: Store environment definitions in the same repo as application code
      environmentDefinition:
        name: "environments"
        type: "gitHub"
        uri: "https://github.com/Evilazaro/identityProvider.git"
        branch: "main"
        path: ".configuration/devcenter/environments"
      
      # Image definition catalog - contains Dev Box image configurations
      # Defines the VM images and customizations for developer workstations
      imageDefinition:
        name: "imageDefinitions"
        type: "gitHub"
        uri: "https://github.com/Evilazaro/identityProvider.git"
        branch: "main"
        path: ".configuration/devcenter/imageDefinitions"

    # Project-specific tags for resource governance and organization
    # Best practice: Apply consistent tags for cost allocation and ownership
    tags:
      environment: "dev"           # Identifies the deployment environment
      division: "Platforms"        # Organizational division responsible for the project
      team: "DevExP"               # Team responsible for implementation
      project: "DevExP-DevBox"     # Project name for cost allocation
      costCenter: "IT"             # Financial tracking designation
      owner: "Contoso"             # Resource ownership
      resources: "Project"         # Resource type identifier

  # eShop project - for e-commerce application development
  - name: "eShop"
    description: "eShop project."

    # Project identity configuration - controls project-level security
    identity:
      type: SystemAssigned
      roleAssignments:
        # Role assignments for eShop developers
        # Grants appropriate permissions to developers working on this project
        - azureADGroupId: "19d12c65-509f-491d-bb38-49297e1c56a0"
          azureADGroupName: "eShop Developers"
          azureRBACRoles:
            # Contributor role allows resource management within the project scope
            - name: "Contributor"
              id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
            
            # Dev Box User role allows creating and using Dev Boxes
            - name: "Dev Box User"
              id: "45d50f46-0b78-4001-a660-4198cbe8cd05"
            
            # Deployment Environment User allows using environments for deployments
            - name: "Deployment Environment User"
              id: "18e40d4e-8d2e-438d-97e1-9528336e149c"

    # Dev Box pools - collections of Dev Boxes with specific configurations
    # Best practice: Create role-specific pools with appropriate tools and settings
    pools:
      # Backend engineer pool - optimized for server-side development
      # Includes backend-specific tools, SDKs, and configurations
      - name: "backend-engineer"
        imageDefinitionName: "eShop-backend-engineer"
      
      # Frontend engineer pool - optimized for client-side development
      # Includes frontend frameworks, design tools, and browser testing tools
      - name: "frontend-engineer"
        imageDefinitionName: "eShop-frontend-engineer"

    # Project-specific environment types
    # Defines which deployment environments are available to the project
    environmentTypes:
      - name: "dev"
        deploymentTargetId: ""
      - name: "staging"
        deploymentTargetId: ""

    # Project-specific catalogs - repositories containing project configurations
    catalogs:
      # Environment definition catalog - contains IaC templates for environments
      # Best practice: Store environment definitions in the same repo as application code
      environmentDefinition:
        name: "environments"
        type: "gitHub"
        uri: "https://github.com/Evilazaro/eShop.git"
        branch: "main"
        path: ".devcenter/environments"
      
      # Image definition catalog - contains Dev Box image configurations
      # Defines the VM images and customizations for developer workstations
      imageDefinition:
        name: "imageDefinitions"
        type: "gitHub"
        uri: "https://github.com/Evilazaro/eShop.git"
        branch: "main"
        path: ".devcenter/imageDefinitions"

    # Project-specific tags for resource governance and organization
    # Best practice: Apply consistent tags for cost allocation and ownership
    tags:
      environment: "dev"           # Identifies the deployment environment
      division: "Platforms"        # Organizational division responsible for the project
      team: "DevExP"               # Team responsible for implementation
      project: "DevExP-DevBox"     # Project name for cost allocation
      costCenter: "IT"             # Financial tracking designation
      owner: "Contoso"             # Resource ownership
      resources: "Project"         # Resource type identifier

# Top-level tags applied to the Dev Center resource
# Best practice: Implement consistent tagging across all Azure resources
# for improved governance, cost management, and operational tracking
tags:
  environment: "dev"           # Identifies the deployment environment
  division: "Platforms"        # Organizational division responsible for the resource
  team: "DevExP"               # Team responsible for implementation
  project: "DevExP-DevBox"     # Project name for cost allocation
  costCenter: "IT"             # Financial tracking designation
  owner: "Contoso"             # Resource ownership
  resources: "DevCenter"       # Resource type identifier
```

## References

- [Azure Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Azure RBAC Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure Tagging Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Azure Dev Box CLI Commands](https://learn.microsoft.com/en-us/cli/azure/devcenter?view=azure-cli-latest)
- [Azure Dev Box Accelerator GitHub](https://github.com/Evilazaro/DevExp-DevBox/)

---

*This documentation is part of the Azure Dev Box Accelerator project. For more information, visit the [GitHub Repository](https://github.com/Evilazaro/DevExp-DevBox/).*