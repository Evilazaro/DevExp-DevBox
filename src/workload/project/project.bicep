@description('Name of the DevCenter instance')
param devCenterName string

@description('Name of the project to be created')
param name string

@description('Log Analytics Workspace Resource ID')
@minLength(1)
param logAnalyticsId string

@description('Description for the DevCenter project')
param projectDescription string

@description('Catalog configuration for the project')
param catalogs object[]

@description('Environment types to be associated with the project')
param projectEnvironmentTypes array

@description('DevBox pool configurations for the project')
param projectPools array

@description('Network connection name for the project')
param projectNetwork object

@description('Secret identifier for Git repository authentication')
@secure()
param secretIdentifier string

@description('Resource group name for security resources')
param securityResourceGroupName string

@description('Managed identity configuration for the project')
param identity Identity

@description('Tags to be applied to all resources')
param tags object = {}

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Identity configuration for the project')
type Identity = {
  @description('Type of managed identity (SystemAssigned or UserAssigned)')
  type: string

  @description('Role assignments for Azure AD groups')
  roleAssignments: RoleAssignment[]
}

@description('Azure RBAC role definition')
type AzureRBACRole = {
  @description('Role definition ID')
  id: string

  @description('Display name of the role')
  name: string
}

@description('Role assignment configuration')
type RoleAssignment = {
  @description('Azure AD group object ID')
  azureADGroupId: string

  @description('Azure AD group display name')
  azureADGroupName: string

  @description('Azure RBAC roles to assign')
  azureRBACRoles: AzureRBACRole[]
}

@description('Reference to existing DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2025-10-01-preview' existing = {
  name: devCenterName
}

@description('DevCenter Project resource')
resource project 'Microsoft.DevCenter/projects@2025-10-01-preview' = {
  name: name
  location: location
  identity: {
    type: identity.type
  }
  properties: {
    description: projectDescription
    devCenterId: devCenter.id
    displayName: name
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
        'ImageDefinition'
      ]
    }
  }
  tags: union(tags, {
    'ms-resource-usage': 'azure-cloud-devbox'
    project: name
  })
}

@description('Configure project identity role assignments')
module projectIdentity '../../identity/projectIdentityRoleAssignment.bicep' = [
  for (role, i) in identity.roleAssignments: {
    scope: resourceGroup()
    params: {
      projectName: project.name
      principalId: project.identity.principalId
      roles: role.azureRBACRoles
      principalType: 'ServicePrincipal'
    }
  }
]

@description('Configure project identity role assignments')
module projectIdentityRG '../../identity/projectIdentityRoleAssignmentRG.bicep' = [
  for (role, i) in identity.roleAssignments: {
    scope: resourceGroup(securityResourceGroupName)
    params: {
      projectName: project.name
      principalId: project.identity.principalId
      roles: role.azureRBACRoles
      principalType: 'ServicePrincipal'
    }
  }
]

@description('Add the AD Group to the DevCenter project')
module projectADGroup '../../identity/projectIdentityRoleAssignment.bicep' = [
  for (role, i) in identity.roleAssignments: {
    scope: resourceGroup()
    params: {
      projectName: project.name
      principalId: role.azureADGroupId
      principalType: 'Group'
      roles: role.azureRBACRoles
    }
  }
]

@description('Configure project catalogs')
module projectCatalogs 'projectCatalog.bicep' = [
  for (catalog, i) in catalogs: {
    scope: resourceGroup()
    params: {
      projectName: project.name
      catalogConfig: catalog
      secretIdentifier: secretIdentifier
    }
  }
]

@description('Configure project environment types')
module environmentTypes 'projectEnvironmentType.bicep' = [
  for (envType, i) in projectEnvironmentTypes: {
    scope: resourceGroup()
    params: {
      projectName: project.name
      environmentConfig: envType
      location: location
    }
  }
]

@description('Connectivity configuration for the project')
module connectivity '../../connectivity/connectivity.bicep' = {
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    projectNetwork: projectNetwork
    logAnalyticsId: logAnalyticsId
    location: location
  }
}

@description('Configure DevBox pools for the project')
module pools 'projectPool.bicep' = [
  for (pool, i) in projectPools: {
    scope: resourceGroup()
    params: {
      name: pool.name
      projectName: project.name
      catalogs: catalogs
      imageDefinitionName: pool.imageDefinitionName
      vmSku: pool.vmSku
      networkConnectionName: connectivity.outputs.networkConnectionName
      networkType: connectivity.outputs.networkType
      location: location
    }
  }
]

@description('The name of the deployed project')
output AZURE_PROJECT_NAME string = project.name

@description('The resource ID of the deployed project')
output AZURE_PROJECT_ID string = project.id
