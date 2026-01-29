// ============================================================================
// Module: catalog.bicep
// Description: Deploys a DevCenter catalog resource that syncs environment
//              definitions from a GitHub or Azure DevOps Git repository.
//              The catalog enables developers to discover and deploy pre-defined
//              environment templates from a centralized source control repository.
//
// Parameters:
//   - devCenterName: The name of the existing DevCenter instance to attach the catalog to.
//   - catalogConfig: Configuration object containing:
//       - name: Unique identifier for the catalog within the DevCenter.
//       - type: Repository type ('gitHub' or 'adoGit').
//       - visibility: Access level ('public' or 'private').
//       - uri: The clone URL of the Git repository.
//       - branch: The branch name to sync environment definitions from.
//       - path: The folder path within the repository containing definitions.
//   - secretIdentifier: Secure string containing the Key Vault secret identifier
//                       for authenticating to private repositories. Required only
//                       when visibility is 'private'.
//
// Resources:
//   - devCenter: Reference to an existing DevCenter instance (Microsoft.DevCenter/devcenters).
//   - catalog: DevCenter catalog resource (Microsoft.DevCenter/devcenters/catalogs)
//              configured for scheduled sync from GitHub or Azure DevOps Git.
//
// Outputs:
//   - AZURE_DEV_CENTER_CATALOG_NAME: The name of the created catalog.
//   - AZURE_DEV_CENTER_CATALOG_ID: The full Azure resource ID of the created catalog.
//   - AZURE_DEV_CENTER_CATALOG_TYPE: The type of catalog ('gitHub' or 'adoGit').
//
// Usage:
//   module catalog 'catalog.bicep' = {
//     name: 'catalogDeployment'
//     params: {
//       devCenterName: 'myDevCenter'
//       catalogConfig: {
//         name: 'my-catalog'
//         type: 'gitHub'
//         visibility: 'public'
//         uri: 'https://github.com/org/repo.git'
//         branch: 'main'
//         path: '/environments'
//       }
//       secretIdentifier: ''
//     }
//   }
// ============================================================================

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
resource devCenter 'Microsoft.DevCenter/devcenters@2025-10-01-preview' existing = {
  name: devCenterName
}

@description('DevCenter catalog configuration')
resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2025-10-01-preview' = {
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
