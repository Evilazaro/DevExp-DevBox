// ============================================================================
// Project Environment Type Bicep Module
// ============================================================================
// This module creates a Project Environment Type resource within an existing
// DevCenter project. Environment types define deployment targets and creator
// role assignments for deployment environments.
//
// Parameters:
//   - projectName: The name of the existing DevCenter project to associate with
//   - location: Azure region for resource deployment (defaults to resource group location)
//   - environmentConfig: Configuration object containing environment type name and deployment target
//
// Resources Created:
//   - Microsoft.DevCenter/projects/environmentTypes: A project environment type with
//     SystemAssigned managed identity and Contributor role assignment for creators
//
// Outputs:
//   - environmentTypeName: The name of the created environment type
//
// Usage Example:
//   module projectEnvType 'projectEnvironmentType.bicep' = {
//     name: 'deploy-env-type'
//     params: {
//       projectName: 'my-project'
//       environmentConfig: {
//         name: 'Development'
//         deploymentTargetId: '/subscriptions/xxx-xxx-xxx'
//       }
//     }
//   }
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
