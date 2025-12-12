@description('The name of the Log Analytics Workspace')
@minLength(4)
@maxLength(49)
param name string

@description('The Azure region for the Log Analytics Workspace')
param location string = resourceGroup().location

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

// Naming convention variable using recommended pattern - ensure total length doesn't exceed 63 characters
var uniqueSuffix = uniqueString(resourceGroup().id)
var maxNameLength = 63 - length(uniqueSuffix) - 1 // 1 for the dash
var truncatedName = length(name) > maxNameLength ? take(name, maxNameLength) : name
var workspaceName = '${truncatedName}-${uniqueSuffix}'

@description('Log Analytics Workspace')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
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
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics Workspace')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name
