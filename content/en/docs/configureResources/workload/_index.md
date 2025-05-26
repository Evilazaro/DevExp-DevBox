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
# Microsoft Dev Box Accelerator – devcenter.yaml Configuration Documentation

## 1. Overview

The devcenter.yaml file is the central configuration for the Microsoft Dev Box Accelerator. It defines the structure, governance, and operational parameters for a Dev Center resource in Azure, enabling organizations to provide secure, scalable, and role-specific developer workstations (Dev Boxes). This YAML file orchestrates Dev Box pools, access controls, environment types, project boundaries, and integration with version-controlled catalogs, ensuring a modular and decoupled approach to developer environment management.

**Key Roles of this YAML:**
- Centralizes Dev Center resource setup and policy.
- Defines projects, environments, and access controls.
- Integrates with Git-based catalogs for configuration-as-code.
- Enables automated, role-specific Dev Box provisioning.

---

## 2. Configurations

Below is a breakdown of each major section, its YAML representation, and an explanation of its purpose.

---

### 2.1. Dev Center Metadata

```yaml
name: "contoso-devcenter"
location: "eastus2"
```
- **name**: Globally unique identifier for the Dev Center resource.  
- **location**: Azure region for deployment; select a region close to your team for performance.

---

### 2.2. Global Settings

```yaml
catalogItemSyncEnableStatus: "Enabled"
microsoftHostedNetworkEnableStatus: "Enabled"
installAzureMonitorAgentEnableStatus: "Enabled"
```
- **catalogItemSyncEnableStatus**: Enables automatic sync of catalog items from source repositories.
- **microsoftHostedNetworkEnableStatus**: Uses Microsoft-managed networking for Dev Boxes (simplifies setup).
- **installAzureMonitorAgentEnableStatus**: Installs Azure Monitor agent for monitoring and compliance.

---

### 2.3. Identity and Access Control

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
- **type**: Managed identity type (`SystemAssigned` recommended for simplicity).
- **roleAssignments**: Assigns Azure RBAC roles to the Dev Center and organizational groups for secure operations.

---

### 2.4. Catalogs

```yaml
catalogs:
  - name: "customTasks"
    type: "gitHub"
    uri: "https://github.com/Evilazaro/DevExP-DevBox.git"
    branch: "main"
    path: ".configuration/devcenter/tasks"
```
- **catalogs**: List of Git-based repositories containing configuration scripts and templates for Dev Box customization.

---

### 2.5. Environment Types

```yaml
environmentTypes:
  - name: "dev"
    deploymentTargetId: ""
  - name: "staging"
    deploymentTargetId: ""
```
- **environmentTypes**: Defines deployment environments (e.g., dev, staging) for SDLC alignment.

---

### 2.6. Projects

Each project is a distinct logical unit with its own pools, catalogs, and access controls.

#### Example Project Structure

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

**Key Elements:**
- **identity**: Project-level identity and RBAC assignments.
- **pools**: Role-specific Dev Box pools (e.g., backend, frontend).
- **environmentTypes**: Environments available to the project.
- **catalogs**: Project-specific catalogs for IaC and image definitions.
- **tags**: Resource tags for governance and cost tracking.

---

### 2.7. Top-Level Tags

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

## 3. Examples and Use Cases

### Example 1: Adding a New Project

To onboard a new team, add a new entry under `projects` with its own identity, pools, catalogs, and tags.  
**Use Case:** Isolates access and configurations for different business units or applications.

### Example 2: Customizing Dev Box Pools

Define pools for different engineering roles (e.g., backend, frontend) with tailored image definitions.  
**Use Case:** Ensures developers get the right tools and environments for their responsibilities.

### Example 3: Integrating with GitHub Catalogs

Point `catalogs` to your organization's GitHub repositories for configuration-as-code.  
**Use Case:** Enables version-controlled, automated updates to Dev Box configurations and environments.

---

## 4. Tips

- **Use Azure AD Groups:** Assign permissions via groups, not individuals, for easier management.
- **Leverage Tags:** Apply consistent tags for cost tracking, ownership, and resource organization.
- **Keep Catalogs Modular:** Separate environment and image definitions for flexibility and reuse.
- **Automate Sync:** Enable catalog sync for up-to-date Dev Box provisioning.
- **Align Environments with SDLC:** Define `dev`, `staging`, and `prod` environments to match your release process.
- **Review RBAC Assignments:** Grant only necessary permissions to minimize risk.
- **Document Custom Pools:** Clearly describe the purpose and configuration of each Dev Box pool for maintainability.

---

**References:**  
- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)  
- [Azure RBAC Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)  

