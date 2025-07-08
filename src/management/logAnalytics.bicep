@description('The name of the Log Analytics Workspace')
@minLength(3)
@maxLength(24)
param name string

@description('The Azure region for the Log Analytics Workspace')
param location string = resourceGroup().location

@description('The number of days to retain data in the workspace')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Tags to apply to the Log Analytics Workspace')
param tags object = {}

@description('The SKU of the Log Analytics Workspace')
@allowed([
  'PerGB2018'
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

// Naming convention variable using recommended pattern
var workspaceName = '${name}-${uniqueString(resourceGroup().id)}'

@description('Log Analytics Workspace')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: workspaceName
  location: location
  tags: union(tags, {
    resourceType: 'Log Analytics'
    module: 'monitoring'
  })
  properties: {
    sku: {
      name: sku
    }
  }
}

@description('Log Analytics Solutions')
resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'AzureActivity(${workspaceName})'
  location: location
  tags: tags
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: 'AzureActivity(${workspaceName})'
    product: 'OMSGallery/AzureActivity'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}

@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${workspaceName}-diag'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
  }
}

@description('The resource ID of the Log Analytics Workspace')
output workspaceId string = logAnalyticsWorkspace.id

@description('The resource ID of the Log Analytics Workspace')
output logAnalyticsId string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics Workspace')
output logAnalyticsName string = logAnalyticsWorkspace.name
