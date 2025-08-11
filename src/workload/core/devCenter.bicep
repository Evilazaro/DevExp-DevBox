// Common variables for reuse
var devCenterName = config.name

// Parameters with improved metadata and validation
@description('DevCenter configuration including identity and settings')
param config DevCenterConfig

@description('Dev Center Catalogs')
param catalogs array

@description('Environment Types')
param environmentTypes array

@description('Log Analytics Workspace Id')
@minLength(1)
param logAnalyticsId string

@description('Secret Identifier')
@secure()
param secretIdentifier string

param securityResourceGroupName string

param dateTime string = utcNow('yyyyMMdd-HHmmss')

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
  scope: string
}

@description('Organization role type configuration')
type OrgRoleType = {
  type: string
  azureADGroupId: string
  azureADGroupName: string
  azureRBACRoles: AzureRBACRole[]
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${devCenterName}-MI'
  location: resourceGroup().location
}

resource federatedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  name: '${devCenterName}-federatedIdentity'
  parent: managedIdentity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: 'https://vstoken.dev.azure.com/023bf353-bd71-4028-ac46-0ab056a2ba87'
    subject: 'sc://contososa2/DevExp-DevBox/devboxazconnection'
  }
}

@description('Dev Center Identity Role Assignments')
module devCenterMIroleAssignment '../../identity/devCenterRoleAssignment.bicep' = [
  for (role, i) in config.identity.roleAssignments.devCenter: {
    name: 'RBACDevCenterSub-${i}-${managedIdentity.name}-${dateTime}'
    scope: subscription()
    params: {
      id: role.id
      principalId: managedIdentity.properties.principalId
      scope: role.scope
    }
  }
]

@description('Dev Center Identity Role Assignments')
module devCenterMIroleAssignmentRG '../../identity/devCenterRoleAssignmentRG.bicep' = [
  for (role, i) in config.identity.roleAssignments.devCenter: {
    name: 'RBACDevCenterRG-${i}-${managedIdentity.name}-${dateTime}'
    scope: resourceGroup(securityResourceGroupName)
    params: {
      id: role.id
      principalId: managedIdentity.properties.principalId
      scope: role.scope
    }
    dependsOn: [
      devCenterMIroleAssignment
    ]
  }
]

// Main DevCenter resource
@description('Dev Center Resource')
resource devcenter 'Microsoft.DevCenter/devcenters@2025-02-01' = {
  name: devCenterName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
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
  dependsOn: [
    managedIdentity
    devCenterMIroleAssignment
    devCenterMIroleAssignmentRG
  ]
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

@description('Dev Center Identity User Groups role assignments')
module devCenterIdentityUserGroupsRoleAssignment '../../identity/orgRoleAssignment.bicep' = [
  for (role, i) in config.identity.roleAssignments.orgRoleTypes: {
    name: 'RBACUserGroup-${i}-${devCenterName}-${dateTime}'
    scope: resourceGroup()
    params: {
      principalId: role.azureADGroupId
      roles: role.azureRBACRoles
    }
    dependsOn: [
      managedIdentity
      devCenterMIroleAssignment
      devCenterMIroleAssignmentRG
    ]
  }
]

// Catalog configuration
@description('Dev Center Catalogs')
module catalog 'catalog.bicep' = [
  for (catalog, i) in catalogs: {
    name: 'catalog-${i}-${devCenterName}-${dateTime}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      catalogConfig: catalog
      secretIdentifier: secretIdentifier
    }
    dependsOn: [
      devcenter
    ]
  }
]

// Environment types configuration
@description('Dev Center Environments')
module environment 'environmentType.bicep' = [
  for (environment, i) in environmentTypes: {
    name: 'environmentType-${i}-${devCenterName}-${dateTime}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenterName
      environmentConfig: environment
    }
    dependsOn: [
      devcenter
    ]
  }
]
