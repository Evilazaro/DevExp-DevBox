targetScope = 'subscription'

@description('Location for the deployment')
param location string = 'eastus2'

@description('Key Vault Secret')
@secure()
param secretValue string

@description('Landing Zone Information')
var landingZone = loadYamlContent('settings/resourceOrganization/azureResources.yaml')

@description('Workload Resource Group')
resource securityRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.workload.create) {
  name: landingZone.security.name
  location: location
  tags: landingZone.security.tags
}

@description('Deploy Security Module')
module security '../src/security/security.bicep' = {
  scope: securityRg
  name: 'security'
  params: {
    name: 'devexp-kv'
    secretValue: secretValue
    tags: landingZone.security.tags
  }
}

@description('Workload Resource Group')
resource monitoringRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.monitoring.create) {
  name: landingZone.monitoring.name
  location: location
  tags: landingZone.monitoring.tags
}

@description('Deploy Monitoring Module')
module monitoring '../src/management/logAnalytics.bicep' = {
  scope: monitoringRg
  name: 'monitoring'
  params: {
    name: 'logAnalytics'
  }
}

@description('Workload Resource Group')
resource connectivityRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.connectivity.create) {
  name: landingZone.connectivity.name
  location: location
  tags: landingZone.connectivity.tags
}

@description('Deploy Connectivity Module')
module connectivity '../src/connectivity/connectivity.bicep' = {
  name: 'connectivity'
  scope: connectivityRg
  params: {
    workspaceId: monitoring.outputs.logAnalyticsId
  }
}

@description('Workload Resource Group')
resource workloadRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.workload.create) {
  name: landingZone.workload.name
  location: location
  tags: landingZone.workload.tags
}

@description('Deploy Workload Module')
module workload '../src/workload/workload.bicep' = {
  name: 'workload'
  scope: workloadRg
  params: {
    logAnalyticsId: monitoring.outputs.logAnalyticsId
    subnets: connectivity.outputs.virtualNetworkSubnets
    secretIdentifier: security.outputs.secretIdentifier
    keyVaultName: security.outputs.keyVaultName
    securityResourceGroupName: securityRg.name
  }
}
