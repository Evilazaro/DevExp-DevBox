// Common variables for reuse
var devCenterName = config.name
var devCenterPrincipalId = devcenter.identity.principalId

// Parameters with improved metadata and validation
@description('DevCenter configuration including identity and settings')
param config DevCenterConfig

@description('Dev Center Catalogs')
param catalogs array

@description('Environment Types')
param environmentTypes array

@description('Subnets')
param virtualNetworks VirtualNetwork[]

@description('Log Analytics Workspace Id')
@minLength(1)
param logAnalyticsId string

@description('Secret Identifier')
@secure()
param secretIdentifier string

// Type definitions with proper naming conventions
@description('DevCenter configuration type')
type DevCenterConfig = {
  name: string
  identity: Identity
  catalogItemSyncEnableStatus: Status
  microsoftHostedNetworkEnableStatus: Status
  installAzureMonitorAgentEnableStatus: Status
  tags: object
}

type VirtualNetwork = {
  name: string
  resourceGroupName: string
  virtualNetworkType: string
  subnets: object[]
}

@description('Status type for feature toggles')
type Status = 'Enabled' | 'Disabled'

@description('Identity configuration type')
type Identity = {
  type: string
  roleAssignments: RoleAssignment
}

@description('Role assignment configuration')
type RoleAssignment = {
  devCenter: AzureRBACRole[]
  orgRoleTypes: OrgRoleType[]
}

@description('Azure RBAC role definition')
type AzureRBACRole = {
  id: string
  name: string
}

@description('Organization role type configuration')
type OrgRoleType = {
  type: string
  azureADGroupId: string
  azureADGroupName: string
  azureRBACRoles: AzureRBACRole[]
}

// Main DevCenter resource
@description('Dev Center Resource')
resource devcenter 'Microsoft.DevCenter/devcenters@2025-02-01' = {
  name: devCenterName
  location: resourceGroup().location
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
    name: 'RBACDevCenter-${i}-${devCenterName}'
    scope: subscription()
    params: {
      id: role.id
      principalId: devCenterPrincipalId
    }
  }
]

@description('Dev Center Identity User Groups role assignments')
module devCenterIdentityUserGroupsRoleAssignment '../../identity/orgRoleAssignment.bicep' = [
  for (role, i) in config.identity.roleAssignments.orgRoleTypes: {
    name: 'RBACUserGroup-${i}-${devCenterName}'
    scope: subscription()
    params: {
      principalId: role.azureADGroupId
      roles: role.azureRBACRoles
    }
    dependsOn: [
      devCenterIdentityRoleAssignment
    ]
  }
]

// Network configuration
@description('Network Connections')
module networkConnection 'networkConnection.bicep' = [
  for (vnet, i) in virtualNetworks: if (vnet.virtualNetworkType == 'Unmanaged') {
    name: 'netConn-${vnet.name}-${uniqueString(vnet.name,resourceGroup().id)}'
    scope: resourceGroup()
    params: {
      name: 'nc-${vnet.subnets[0].name}'
      devCenterName: devCenterName
      subnetId: vnet.subnets[0].id
    }
  }
]

@description('Network Connections for Dev Center')
output networkConnections array = [
  for (vnet, i) in virtualNetworks: {
    name: networkConnection[i].outputs.networkConnectionName
    id: networkConnection[i].outputs.networkConnectionId
    virtualNetworkType: vnet.virtualNetworkType
  }
]

// Catalog configuration
@description('Dev Center Catalogs')
module catalog 'catalog.bicep' = [
  for (catalog, i) in catalogs: {
    name: 'catalog-${i}-${devCenterName}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      catalogConfig: catalog
      secretIdentifier: secretIdentifier
    }
    dependsOn: [
      devCenterIdentityRoleAssignment
    ]
  }
]

// Environment types configuration
@description('Dev Center Environments')
module environment 'environmentType.bicep' = [
  for (environment, i) in environmentTypes: {
    name: 'environmentType-${i}-${devCenterName}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      environmentConfig: environment
    }
  }
]

// Outputs with clear descriptions
@description('Deployed Dev Center name')
output AZURE_DEV_CENTER_NAME string = devCenterName

