targetScope = 'subscription'

@description('Location for the deployment')
param location string = 'eastus2'

@description('Landing Zone Information')
var landingZone = loadYamlContent('settings/resourceOrganization/azureResources.yaml')

@description('Workload Resource Group')
resource workloadRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.workload.create) {
  name: landingZone.workload.name
  location: location
  tags: landingZone.workload.tags
}

@description('Deploy Monitoring Module')
module monitoring '../src/management/logAnalytics.bicep' = {
  scope: workloadRg
  name: 'monitoring'
  params: {
    name: 'logAnalytics'
  }
}

@description('Deploy Connectivity Module')
module connectivity '../src/connectivity/connectivity.bicep' = {
  name: 'connectivity'
  scope: workloadRg
  params: {
    workspaceId: monitoring.outputs.logAnalyticsId
  }
}

@description('Deploy Workload Module')
module workload '../src/workload/workload.bicep' = {
  name: 'workload'
  scope: workloadRg
  params: {
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsName
    subnets: connectivity.outputs.virtualNetworkSubnets
  }
}
