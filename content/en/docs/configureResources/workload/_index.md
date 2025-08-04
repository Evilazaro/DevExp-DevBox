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
weight: 8
---

# Dev Center Configuration Guide

## Overview

The `devcenter.yaml` file is the central configuration for the Microsoft Dev Box Accelerator. It defines the structure, governance, and operational parameters for a Dev Center resource in Azure, enabling organizations to provide secure, scalable, and role-specific developer workstations (Dev Boxes). This YAML orchestrates Dev Box pools, access controls, environment types, project boundaries, and integration with version-controlled catalogs, ensuring a modular and decoupled approach to developer environment management.

**Key Roles of this YAML:**
- Centralizes Dev Center resource setup and policy.
- Defines projects, environments, and access controls.
- Integrates with Git-based catalogs for configuration-as-code.
- Enables automated, role-specific Dev Box provisioning.

---

## Configuration Sections

Below is a breakdown of each major section, its YAML representation, and an explanation of its purpose.

---

### Dev Center Metadata

```yaml
name: "devexp-devcenter"
```
- **name**: Globally unique identifier for the Dev Center resource.

---

### Global Settings

```yaml
catalogItemSyncEnableStatus: "Enabled"
microsoftHostedNetworkEnableStatus: "Enabled"
installAzureMonitorAgentEnableStatus: "Enabled"
```
- **catalogItemSyncEnableStatus**: Enables automatic sync of catalog items from source repositories.
- **microsoftHostedNetworkEnableStatus**: Uses Microsoft-managed networking for Dev Boxes (simplifies setup).
- **installAzureMonitorAgentEnableStatus**: Installs Azure Monitor agent for monitoring and compliance.

---

### Identity and Access Control

```yaml
identity:
  type: "SystemAssigned"
  roleAssignments:
    devCenter:
      - id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
        name: "Contributor"
        scope: "Subscription"
      - id: "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
        name: "User Access Administrator"
        scope: "Subscription"
      - id: "4633458b-17de-408a-b874-0445c86b69e6"
        name: "Key Vault Secrets User"
        scope: "ResourceGroup"
      - id: "b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
        name: "Key Vault Secrets Officer"
        scope: "ResourceGroup"
    orgRoleTypes:
      - type: DevManager
        azureADGroupId: "5a1d1455-e771-4c19-aa03-fb4a08418f22"
        azureADGroupName: "Platform Engineering Team"
        azureRBACRoles:
          - name: "DevCenter Project Admin"
            id: "331c37c6-af14-46d9-b9f4-e1909e1b95a0"
            scope: ResourceGroup
```
- **type**: Managed identity type (`SystemAssigned` recommended for simplicity).
- **roleAssignments**: Assigns Azure RBAC roles to the Dev Center and organizational groups for secure operations. Includes both resource-level (`devCenter`) and organization-level (`orgRoleTypes`) assignments, with explicit scopes for each role.

---

### Catalogs

```yaml
catalogs:
  - name: "customTasks"
    type: gitHub
    uri: "https://github.com/Evilazaro/DevExp-DevBox.git"
    branch: "main"
    path: "/.configuration/devcenter/tasks"
```
- **catalogs**: List of Git-based repositories containing configuration scripts and templates for Dev Box customization. Use version-controlled repositories for configuration-as-code.

---

### Environment Types

```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
  - name: "UAT"
    deploymentTargetId: ""
```
- **environmentTypes**: Defines deployment environments (e.g., dev, staging, UAT) for SDLC alignment.

---

### Projects

Each project is a distinct logical unit with its own network, pools, catalogs, access controls, and tags.

#### Example Project Structure

```yaml
projects:
  - name: "identityProvider"
    description: "Identity Provider project."
    network:
      name: identityProvider
      create: true
      resourceGroupName: "identityProvider-connectivity-RG"
      virtualNetworkType: Managed
      addressPrefixes:
        - 10.0.0.0/16
      subnets:
        - name: identityProvider-subnet
          properties:
            addressPrefix: 10.0.1.0/24
      tags:
        environment: dev
        division: Platforms
        team: DevExP
        project: DevExP-DevBox
        costCenter: IT
        owner: Contoso
        resources: Network
    identity:
      type: SystemAssigned
      roleAssignments:
        - azureADGroupId: "67a29bc3-f25c-4599-9cb1-4da19507e8ee"
          azureADGroupName: "Identity Provider Engineers"
          azureRBACRoles:
            - name: "Contributor"
              id: "b24988ac-6180-42a0-ab88-20f7382dd24c"
              scope: Project
            - name: "Dev Box User"
              id: "45d50f46-0b78-4001-a660-4198cbe8cd05"
              scope: Project
            - name: "Deployment Environment User"
              id: "18e40d4e-8d2e-438d-97e1-9528336e149c"
              scope: Project
            - name: "Key Vault Secrets User"
              id: "4633458b-17de-408a-b874-0445c86b69e6"
              scope: ResourceGroup
            - id: "b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
              name: "Key Vault Secrets Officer"
              scope: ResourceGroup
    pools:
      - name: "backend-engineer"
        imageDefinitionName: "identityProvider-backend-engineer"
        vmSku: general_i_32c128gb512ssd_v2
      - name: "frontend-engineer"
        imageDefinitionName: "identityProvider-frontend-engineer"
        vmSku: general_i_16c64gb256ssd_v2
    environmentTypes:
      - name: "dev"
        deploymentTargetId: ""
      - name: "staging"
        deploymentTargetId: ""
    catalogs:
      environmentDefinition:
        name: "environments"
        type: gitHub
        uri: "https://github.com/Evilazaro/IdentityProvider.git"
        branch: "main"
        path: "/.configuration/devcenter/environments"
      imageDefinition:
        name: "imageDefinitions"
        type: gitHub
        uri: "https://github.com/Evilazaro/IdentityProvider.git"
        branch: "main"
        path: "/.configuration/devcenter/imageDefinitions"
    tags:
      environment: "dev"
      division: "Platforms"
      team: "DevExP"
      project: "DevExP-DevBox"
      costCenter: "IT"
      owner: "Contoso"
      resources: "Project"
```

**Key Elements:**
- **network**: Project-level network configuration, including VNet, subnets, and network tags. Use `Managed` for Azure-managed networking.
- **identity**: Project-level identity and RBAC assignments, with explicit scopes for each role.
- **pools**: Role-specific Dev Box pools (e.g., backend, frontend) with VM SKU specified for each pool.
- **environmentTypes**: Environments available to the project.
- **catalogs**: Project-specific catalogs for IaC and image definitions. Note the path differences for each project.
- **tags**: Resource tags for governance and cost tracking.

---

### Top-Level Tags

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
- **tags**: Applied to the Dev Center resource for consistent governance, cost allocation, and ownership tracking.

---

## Best Practices

- **Use Azure AD Groups:** Assign permissions via groups, not individuals, for easier management.
- **Leverage Tags:** Apply consistent tags for cost tracking, ownership, and resource organization.
- **Keep Catalogs Modular:** Separate environment and image definitions for flexibility and reuse.
- **Automate Sync:** Enable catalog sync for up-to-date Dev Box provisioning.
- **Align Environments with SDLC:** Define `dev`, `staging`, and `UAT` environments to match your release process.
- **Review RBAC Assignments:** Grant only necessary permissions to minimize risk, and use explicit scopes.
- **Document Custom Pools:** Clearly describe the purpose, configuration, and VM SKU of each Dev Box pool for maintainability.
- **Use the `network` section:** Define project-level network configuration for each project to control connectivity and isolation.

---

## References

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
- [Azure RBAC Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Dev Center Accelerator Docs](https://evilazaro.github.io/DevExp-DevBox/docs/configureresources/workload/)

---

**Tip:** To onboard a new team, add a new entry under `projects` with its own identity, pools, catalogs, and tags.  
**Use Case:** Isolates access and configurations for different business units or applications.

