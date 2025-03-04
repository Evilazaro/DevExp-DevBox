@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Project Description')
param projectDescription string

@description('Project Catalogs')
param projectCatalogs Catalog[]

@description('Project Environment Types')
param projectEnvironmentTypes ProjectEnvironmentType[]

type Project = {
  name: string
  description: string
  catalogs: array
  environmentTypes: ProjectEnvironmentType[]
}

type Catalog = {
  name: string
  type: CatalogType
  uri: string
  branch: string
  path: string
}

type CatalogType = 'gitHub' | 'adoGit'

type ProjectEnvironmentType = {
  name: string
  deploymentTargetId: string
}

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Dev Center Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  properties: {
    description: projectDescription
    devCenterId: devCenter.id
    displayName: name
  }
}

@description('Project Catalogs')
module catalogs 'projectCatalog.bicep' = [
  for catalog in projectCatalogs: {
    name: catalog.name
    params: {
      projectName: project.name
      catalogConfig: catalog
    }
  }
]

@description('Project Environment Types')
module environmentTypes 'projectEnvironmentType.bicep' = [
  for environmentType in projectEnvironmentTypes: {
    name: environmentType.name
    params: {
      projectName: project.name
      environmentConfig: environmentType
    }
  }
]
