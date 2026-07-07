@description('Name identifier for the role assignment')
param name string

@description('The principal ID of the identity to assign Key Vault access to')
param principalId string

@description('Role assignment resource')
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
