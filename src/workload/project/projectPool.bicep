/*
  =====================================================================
  Project Pool Module
  =====================================================================
  
  Module:       projectPool.bicep
  Description:  Creates DevBox pools for a Microsoft DevCenter project
  API Version:  2025-10-01-preview
  
  =====================================================================
  OVERVIEW
  =====================================================================
  
  DevBox pools define the configuration for developer workstations that
  can be provisioned on-demand within a DevCenter project. Each pool
  specifies the VM size, image, network configuration, and access settings.
  
  This module iterates through a collection of catalogs and creates pool
  resources only for catalogs marked as 'imageDefinition' type.
  
  =====================================================================
  FEATURES
  =====================================================================
  
  - Dynamic pool creation based on catalog type filtering
  - Configurable VM SKU and image references from catalog definitions
  - Network connection support (Managed and Unmanaged VNet types)
  - Windows Client licensing pre-configured
  - Local administrator access enabled by default
  - Single Sign-On (SSO) enabled for seamless authentication
  - Managed virtual network regions auto-configured for Managed type
  
  =====================================================================
  PARAMETERS
  =====================================================================
  
  | Parameter             | Type       | Required | Description                                    |
  |-----------------------|------------|----------|------------------------------------------------|
  | name                  | string     | Yes      | Base name for pool resources ({name}-{i}-pool) |
  | location              | string     | No       | Azure region (defaults to resource group)      |
  | catalogs              | Catalog[]  | Yes      | Array of catalog definitions                   |
  | imageDefinitionName   | string     | Yes      | Image definition name within each catalog      |
  | networkConnectionName | string     | Yes      | Network connection to attach to pools          |
  | vmSku                 | string     | Yes      | VM SKU (e.g., 'general_i_8c32gb256ssd_v2')     |
  | networkType           | string     | Yes      | 'Managed' or 'Unmanaged' VNet type             |
  | projectName           | string     | Yes      | Parent DevCenter project resource name         |
  
  =====================================================================
  OUTPUTS
  =====================================================================
  
  | Output    | Type  | Description                                              |
  |-----------|-------|----------------------------------------------------------|
  | poolNames | array | Array of created pool names (null for non-image catalogs)|
  
  =====================================================================
  DEPENDENCIES
  =====================================================================
  
  - Existing DevCenter project resource (Microsoft.DevCenter/projects)
  - Catalogs must be synced with image definitions before pool creation
  
  =====================================================================
  EXAMPLE USAGE
  =====================================================================
  
  module pools 'projectPool.bicep' = {
    name: 'deploy-pools'
    params: {
      name: 'dev-pool'
      catalogs: catalogDefinitions
      imageDefinitionName: 'win11-vs2022'
      networkConnectionName: 'myNetworkConnection'
      vmSku: 'general_i_8c32gb256ssd_v2'
      networkType: 'Managed'
      projectName: 'myProject'
    }
  }
  
  =====================================================================
*/

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

@description('Reference to the existing DevCenter project')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' existing = {
  name: projectName
}

@description('DevBox Pool resources - creates pools for image definition catalogs')
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

@description('Array of created pool names')
output poolNames array = [for (catalog, i) in catalogs: catalog.type == 'imageDefinition' ? pool[i].name : null]
