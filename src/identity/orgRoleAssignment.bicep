@description('The principal (object) ID of the security group to assign roles to')
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
param principalType string = 'Group'

@description('Role assignments for the security group')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, principalId, role.id, role.name, principalType)
    scope: resourceGroup()
    properties: {
      principalId: principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', role.id)
      principalType: principalType
      description: contains(role, 'name') ? 'Role: ${role.name!}' : 'Role assignment for ${principalId}'
    }
  }
]

@description('Array of created role assignment IDs')
output roleAssignmentIds array = [
  for (role, i) in roles: {
    roleId: role.id
    roleName: contains(role, 'name') ? role.name! : role.id
    assignmentId: roleAssignment[i].id
  }
]

@description('Principal ID assigned roles')
output principalId string = principalId
