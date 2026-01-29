/*
  Resource Group Module
  ---------------------
  This Bicep module manages Azure Resource Groups at the subscription scope.
  It supports both creating new resource groups and referencing existing ones
  based on the 'create' parameter flag.

  Parameters:
    - create: bool - Flag to determine whether to create a new resource group (true) or reference an existing one (false)
    - name: string - The name of the resource group
    - location: string - Azure region for the resource group deployment
    - tags: object - Key-value pairs of tags to apply to the resource group

  Resources:
    - newRg: Creates a new resource group when create=true
    - existingRg: References an existing resource group when create=false

  Outputs:
    - resourceGroupName: string - The name of the resource group (newly created or existing)

  Usage:
    - Set create=true to provision a new resource group
    - Set create=false to reference an existing resource group by name

  Example:
    module rg 'resourceGroup.bicep' = {
      name: 'resourceGroupDeployment'
      params: {
        create: true
        name: 'my-resource-group'
        location: 'eastus'
        tags: {
          environment: 'dev'
        }
      }
    }
*/

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
