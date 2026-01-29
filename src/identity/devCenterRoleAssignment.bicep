/*
  Module: devCenterRoleAssignment.bicep
  
  Description:
    Creates a role assignment at the subscription scope for a given identity.
    This module is used to assign Azure RBAC roles to service principals, users, or groups
    for Dev Center resources. The role assignment is conditionally created only when the
    scope parameter is set to 'Subscription'.
  
  Usage:
    module roleAssign 'devCenterRoleAssignment.bicep' = {
      name: 'devCenterRoleAssignment'
      params: {
        id: '<role-definition-guid>'
        principalId: '<principal-id>'
        principalType: 'ServicePrincipal'
        scope: 'Subscription'
      }
    }
  
  Parameters:
    - id: string (required)
        The role definition ID (GUID) to assign. Must be a valid Azure RBAC role definition ID.
    - principalId: string (required)
        The principal ID of the identity receiving the role assignment.
    - principalType: string (optional, default: 'ServicePrincipal')
        The type of principal. Allowed values: 'User', 'Group', 'ServicePrincipal'.
    - scope: string (required)
        The scope level for the role assignment. Currently only supports 'Subscription'.
  
  Outputs:
    - roleAssignmentId: string
        The resource ID of the created role assignment. Returns empty string if scope is not 'Subscription'.
    - scope: string
        The subscription ID where the role assignment was created.
  
  Resources:
    - Microsoft.Authorization/roleDefinitions@2022-05-01-preview (existing)
    - Microsoft.Authorization/roleAssignments@2022-04-01
*/

targetScope = 'subscription'

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
  scope: subscription()
}

var roleAssignmentId = guid(subscription().id, principalId, id)

@description('Role assignment resource')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (scope == 'Subscription') {
  name: roleAssignmentId
  scope: subscription()
  properties: {
    roleDefinitionId: roleDefinition.id
    principalType: principalType
    principalId: principalId
    description: 'Role assignment for ${principalId} with role ${roleDefinition.name}'
  }
}

@description('The ID of the created role assignment')
output roleAssignmentId string = (scope == 'Subscription') ? roleAssignment!.id : ''

@description('The scope of the role assignment')
output scope string = subscription().id
