@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string = 'dev'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param identityProviderExists bool = false

@description('Id of the user or app to assign application roles')
param principalId string = ''

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

// Organize resources in a resource group
module resources 'resources.bicep' = {
  scope: resourceGroup()
  name: 'resources'
  params: {
    location: location
    tags: tags
    principalId: principalId
    identityProviderExists: identityProviderExists
  }
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.AZURE_CONTAINER_REGISTRY_ENDPOINT
output AZURE_RESOURCE_IDENTITY_PROVIDER_ID string = resources.outputs.AZURE_RESOURCE_IDENTITY_PROVIDER_ID
