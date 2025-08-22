@description('The name of the DevCenter instance')
param devCenterName string

@description('Configuration for the catalog to be created')
param catalogConfig Catalog

@description('Secret identifier for the Git repository authentication')
@secure()
param secretIdentifier string

@description('Catalog type definition')
type Catalog = {
  @description('Name of the catalog')
  name: string

  @description('Type of repository (GitHub or Azure DevOps Git)')
  type: CatalogType

   @description('Visibility of the catalog')
  visibility: 'public' | 'private'

  @description('URI of the repository')
  uri: string

  @description('Branch to sync from')
  branch: string

  @description('Path within the repository to sync')
  path: string
}

@description('Catalog type definition')
type CatalogType = 'gitHub' | 'adoGit'

@description('Reference to the existing DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2025-04-01-preview' existing = {
  name: devCenterName
}

@description('DevCenter catalog configuration')
resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2025-04-01-preview' = {
  name: catalogConfig.name
  parent: devCenter
  properties: union(
    {
      syncType: 'Scheduled'
    },
    catalogConfig.type == 'gitHub'
      ? {
          gitHub: {
            uri: catalogConfig.uri
            branch: catalogConfig.branch
            path: catalogConfig.path
            secretIdentifier: (catalogConfig.visibility == 'private') ? secretIdentifier : null
          }
        }
      : {
          adoGit: {
            uri: catalogConfig.uri
            branch: catalogConfig.branch
            path: catalogConfig.path
            secretIdentifier: (catalogConfig.visibility == 'private') ? secretIdentifier : null
          }
        }
  )
}

@description('The name of the created catalog')
output AZURE_DEV_CENTER_CATALOG_NAME string = catalog.name

@description('The ID of the created catalog')
output AZURE_DEV_CENTER_CATALOG_ID string = catalog.id

@description('The type of the created catalog')
output AZURE_DEV_CENTER_CATALOG_TYPE string = catalogConfig.type
