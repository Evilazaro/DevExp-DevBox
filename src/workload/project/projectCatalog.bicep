/*
  Project Catalog Module
  ----------------------
  This Bicep module creates a catalog resource for a Microsoft DevCenter project.
  Catalogs can be used for environment definitions or image definitions and support
  both GitHub and Azure DevOps Git repositories as source control providers.
  
  The module supports:
  - Public and private repository visibility
  - Scheduled sync type for catalog updates
  - GitHub and Azure DevOps Git source control
  - Environment and image definition catalog types

  Parameters:
  - projectName: The name of the existing DevCenter project to attach the catalog to
  - catalogConfig: Configuration object containing catalog settings (name, type, source control, visibility, uri, branch, path)
  - secretIdentifier: Secure string for Git repository authentication (required for private repositories)

  Outputs:
  - catalogName: The name of the created project catalog
  - catalogId: The resource ID of the created project catalog

  Usage Example:
  ```bicep
  module projectCatalog 'projectCatalog.bicep' = {
    name: 'deploy-project-catalog'
    params: {
      projectName: 'my-devcenter-project'
      catalogConfig: {
        name: 'my-catalog'
        type: 'environmentDefinition'
        sourceControl: 'gitHub'
        visibility: 'private'
        uri: 'https://github.com/org/repo.git'
        branch: 'main'
        path: '/environments'
      }
      secretIdentifier: keyVaultSecretUri
    }
  }
  ```
*/

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
