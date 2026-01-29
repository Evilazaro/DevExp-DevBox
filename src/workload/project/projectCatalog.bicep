/*
  =============================================================================
  Project Catalog Module
  =============================================================================
  
  Description:
  ------------
  This Bicep module creates a catalog resource for a Microsoft DevCenter project.
  Catalogs provide reusable definitions that can be used to create environments
  or custom images within DevCenter projects.

  Features:
  ---------
  - Supports both GitHub and Azure DevOps Git repositories as source control
  - Configurable repository visibility (public/private)
  - Automatic scheduled synchronization of catalog contents
  - Two catalog types: environment definitions and image definitions
  - Secure authentication via Key Vault secret references for private repos

  Parameters:
  -----------
  | Name             | Type           | Description                                              |
  |------------------|----------------|----------------------------------------------------------|
  | projectName      | string         | Name of the existing DevCenter project                   |
  | catalogConfig    | Catalog        | Configuration object with catalog settings               |
  | secretIdentifier | secureString   | Key Vault secret URI for private repo authentication     |

  Catalog Configuration Properties:
  ---------------------------------
  | Property      | Type                                    | Description                        |
  |---------------|-----------------------------------------|------------------------------------|
  | name          | string                                  | Unique name for the catalog        |
  | type          | 'environmentDefinition'|'imageDefinition'| Type of definitions in catalog    |
  | sourceControl | 'gitHub' | 'adoGit'                     | Source control provider            |
  | visibility    | 'public' | 'private'                    | Repository visibility              |
  | uri           | string                                  | Repository clone URL               |
  | branch        | string                                  | Branch to sync from                |
  | path          | string                                  | Path within repo to sync           |

  Outputs:
  --------
  | Name        | Type   | Description                              |
  |-------------|--------|------------------------------------------|
  | catalogName | string | The name of the created project catalog  |
  | catalogId   | string | The resource ID of the created catalog   |

  Usage Example:
  --------------
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

  Notes:
  ------
  - For private repositories, ensure the secretIdentifier points to a valid
    Key Vault secret containing a PAT or appropriate authentication token
  - The sync type is set to 'Scheduled' for automatic catalog updates
  - API Version: 2025-10-01-preview

  =============================================================================
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
