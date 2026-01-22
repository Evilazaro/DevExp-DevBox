// Common variables for reuse
@description('Name of the DevCenter instance from configuration')
var devCenterName = config.name

@description('Principal ID of the DevCenter managed identity')
var devCenterPrincipalId = devcenter.identity.principalId

// Parameters with improved metadata and validation
@description('DevCenter configuration including identity and settings')
param config DevCenterConfig

@description('Array of catalog configurations for the DevCenter')
param catalogs Catalog[]

@description('Array of environment type configurations for the DevCenter')
param environmentTypes EnvironmentTypeConfig[]

@description('Log Analytics Workspace Id')
@minLength(1)
param logAnalyticsId string

@description('Secret Identifier')
@secure()
param secretIdentifier string

@description('Name of the resource group containing security resources')
param securityResourceGroupName string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

// Type definitions with proper naming conventions
@description('DevCenter configuration type')
type DevCenterConfig = {
  @description('Name of the DevCenter instance')
  name: string

  @description('Managed identity configuration for the DevCenter')
  identity: Identity

  @description('Status for catalog item sync feature')
  catalogItemSyncEnableStatus: Status

  @description('Status for Microsoft hosted network feature')
  microsoftHostedNetworkEnableStatus: Status

  @description('Status for Azure Monitor agent installation feature')
  installAzureMonitorAgentEnableStatus: Status

  @description('Tags to apply to the DevCenter')
  tags: Tags
}

@description('Tags type for resource tagging')
type Tags = {
  @description('Wildcard property for any tag key-value pairs')
  *: string
}

@description('Virtual network configuration type')
type VirtualNetwork = {
  @description('Name of the virtual network')
  name: string

  @description('Name of the resource group containing the virtual network')
  resourceGroupName: string

  @description('Type of virtual network')
  virtualNetworkType: string

  @description('Subnet configurations for the virtual network')
  subnets: VirtualNetworkSubnet[]
}

@description('Subnet configuration for virtual networks')
type VirtualNetworkSubnet = {
  @description('Name of the subnet')
  name: string

  @description('Address prefix for the subnet')
  addressPrefix: string
}

@description('Status type for feature toggles')
type Status = 'Enabled' | 'Disabled'

@description('Identity configuration type')
type Identity = {
  @description('Type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned,UserAssigned)')
  type: string

  @description('Role assignment configuration for the identity')
  roleAssignments: RoleAssignment
}

@description('Role assignment configuration')
type RoleAssignment = {
  @description('Role assignments scoped to the DevCenter')
  devCenter: AzureRBACRole[]

  @description('Organization-level role type configurations')
  orgRoleTypes: OrgRoleType[]
}

@description('Azure RBAC role definition')
type AzureRBACRole = {
  @description('The GUID of the role definition')
  id: string

  @description('Display name of the role')
  name: string

  @description('Scope at which the role should be assigned')
  scope: string
}

@description('Organization role type configuration')
type OrgRoleType = {
  @description('Type of organization role')
  type: string

  @description('Azure AD group object ID')
  azureADGroupId: string

  @description('Azure AD group display name')
  azureADGroupName: string

  @description('Array of Azure RBAC roles to assign')
  azureRBACRoles: AzureRBACRole[]
}

@description('Catalog configuration for DevCenter')
type Catalog = {
  @description('Name of the catalog')
  name: string

  @description('Type of repository (GitHub or Azure DevOps Git)')
  type: 'gitHub' | 'adoGit'

  @description('Visibility of the catalog')
  visibility: 'public' | 'private'

  @description('URI of the repository')
  uri: string

  @description('Branch to sync from')
  branch: string

  @description('Path within the repository to sync')
  path: string
}

@description('Environment type configuration')
type EnvironmentTypeConfig = {
  @description('Name of the environment type')
  name: string
}

// Main DevCenter resource
@description('Dev Center Resource')
resource devcenter 'Microsoft.DevCenter/devcenters@2025-10-01-preview' = {
  name: devCenterName
  location: location
  identity: {
    type: config.identity.type
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: config.catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: config.microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: config.installAzureMonitorAgentEnableStatus
    }
  }
  tags: config.tags
}

@description('Deployed Dev Center name')
output AZURE_DEV_CENTER_NAME string = devCenterName

// Monitoring configuration
@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${devCenterName}-diagnostics'
  scope: devcenter
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsId
  }
}

// RBAC and Identity Management
@description('Dev Center Identity Role Assignments')
module devCenterIdentityRoleAssignment '../../identity/devCenterRoleAssignment.bicep' = [
  for (role, i) in config.identity.roleAssignments.devCenter: {
    scope: subscription()
    params: {
      id: role.id
      principalId: devCenterPrincipalId
      scope: role.scope
    }
  }
]

@description('Dev Center Identity Role Assignments')
module devCenterIdentityRoleAssignmentRG '../../identity/devCenterRoleAssignmentRG.bicep' = [
  for (role, i) in config.identity.roleAssignments.devCenter: {
    scope: resourceGroup(securityResourceGroupName)
    params: {
      id: role.id
      principalId: devCenterPrincipalId
      scope: role.scope
    }
    dependsOn: [
      devCenterIdentityRoleAssignment
    ]
  }
]

@description('Dev Center Identity User Groups role assignments')
module devCenterIdentityUserGroupsRoleAssignment '../../identity/orgRoleAssignment.bicep' = [
  for (role, i) in config.identity.roleAssignments.orgRoleTypes: {
    scope: resourceGroup()
    params: {
      principalId: role.azureADGroupId
      roles: role.azureRBACRoles
    }
  }
]

// Catalog configuration
@description('Dev Center Catalogs')
module catalog 'catalog.bicep' = [
  for (catalog, i) in catalogs: {
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      catalogConfig: catalog
      secretIdentifier: secretIdentifier
    }
  }
]

// Environment types configuration
@description('Dev Center Environments')
module environment 'environmentType.bicep' = [
  for (environment, i) in environmentTypes: {
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      environmentConfig: environment
    }
  }
]
