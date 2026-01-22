targetScope = 'subscription'

@description('Flag indicating whether to create a new resource group or reference an existing one')
param create bool

@description('Name of the resource group')
param name string

@description('Azure region where the resource group will be located')
param location string

@description('Tags to apply to the resource group')
param tags object

@description('Resource group name for new or existing resource group')
resource newRg 'Microsoft.Resources/resourceGroups@2025-04-01' = if (create) {
  name: name
  location: location
  tags: tags
}

@description('Reference to existing resource group')
resource existingRg 'Microsoft.Resources/resourceGroups@2025-04-01' existing = if (!create) {
  name: name
}

@description('The name of the resource group - either newly created or existing')
output resourceGroupName string = create ? newRg.name : existingRg.name
