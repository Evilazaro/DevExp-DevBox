@description('Name of the DevCenter project')
param projectName string

@description('Catalog configurations for the project')
param catalogConfig ProjectCatalog

@description('Secret identifier for Git repository authentication')
@secure()
param secretIdentifier string

@description('Catalog definition')
type Catalog = {
  @description('Name of the catalog')
  name: string

  @description('Type of repository (GitHub or Azure DevOps Git)')
  type: CatalogType

  @description('URI of the repository')
  uri: string

  @description('Branch to sync from')
  branch: string

  @description('Path within the repository to sync')
  path: string
}

@description('Project catalog configuration')
type ProjectCatalog = {
  @description('Environment definition catalog configuration')
  environmentDefinition: Catalog

  @description('Image definition catalog configuration')
  imageDefinition: Catalog
}

@description('Supported catalog repository types')
type CatalogType = string

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-02-01' existing = {
  name: projectName
}

@description('Environment Definition Catalog')
resource environmentDefinitionCatalog 'Microsoft.DevCenter/projects/catalogs@2025-02-01' = {
  name: catalogConfig.environmentDefinition.name
  parent: project
  properties: {
    syncType: 'Scheduled'
    gitHub: catalogConfig.environmentDefinition.type == 'gitHub'
      ? {
          uri: catalogConfig.environmentDefinition.uri
          branch: catalogConfig.environmentDefinition.branch
          path: catalogConfig.environmentDefinition.path
          secretIdentifier: secretIdentifier
        }
      : null
    adoGit: catalogConfig.environmentDefinition.type == 'adoGit'
      ? {
          uri: catalogConfig.environmentDefinition.uri
          branch: catalogConfig.environmentDefinition.branch
          path: catalogConfig.environmentDefinition.path
          secretIdentifier: secretIdentifier
        }
      : null
  }
}

@description('Image Definition Catalog')
resource imageDefinitionCatalog 'Microsoft.DevCenter/projects/catalogs@2025-02-01' = {
  name: catalogConfig.imageDefinition.name
  parent: project
  properties: {
    syncType: 'Scheduled'
    gitHub: catalogConfig.imageDefinition.type == 'gitHub'
      ? {
          uri: catalogConfig.imageDefinition.uri
          branch: catalogConfig.imageDefinition.branch
          path: catalogConfig.imageDefinition.path
          secretIdentifier: secretIdentifier
        }
      : null
    adoGit: catalogConfig.imageDefinition.type == 'adoGit'
      ? {
          uri: catalogConfig.imageDefinition.uri
          branch: catalogConfig.imageDefinition.branch
          path: catalogConfig.imageDefinition.path
          secretIdentifier: secretIdentifier
        }
      : null
  }
}

@description('The name of the environment definition catalog')
output environmentDefinitionCatalogName string = environmentDefinitionCatalog.name

@description('The ID of the environment definition catalog')
output environmentDefinitionCatalogId string = environmentDefinitionCatalog.id

@description('The name of the image definition catalog')
output imageDefinitionCatalogName string = imageDefinitionCatalog.name

@description('The ID of the image definition catalog')
output imageDefinitionCatalogId string = imageDefinitionCatalog.id
