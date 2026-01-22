@description('Name of the DevCenter project')
param projectName string

@description('Catalog configurations for the project')
param catalogConfig Catalog

@description('Secret identifier for Git repository authentication')
@secure()
param secretIdentifier string

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

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' existing = {
  name: projectName
}

@description('Environment Definition Catalog')
resource catalog 'Microsoft.DevCenter/projects/catalogs@2025-10-01-preview' = {
  name: catalogConfig.name
  parent: project
  properties: {
    syncType: 'Scheduled'
    gitHub: catalogConfig.sourceControl == 'gitHub'
      ? {
          uri: catalogConfig.uri
          branch: catalogConfig.branch
          path: catalogConfig.path
          secretIdentifier: (catalogConfig.visibility == 'private') ? secretIdentifier : null
        }
      : null
    adoGit: catalogConfig.sourceControl == 'adoGit'
      ? {
          uri: catalogConfig.uri
          branch: catalogConfig.branch
          path: catalogConfig.path
          secretIdentifier: (catalogConfig.visibility == 'private') ? secretIdentifier : null
        }
      : null
  }
}

@description('The name of the created project catalog')
output catalogName string = catalog.name

@description('The resource ID of the created project catalog')
output catalogId string = catalog.id
