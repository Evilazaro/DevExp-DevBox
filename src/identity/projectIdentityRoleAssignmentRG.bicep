@description('The name of the DevCenter project')
param projectName string

@description('The principal (object) ID to assign roles to')
param principalId string

@description('Array of role definitions to assign to the principal')
param roles array

@description('The principal type for the role assignments')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
  'ForeignGroup'
  'Device'
])
param principalType string

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-04-01-preview' existing = {
  name: projectName
}

@description('Role assignments for the project')
resource roleAssignmentRG 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: if (role.scope == 'ResourceGroup') {
    name: guid(subscription().id, resourceGroup().id, project.id, principalId, role.id)
    scope: resourceGroup()
    properties: {
      principalId: principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', role.id)
      principalType: principalType
      description: contains(role, 'name')
        ? 'Role: ${role.name!} for project ${projectName}'
        : 'Role assignment for ${principalId}'
    }
  }
]

@description('Array of created role assignment IDs')
output roleAssignmentIds array = [
  for (role, i) in roles: {
    roleId: role.id
    roleName: contains(role, 'name') ? role.name! : role.id
    assignmentId: roleAssignmentRG[i].id
  }
]

@description('Project ID')
output projectId string = project.id
