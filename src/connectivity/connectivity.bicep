@description('Name of the DevCenter instance')
param devCenterName string

@description('Project Network Connectivity')
param projectNetwork object

@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsId string

@description('Azure region for resource deployment')
param location string

var rgCreate = (projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged') 

module Rg 'resourceGroup.bicep' = {
  name: 'projectNetworkRg-${uniqueString(projectNetwork.name, location)}'
  scope: subscription()
  params: {
    name: projectNetwork.resourceGroupName
    location: location
    tags: projectNetwork.tags
    create: rgCreate
  }
}

module virtualNetwork 'vnet.bicep' = if (rgCreate) {
  name: 'virtualNetwork-${uniqueString(projectNetwork.name, location)}'
  scope: resourceGroup(projectNetwork.resourceGroupName)
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
    Rg
  ]
}

var netConectCreate = (projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged') || (!projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged')

@description('Network Connection resource for DevCenter')
module networkConnection './networkConnection.bicep' = if (netConectCreate) {
  name: 'netconn-${uniqueString(projectNetwork.name,resourceGroup().id)}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: 'netconn-${virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.name}'
    subnetId: virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.subnets[0].id
  }
  dependsOn: [
    virtualNetwork
  ]
}

output networkConnectionName string = netConectCreate
  ? networkConnection!.outputs.networkConnectionName
  : projectNetwork.name

output networkType string = projectNetwork.virtualNetworkType
