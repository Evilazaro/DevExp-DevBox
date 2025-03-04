@description('Configuration')
param config DevCenterconfig

@description('Dev Center Catalogs')
param devCenterCatalogs Catalog[]

@description('Environment Types')
param devCenterEnvironmentTypes EnvironmentType[]

@description('Projects')
param devCenterProjects Project[]

@description('Log Analytics Workspace')
param logAnalyticsWorkspaceName string

@description('Subnets')
param subnets NetWorkConection[]

type DevCenterconfig = {
  name: string
  identity: Identity
  catalogItemSyncEnableStatus: Status
  microsoftHostedNetworkEnableStatus: Status
  installAzureMonitorAgentEnableStatus: Status
}

type Status = 'Enabled' | 'Disabled'

type Identity = {
  type: string
  roleAssignments: string[]
}

type Catalog = {
  name: string
  type: CatalogType
  uri: string
  branch: string
  path: string
}

type CatalogType = 'gitHub' | 'adoGit'

type EnvironmentType = {
  name: string
}

type ProjectEnvironmentType = {
  name: string
  deploymentTargetId: string
}

type Project = {
  name: string
  description: string
  environmentTypes: ProjectEnvironmentType[]
  catalogs: Catalog[]
}

type NetWorkConection = {
  name: string
  id: string
}

resource devcenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: '${config.name}-${uniqueString(resourceGroup().id)}'
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
}

resource logAnalytics  'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: devcenter.name
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
    workspaceId: logAnalytics.id
  }
}

@description('Dev Center Identity Role Assignments')
module roleAssignments '../identity/devCenterRoleAssignment.bicep' = [
  for role in config.identity.roleAssignments: {
    name: '${role}-roleAssignments'
    scope: subscription()
    params: {
      role: role
      principalId: devcenter.identity.principalId
    }
  }
]

@description('Network Connections')
module networkConnections 'core/networkConnection.bicep' = [
  for subnet in subnets: {
    name: '${config.name}-${subnet.name}'
    params: {
      name: subnet.name
      devcenterNae: devcenter.name
      subnetId: subnet.id
    }
  }
]

@description('Dev Center Catalogs')
module catalogs 'core/catalog.bicep' = [
  for catalog in devCenterCatalogs: {
    name: catalog.name
    params: {
      devCenterName: devcenter.name
      catalogConfig: catalog
    }
  }
]

// @description('Dev Center Compute Galleries')
// module computeGallery 'core/computeGallery.bicep' = {
//   name: 'devCenter-computeGallery'
//   params: {
//     computeGalleryId: compute.outputs.computeGalleryId
//     computeGalleryName: compute.outputs.computeGalleryName
//     devCenterName: devcenter.name
//   }
//   dependsOn: [
//     roleAssignments
//   ]
// }

@description('Dev Center Environments')
module environments 'core/environmentType.bicep' = [
  for environment in devCenterEnvironmentTypes: {
    name: environment.name
    params: {
      devCenterName: devcenter.name
      environmentConfig: environment
    }
  }
]

@description('Dev Center Projects')
module projects 'core/project.bicep' = [
  for project in devCenterProjects: {
    name: project.name
    params: {
      name: project.name
      projectDescription: project.name
      devCenterName: devcenter.name
      projectCatalogs: project.catalogs
      projectEnvironmentTypes: project.environmentTypes
    }
  }
]
