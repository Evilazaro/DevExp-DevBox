@description('Project Name')
param projectName string

@description('Environment Configuration')
param environmentConfig ProjectEnvironmentType

type ProjectEnvironmentType = {
  name: string
  deploymentTargetId: string
}

var roles = [
  {
    id: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    properties: {}
  }
]

@description('Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' existing = {
  name: projectName
}

@description('Dev Center Environments')
resource environmentType 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = {
  name: environmentConfig.name
  parent: project
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: environmentConfig.name
    deploymentTargetId: empty(environmentConfig.deploymentTargetId)
      ? subscription().id
      : environmentConfig.deploymentTargetId
    status: 'Enabled'
    creatorRoleAssignment: {
      roles: toObject(roles, role => role.id, role => role.properties)
    }
  }
}

@description('The name of the environment type')
output environmentTypeName string = environmentType.name
