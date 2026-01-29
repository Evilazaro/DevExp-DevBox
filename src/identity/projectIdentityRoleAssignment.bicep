/*
  Module: projectIdentityRoleAssignment.bicep
  
  Description: 
    Assigns Azure RBAC roles to a principal (user, group, or service principal) 
    for a DevCenter project. This module creates role assignments scoped to the 
    project level for each role definition provided where the scope is 'Project'.
  
  Usage:
    This module is designed to be called from a parent deployment to grant 
    identity access to DevCenter project resources. Role assignments are created
    using a deterministic GUID based on subscription, resource group, project,
    principal, and role to ensure idempotent deployments.
  
  Parameters:
    - projectName: Name of the existing DevCenter project to assign roles on
    - principalId: The object ID (GUID) of the principal to assign roles to
    - roles: Array of AzureRBACRole objects containing:
        - id: The GUID of the role definition (e.g., 'b24988ac-6180-42a0-ab88-20f7382dd24c' for Contributor)
        - name: (Optional) Display name of the role for documentation purposes
        - scope: Scope at which the role should be assigned (only 'Project' scope is processed)
    - principalType: Type of principal being assigned (User, Group, ServicePrincipal, ForeignGroup, Device)
  
  Outputs:
    - roleAssignmentIds: Array of objects containing roleId, roleName, and assignmentId for each created assignment
    - projectId: The full resource ID of the DevCenter project
  
  Example:
    module projectRoleAssignment 'projectIdentityRoleAssignment.bicep' = {
      name: 'assign-project-roles'
      params: {
        projectName: 'my-devcenter-project'
        principalId: '00000000-0000-0000-0000-000000000000'
        principalType: 'ServicePrincipal'
        roles: [
          { id: 'b24988ac-6180-42a0-ab88-20f7382dd24c', name: 'Contributor', scope: 'Project' }
        ]
      }
    }
*/

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
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roles: if (role.scope == 'Project') {
    name: guid(subscription().id, resourceGroup().id, project.id, principalId, role.id)
    scope: project
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
    assignmentId: roleAssignment[i].id
  }
]

@description('Project ID')
output projectId string = project.id
