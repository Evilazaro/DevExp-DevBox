// ============================================================================
// Project Environment Type Bicep Module
// ============================================================================
// 
// Purpose:
//   Creates a Project Environment Type resource within an existing Azure DevCenter
//   project. Environment types define deployment targets and configure creator
//   role assignments for Azure Deployment Environments.
//
// Description:
//   This module provisions a project-scoped environment type that enables developers
//   to create deployment environments within a DevCenter project. The environment
//   type is configured with a SystemAssigned managed identity and grants the
//   Contributor role to environment creators by default.
//
// Parameters:
//   - projectName (string, required): 
//       The name of the existing DevCenter project to associate the environment type with.
//   
//   - location (string, optional): 
//       Azure region for resource deployment. Defaults to the resource group location.
//   
//   - environmentConfig (ProjectEnvironmentType, required): 
//       Configuration object containing:
//         - name: The name/identifier of the environment type (e.g., 'Development', 'Staging')
//         - deploymentTargetId: Resource ID of the target subscription for deployments
//
// Resources Created:
//   - Microsoft.DevCenter/projects/environmentTypes (API: 2025-10-01-preview):
//       A project environment type with:
//       - SystemAssigned managed identity for secure resource access
//       - Contributor role (b24988ac-6180-42a0-ab88-20f7382dd24c) for creators
//       - Enabled status for immediate availability
//
// Outputs:
//   - environmentTypeName (string): The name of the created environment type resource
//
// Dependencies:
//   - An existing DevCenter project (referenced by projectName parameter)
//   - Valid subscription ID for deployment target
//
// Usage Example:
//   module projectEnvType 'projectEnvironmentType.bicep' = {
//     name: 'deploy-env-type'
//     params: {
//       projectName: 'my-project'
//       location: 'eastus'
//       environmentConfig: {
//         name: 'Development'
//         deploymentTargetId: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
//       }
//     }
//   }
//
// Notes:
//   - The environment type uses the current subscription as the deployment target
//   - Creator role assignment enables developers to manage resources in their environments
//   - The managed identity allows the environment type to perform Azure operations
//
// ============================================================================

@description('Project Name')
param projectName string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Environment Configuration')
param environmentConfig ProjectEnvironmentType

type ProjectEnvironmentType = {
  @description('Name of the environment type')
  name: string

  @description('Resource ID of the subscription for deployment target')
  deploymentTargetId: string
}

@description('Default role assignments for environment type creators - Contributor role')
var roles = [
  {
    id: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    properties: {}
  }
]

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' existing = {
  name: projectName
}

@description('Project Environment Type resource for deployment environments')
resource environmentType 'Microsoft.DevCenter/projects/environmentTypes@2025-10-01-preview' = {
  name: environmentConfig.name
  location: location
  parent: project
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: environmentConfig.name
    deploymentTargetId: subscription().id
    status: 'Enabled'
    creatorRoleAssignment: {
      roles: toObject(roles, role => role.id, role => role.properties)
    }
  }
}

@description('The name of the environment type')
output environmentTypeName string = environmentType.name
