@description('Pool Name')
param name string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('The name of the catalog to use for the pool')
param catalogs Catalog[]

@description('The name of the dev box definition to use for the pool')
param imageDefinitionName string

@description('The name of the network connection to use for the pool')
param networkConnectionName string

@description('The SKU of the virtual machine to use for the pool')
param vmSku string

@description('Network type for resource deployment')
param networkType string

@description('The name of the project to which the pool belongs')
param projectName string

@description('Catalog definition')
type Catalog = {
  @description('Name of the catalog')
  name: string

  @description('Type of catalog (environment or image)')
  type: 'environmentDefinition' | 'imageDefinition'

  @description('Source control type')
  sourceControl: 'gitHub' | 'adoGit'

  @description('Visibility of the catalog')
  visibility: 'public' | 'private'

  @description('URI of the repository')
  uri: string

  @description('Branch to sync from')
  branch: string

  @description('Path within the repository to sync')
  path: string
}

@description('Project')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' existing = {
  name: projectName
}

@description('Dev Box Pool resource')
resource pool 'Microsoft.DevCenter/projects/pools@2025-10-01-preview' = [
  for (catalog, i) in catalogs: if (catalog.type == 'imageDefinition') {
    name: '${name}-${i}-pool'
    location: location
    parent: project
    properties: {
      devBoxDefinitionType: 'Value'
      devBoxDefinitionName: '~Catalog~${catalog.name}~${imageDefinitionName}'
      devBoxDefinition: {
        imageReference: {
          id: '${project.id}/images/~Catalog~${catalog.name}~${imageDefinitionName}'
        }
        sku: {
          name: vmSku
        }
      }
      networkConnectionName: networkConnectionName
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      singleSignOnStatus: 'Enabled'
      displayName: name
      virtualNetworkType: networkType
      managedVirtualNetworkRegions: (networkType == 'Managed') ? [location] : []
    }
  }
]
