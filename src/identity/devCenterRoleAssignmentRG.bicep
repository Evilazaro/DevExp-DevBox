/*
  Module: devCenterRoleAssignmentRG.bicep
  
  Description: 
    Creates a role assignment at the resource group scope for a specified identity.
    This module is used to grant RBAC permissions to service principals, users, or groups
    within a resource group context, typically for Dev Center scenarios.
    
    The role assignment is only created when the scope parameter is set to 'ResourceGroup'.
    A unique GUID is generated for the assignment name based on subscription, resource group,
    principal ID, and role definition ID to ensure idempotency.
  
  Parameters:
    - id: string (required)
        The role definition ID (GUID) to assign. Must be a valid Azure built-in or custom role ID.
    - principalId: string (required)
        The principal ID (object ID) of the identity receiving the role assignment.
    - principalType: string (optional, default: 'ServicePrincipal')
        The type of principal. Allowed values: 'User', 'Group', 'ServicePrincipal'.
    - scope: string (required)
        The scope level for the assignment. Only 'ResourceGroup' creates the assignment;
        other values result in no assignment being created.
  
  Outputs:
    - roleAssignmentId: string
        The resource ID of the created role assignment, or empty string if not created.
    - scope: string
        The resource group ID where the assignment was created.
  
  Example Usage:
    module roleAssignment 'devCenterRoleAssignmentRG.bicep' = {
      name: 'devCenterRoleAssignment'
      scope: resourceGroup('myResourceGroup')
      params: {
        id: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor role
        principalId: '12345678-1234-1234-1234-123456789012'
        principalType: 'ServicePrincipal'
        scope: 'ResourceGroup'
      }
    }
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
