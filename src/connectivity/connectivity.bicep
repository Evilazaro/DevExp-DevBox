// ============================================================================
// Module: connectivity.bicep
// Description: Orchestrates network connectivity resources for DevCenter projects.
//              This module provisions virtual networks, network connections, and
//              resource groups based on the project network configuration.
// 
// Dependencies:
//   - resourceGroup.bicep: Creates or references the resource group for network resources
//   - vnet.bicep: Provisions or references the virtual network and subnets
//   - networkConnection.bicep: Creates the DevCenter network connection attachment
// 
// Usage:
//   This module is typically called from a parent deployment to set up network
//   connectivity for DevCenter projects. It supports both creating new network
//   infrastructure and connecting to existing virtual networks.
// 
// Outputs:
//   - networkConnectionName: The name of the network connection for DevCenter attachment
//   - networkType: The type of virtual network (Managed or Unmanaged)
// ============================================================================

// =========================== Parameters ===========================

@description('Name of the DevCenter instance that will be connected to the virtual network')
param devCenterName string

@description('Project network configuration object containing: name, virtualNetworkType, create flag, resourceGroupName, addressPrefixes, subnets, and tags')
param projectNetwork object

@description('Log Analytics workspace resource ID for enabling diagnostic settings on network resources')
param logAnalyticsId string

@description('Azure region where network resources will be deployed')
param location string

// =========================== Variables ============================

@description('Determines if network connectivity resources should be created. Returns true when virtualNetworkType is Unmanaged, regardless of whether creating new or using existing network.')
var networkConnectivityCreate = (projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged') || (!projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged')

@description('Resource Group module for network connectivity resources')
module resourceGroupModule 'resourceGroup.bicep' = {
  scope: subscription()
  params: {
    name: projectNetwork.resourceGroupName
    location: location
    tags: projectNetwork.tags
    create: networkConnectivityCreate
  }
}

@description('Resource group name - uses project network resource group if creating new connectivity, otherwise uses current resource group')
var rgName = (networkConnectivityCreate) ? projectNetwork.resourceGroupName : resourceGroup().name

@description('Virtual Network module for project connectivity')
module virtualNetwork 'vnet.bicep' = {
  scope: resourceGroup(rgName)
  params: {
    logAnalyticsId: logAnalyticsId
    location: location
    settings: {
      name: projectNetwork.name
      virtualNetworkType: projectNetwork.virtualNetworkType
      create: projectNetwork.create
      resourceGroupName: projectNetwork.resourceGroupName
      addressPrefixes: projectNetwork.addressPrefixes
      subnets: projectNetwork.subnets
      tags: projectNetwork.tags
    }
  }
  dependsOn: [
    resourceGroupModule
  ]
}

@description('Network Connection resource for DevCenter - creates attachment between DevCenter and virtual network')
module networkConnection './networkConnection.bicep' = if (networkConnectivityCreate) {
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: 'netconn-${virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.name}'
    subnetId: virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.subnets[0].id
  }
}

@description('The name of the network connection - either newly created or from existing project network configuration')
output networkConnectionName string = networkConnectivityCreate
  ? networkConnection.?outputs.?networkConnectionName ?? projectNetwork.name
  : projectNetwork.name

@description('The type of virtual network (Managed or Unmanaged)')
output networkType string = projectNetwork.virtualNetworkType
