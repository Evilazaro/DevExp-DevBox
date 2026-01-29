/*
  Module: devCenterRoleAssignmentRG.bicep
  Description: Creates a role assignment at the resource group scope for a specified identity.
               This module is used to grant RBAC permissions to service principals, users, or groups
               within a resource group context, typically for Dev Center scenarios.
  
  Parameters:
    - id: The role definition ID (GUID) to assign
    - principalId: The principal ID of the identity receiving the role
    - principalType: The type of principal (User, Group, or ServicePrincipal)
    - scope: The scope level for the assignment (only 'ResourceGroup' creates the assignment)
  
  Outputs:
    - roleAssignmentId: The resource ID of the created role assignment
    - scope: The resource group ID where the assignment was created
*/

targetScope = 'resourceGroup'

@description('The role definition ID to assign to the identity')
param id string

@description('The principal ID of the identity to assign the role to')
param principalId string

@description('The principal type of the identity to assign the role to')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string = 'ServicePrincipal'

@description('The scope at which the role assignment should be created')
param scope string

@description('Existing role definition reference')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: id
  scope: resourceGroup()
}

@description('Role assignment resource')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (scope == 'ResourceGroup') {
  name: guid(subscription().id, resourceGroup().id, principalId, id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: roleDefinition.id
    principalType: principalType
    principalId: principalId
    description: 'Role assignment for ${principalId} with role ${roleDefinition.name}'
  }
}

@description('The ID of the created role assignment')
output roleAssignmentId string = (scope == 'ResourceGroup') ? roleAssignment!.id : ''

@description('The scope of the role assignment')
output scope string = resourceGroup().id
