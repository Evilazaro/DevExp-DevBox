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
