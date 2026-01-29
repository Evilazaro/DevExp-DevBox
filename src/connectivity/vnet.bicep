/*
  Virtual Network (VNet) Bicep Module
  ====================================

  Description:
  ------------
  This module provisions or references an Azure Virtual Network (VNet) for use in 
  Dev Box and related Azure infrastructure deployments. It provides flexible network 
  configuration options supporting both new and existing virtual networks.

  Features:
  ---------
  - Creates a new virtual network with configurable address spaces and subnets
  - References an existing virtual network when not creating a new one
  - Configures diagnostic settings to send logs and metrics to Log Analytics
  - Supports both 'Managed' and 'Unmanaged' network types
  - Applies consistent tagging across all resources

  Parameters:
  -----------
  - logAnalyticsId : string  - Resource ID of the Log Analytics workspace for diagnostics
  - location       : string  - Azure region for resource deployment
  - tags           : object  - Tags to apply to all resources (optional)
  - settings       : object  - Network configuration settings (see NetworkSettings type)

  Outputs:
  --------
  - AZURE_VIRTUAL_NETWORK : object - Contains name, resourceGroupName, virtualNetworkType, and subnets

  Dependencies:
  -------------
  - Log Analytics workspace (for diagnostic settings)
  - Existing resource group (when referencing existing VNet)

  Usage Example:
  --------------
  // Create a new virtual network
  module vnet 'vnet.bicep' = {
    name: 'vnetDeployment'
    params: {
      logAnalyticsId: '<log-analytics-resource-id>'
      location: 'eastus'
      tags: { environment: 'dev', project: 'devbox' }
      settings: {
        name: 'myVnet'
        virtualNetworkType: 'Unmanaged'
        create: true
        resourceGroupName: 'myResourceGroup'
        tags: {}
        addressPrefixes: ['10.0.0.0/16']
        subnets: [
          { name: 'default', properties: { addressPrefix: '10.0.0.0/24' } }
          { name: 'devbox', properties: { addressPrefix: '10.0.1.0/24' } }
        ]
      }
    }
  }

  // Reference an existing virtual network
  module existingVnet 'vnet.bicep' = {
    name: 'existingVnetDeployment'
    params: {
      logAnalyticsId: '<log-analytics-resource-id>'
      location: 'eastus'
      tags: {}
      settings: {
        name: 'existingVnetName'
        virtualNetworkType: 'Unmanaged'
        create: false
        resourceGroupName: 'existingResourceGroup'
        tags: {}
        addressPrefixes: []
        subnets: []
      }
    }
  }
*/

@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsId string

@description('Azure region for resource deployment')
param location string

@description('Tags to apply to all resources')
param tags object = {}

@description('Network configuration settings')
param settings object

@description('Network settings type definition with enhanced validation')
type NetworkSettings = {
  @description('Name of the virtual network')
  name: string

  @description('Type of network to create (vnet or existing)')
  virtualNetworkType: 'Unmanaged' | 'Managed'

  @description('Flag to create new or use existing virtual network')
  create: bool

  @description('Resource group name for existing virtual network')
  resourceGroupName: string

  @description('Resource tags')
  tags: object

  @description('Address space prefixes in CIDR notation')
  addressPrefixes: string[]

  @description('Subnet configurations')
  subnets: object[]
}

@description('Virtual Network resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-01-01' = if (settings.create && settings.virtualNetworkType == 'Unmanaged') {
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
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2025-01-01' existing = if (!settings.create && settings.virtualNetworkType == 'Unmanaged') {
  name: settings.name
  scope: resourceGroup(settings.resourceGroupName)
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

@description('Virtual network configuration object containing name, resource group, network type, and subnet information')
output AZURE_VIRTUAL_NETWORK object = (settings.create && settings.virtualNetworkType == 'Unmanaged')
  ? {
      name: virtualNetwork.?name ?? ''
      resourceGroupName: resourceGroup().name
      virtualNetworkType: settings.virtualNetworkType
      subnets: virtualNetwork.?properties.?subnets ?? []
    }
  : (!settings.create && settings.virtualNetworkType == 'Unmanaged')
      ? {
          name: existingVirtualNetwork.?name ?? ''
          resourceGroupName: resourceGroup().name
          virtualNetworkType: settings.virtualNetworkType
          subnets: existingVirtualNetwork.?properties.?subnets ?? []
        }
      : {
          name: ''
          resourceGroupName: ''
          virtualNetworkType: settings.virtualNetworkType
          subnets: []
        }
