@description('Log Analytics ID')
param logAnalyticsId string

@description('Network Settings')
param settings NetworkSettings

type NetworkSettings = {
  name: string
  create: bool
  tags: object
  addressPrefixes: array
  subnets: array
}

@description('Virtual Network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = if (settings.create) {
  name: settings.name
  location: resourceGroup().location
  tags: settings.tags
  properties: {
    addressSpace: {
      addressPrefixes: settings.addressPrefixes
    }
    subnets: [
      for subnet in settings.subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.properties.addressPrefix
        }
      }
    ]
  }
}

@description('Existing Virtual Network')
resource existingVNetRg 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (!settings.create) {
  name: settings.name
  scope: resourceGroup()
}

@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (settings.create) {
  name: '${virtualNetwork.name}-diagnostic-settings'
  scope: virtualNetwork
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

@description('The ID of the Virtual Network')
output virtualNetworkId string = (settings.create) ? virtualNetwork.id : existingVNetRg.id

@description('The subnets of the Virtual Network')
output AZURE_VIRTUAL_NETWORK_SUBNETS array = [
  for (subnet, i) in settings.subnets: {
    id: (settings.create) ? virtualNetwork.properties.subnets[i].id : existingVNetRg.properties.subnets[i].id
    name: (settings.create) ? subnet.name : existingVNetRg.properties.subnets[i].name
  }
]

@description('The name of the Virtual Network')
output AZURE_VIRTUAL_NETWORK_NAME string = (settings.create) ? virtualNetwork.name : existingVNetRg.name
