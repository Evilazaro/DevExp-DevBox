// ============================================================================
// Project Identity Role Assignment (Resource Group Scope)
// ============================================================================
// This Bicep module assigns Azure RBAC roles to a principal at the resource
// group scope for a DevCenter project. It supports multiple role assignments
// and filters roles based on the 'ResourceGroup' scope.
//
// Parameters:
//   - projectName: The name of the DevCenter project to reference
//   - principalId: The object ID of the principal (user, group, or service principal)
//   - roles: Array of AzureRBACRole objects defining the roles to assign
//   - principalType: The type of principal (User, Group, ServicePrincipal, ForeignGroup, Device)
//
// Outputs:
//   - roleAssignmentIds: Array of objects containing roleId, roleName, and assignmentId
//   - projectId: The resource ID of the referenced DevCenter project
//
// Usage:
//   module rgRoleAssignment 'projectIdentityRoleAssignmentRG.bicep' = {
//     name: 'projectRgRoleAssignment'
//     params: {
//       projectName: 'myProject'
//       principalId: '00000000-0000-0000-0000-000000000000'
//       roles: [
//         { id: 'acdd72a7-3385-48ef-bd42-f606fba81ae7', name: 'Reader', scope: 'ResourceGroup' }
//       ]
//       principalType: 'User'
//     }
//   }
//
// Notes:
//   - Only roles with scope set to 'ResourceGroup' will be assigned
//   - Role assignment names are generated using a deterministic GUID based on
//     subscription, resource group, project, principal, and role IDs
// ============================================================================

@description('The name of the DevCenter project')
param projectName string

@description('The principal (object) ID to assign roles to')
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
param principalType string

@description('Azure RBAC role definition')
type AzureRBACRole = {
  @description('The GUID of the role definition')
  id: string

  @description('Display name of the role')
  name: string?

  @description('Scope at which the role should be assigned')
  scope: string
}

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' existing = {
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
      description: role.?name != null
        ? 'Role: ${role.name!} for project ${projectName}'
        : 'Role assignment for ${principalId}'
    }
  }
]

@description('Array of created role assignment IDs')
output roleAssignmentIds array = [
  for (role, i) in roles: {
    roleId: role.id
    roleName: role.?name ?? role.id
    assignmentId: roleAssignmentRG[i].id
  }
]

@description('Project ID')
output projectId string = project.id
