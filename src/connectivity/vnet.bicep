@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsId string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Tags to apply to all resources')
param tags object = {}

@description('Network configuration settings')
param settings NetworkSettings

@description('Network settings type definition with enhanced validation')
type NetworkSettings = {
  @description('Name of the virtual network')
  name: string

  @description('Type of network to create (vnet or existing)')
  virtualNetworkType: 'Unmanaged' | 'Managed'

  @description('Flag to create new or use existing virtual network')
  create: bool

  @description('Resource tags')
  tags: object

  @description('Address space prefixes in CIDR notation')
  addressPrefixes: string[]

  @description('Subnet configurations')
  subnets: array
}

@description('Virtual Network resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = if (settings.create && settings.virtualNetworkType == 'Unmanaged') {
  name: settings.name
  location: location
  tags: union(tags, settings.tags)
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

@description('Reference to existing Virtual Network')
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (!settings.create && settings.virtualNetworkType == 'Unmanaged') {
  name: settings.name
}

@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (settings.create && settings.virtualNetworkType == 'Unmanaged') {
  name: '${virtualNetwork.name}-diag'
  scope: virtualNetwork
  properties: {
    workspaceId: logAnalyticsId
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

@description('The resource ID of the Virtual Network')
output virtualNetworkId string = (settings.create && settings.virtualNetworkType == 'Unmanaged')
  ? virtualNetwork.id
  : (!settings.create && settings.virtualNetworkType == 'Unmanaged')
      ? existingVirtualNetwork.id
      : settings.virtualNetworkType

var subnetsOutput = (settings.create && settings.virtualNetworkType == 'Unmanaged')
  ? virtualNetwork.properties.subnets
  : (!settings.create && settings.virtualNetworkType == 'Unmanaged')
      ? existingVirtualNetwork.properties.subnets
      : [
          {
            name: settings.name
            id: settings.virtualNetworkType
          }
        ]

@description('The subnets of the deployed Virtual Network')
output AZURE_VIRTUAL_NETWORK_SUBNETS array = subnetsOutput
@description('The name of the Virtual Network')
output AZURE_VIRTUAL_NETWORK_NAME string = (settings.create && settings.virtualNetworkType == 'Unmanaged')
  ? virtualNetwork.name
  : (!settings.create && settings.virtualNetworkType == 'Unmanaged')
      ? existingVirtualNetwork.name
      : settings.virtualNetworkType
