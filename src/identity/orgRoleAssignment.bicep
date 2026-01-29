// ============================================================================
// Organization Role Assignment Module
// ============================================================================
// This Bicep module creates Azure RBAC role assignments at the resource group
// scope for a specified principal (user, group, service principal, etc.).
//
// Parameters:
//   - principalId: The object ID of the security principal to assign roles to
//   - roles: Array of role definitions containing role GUIDs and optional names
//   - principalType: Type of principal (User, Group, ServicePrincipal, etc.)
//
// Outputs:
//   - roleAssignmentIds: Array of created role assignment details (roleId, roleName, assignmentId)
//   - principalId: The principal ID that was assigned the roles
//
// Usage:
//   module roleAssignments 'orgRoleAssignment.bicep' = {
//     name: 'roleAssignments'
//     params: {
//       principalId: '<object-id>'
//       roles: [
//         { id: '<role-definition-guid>', name: 'Contributor' }
//         { id: 'acdd72a7-3385-48ef-bd42-f606fba81ae7', name: 'Reader' }
//       ]
//       principalType: 'Group'
//     }
//   }
//
// Notes:
//   - Role assignment names are generated using a deterministic GUID based on
//     subscription, resource group, principal, role, and principal type
//   - The module supports assigning multiple roles in a single deployment
//   - Role definitions must exist in Azure before assignment
// ============================================================================

@description('The principal (object) ID of the security group to assign roles to')
param principalId string

@description('Array of role definitions to assign to the principal')
param roles AzureRBACRole[]

@description('The principal type for the role assignments')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
  'ForeignGroup'
  'Device'
])
param principalType string = 'Group'

@description('Azure RBAC role definition for organization-level assignments')
type AzureRBACRole = {
  @description('The GUID of the role definition')
  id: string

  @description('Display name of the role')
  name: string?
}

@description('Role assignments for the security group')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: {
    name: guid(subscription().id, resourceGroup().id, principalId, role.id, role.?name ?? '', principalType)
    scope: resourceGroup()
    properties: {
      principalId: principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', role.id)
      principalType: principalType
      description: role.?name != null ? 'Role: ${role.name!}' : 'Role assignment for ${principalId}'
    }
  }
]

@description('Array of created role assignment IDs')
output roleAssignmentIds array = [
  for (role, i) in roles: {
    roleId: role.id
    roleName: role.?name ?? role.id
    assignmentId: roleAssignment[i].id
  }
]

@description('Principal ID assigned roles')
output principalId string = principalId
