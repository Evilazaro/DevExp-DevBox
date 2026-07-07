@description('Name of the DevCenter instance')
param devCenterName string

@description('Project Network Connectivity')
param projectNetwork object

@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsId string

@description('Azure region for resource deployment')
param location string

@description('Determines if network connectivity resources should be created based on project network configuration')
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
