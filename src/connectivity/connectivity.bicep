@description('Name of the DevCenter instance')
param devCenterName string

@description('Project Network Connectivity')
param projectNetwork object

@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsId string

@description('Azure region for resource deployment')
param location string

module Rg 'resourceGroup.bicep' = {
  name: 'projectNetworkRg-${uniqueString(projectNetwork.name, location)}'
  scope: subscription()
  params: {
    name: projectNetwork.resourceGroupName
    location: location
    tags: projectNetwork.tags
    create: projectNetwork.create
  }
}

module virtualNetwork 'vnet.bicep' = {
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

module networkConnection './networkConnection.bicep' = if (projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged') {
  name: 'netconn-${uniqueString(projectNetwork.name,resourceGroup().id)}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenterName
    name: 'netconn-${virtualNetwork.name}'
    subnetId: virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK.subnets[0].id
  }
  dependsOn: [
    virtualNetwork
  ]
}

var connectionName = (projectNetwork.create && projectNetwork.virtualNetworkType == 'Unmanaged')
  ? networkConnection.name
  : projectNetwork.name

output networkConnectionName string = connectionName

output networkType string = projectNetwork.virtualNetworkType
