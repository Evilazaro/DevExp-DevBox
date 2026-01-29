// ============================================================================
// Project Identity Role Assignment (Resource Group Scope)
// ============================================================================
// This Bicep module assigns Azure RBAC roles to a principal at the resource
// group scope for a DevCenter project. It supports multiple role assignments
// and filters roles based on the 'ResourceGroup' scope.
//
// Usage:
//   - Provide the DevCenter project name to reference
//   - Specify the principal ID (user, group, or service principal)
//   - Pass an array of roles with scope set to 'ResourceGroup'
//   - Specify the principal type for proper role assignment
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
