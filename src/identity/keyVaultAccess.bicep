/*
  Key Vault Access Bicep Module
  
  This module creates a role assignment that grants Key Vault Secrets User access
  to a specified service principal. The Key Vault Secrets User role allows reading
  secrets from Azure Key Vault.
  
  Parameters:
    - name: A unique name identifier used to generate a deterministic GUID for the role assignment.
    - principalId: The Azure AD principal ID (e.g., managed identity, service principal) 
                   that will be granted access to Key Vault secrets.
  
  Outputs:
    - roleAssignmentId: The resource ID of the created role assignment.
    - roleAssignmentName: The name (GUID) of the created role assignment.
  
  Role Definition:
    Key Vault Secrets User (4633458b-17de-408a-b874-0445c86b69e6)
    - Allows read access to secret contents
    - Does not allow management of Key Vault or secret metadata
  
  Usage:
    module keyVaultAccess 'keyVaultAccess.bicep' = {
      name: 'keyVaultAccessDeployment'
      params: {
        name: 'myRoleAssignment'
        principalId: '<service-principal-id>'
      }
    }
  
  Notes:
    - The role assignment name is generated using a GUID based on subscription, 
      resource group, and the provided name parameter for idempotency.
    - principalType is set to 'ServicePrincipal' which includes managed identities.
*/

@description('Name identifier for the role assignment')
param name string

@description('The principal ID of the identity to assign Key Vault access to')
param principalId string

@description('Role assignment resource that grants Key Vault Secrets User permissions to the specified principal')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, name, resourceGroup().id)
  properties: {
    principalId: principalId
    // Key Vault Secrets User role - allows reading secrets from Key Vault
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalType: 'ServicePrincipal'
  }
}

@description('The ID of the created role assignment')
output roleAssignmentId string = roleAssignment.id

@description('The name of the created role assignment')
output roleAssignmentName string = roleAssignment.name
