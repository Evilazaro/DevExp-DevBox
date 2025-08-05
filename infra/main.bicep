targetScope = 'subscription'

// Parameters with improved validation and documentation
@description('Azure region where resources will be deployed')
@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
  'westus3'
  'centralus'
  'northeurope'
  'westeurope'
  'southeastasia'
  'australiaeast'
  'japaneast'
  'uksouth'
  'canadacentral'
  'swedencentral'
  'switzerlandnorth'
  'germanywestcentral'
])
param location string

@description('Secret value for Key Vault - GitHub Access Token')
@secure()
param secretValue string

@description('Environment name used for resource naming (dev, test, prod)')
@minLength(2)
@maxLength(10)
param environmentName string

param dateTime string = utcNow('yyyyMMdd-HHmmss')

// Load configuration from YAML
@description('Landing Zone resource organization')
var landingZones = loadYamlContent('settings/resourceOrganization/azureResources.yaml')

// Variables with consistent naming convention
var resourceNameSuffix = '${environmentName}-${location}-RG'

// Creates consistent resource group names
var createResourceGroupName = {
  security: landingZones.security.create
    ? '${landingZones.security.name}-${resourceNameSuffix}'
    : landingZones.security.name
  monitoring: landingZones.monitoring.create
    ? '${landingZones.monitoring.name}-${resourceNameSuffix}'
    : landingZones.monitoring.name
  workload: landingZones.workload.create
    ? '${landingZones.workload.name}-${resourceNameSuffix}'
    : landingZones.workload.name
}

var securityRgName = createResourceGroupName.security
var monitoringRgName = createResourceGroupName.monitoring
var workloadRgName = createResourceGroupName.workload

// Security resources
@description('Security Resource Group for Key Vault and related resources')
resource securityRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZones.security.create) {
  name: securityRgName
  location: location
  tags: union(landingZones.security.tags, {
    component: 'security'
  })
}

output SECURITY_AZURE_RESOURCE_GROUP_NAME string = securityRg.name

// Monitoring resources
@description('Monitoring Resource Group for Log Analytics and related resources')
resource monitoringRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZones.monitoring.create) {
  name: monitoringRgName
  location: location
  tags: union(landingZones.monitoring.tags, {
    component: 'monitoring'
  })
}

output MONITORING_AZURE_RESOURCE_GROUP_NAME string = monitoringRg.name

// Workload resources
@description('Workload Resource Group for DevCenter resources')
resource workloadRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZones.workload.create) {
  name: workloadRgName
  location: location
  tags: union(landingZones.workload.tags, {
    component: 'workload'
  })
}

output WORKLOAD_AZURE_RESOURCE_GROUP_NAME string = workloadRg.name

// Module deployments with improved names and organization
@description('Log Analytics Workspace for centralized monitoring')
module monitoring '../src/management/logAnalytics.bicep' = {
  name: 'monitoring-logAnalytics-${environmentName}-${dateTime}'
  scope: resourceGroup(monitoringRgName)
  params: {
    name: 'logAnalytics'
  }
  dependsOn: [
    monitoringRg
  ]
}

@description('The resource ID of the Log Analytics Workspace')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('The name of the Log Analytics Workspace')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME

@description('Security components including Key Vault')
module security '../src/security/security.bicep' = {
  name: 'security-keyvault-${environmentName}-${dateTime}'
  scope: resourceGroup(securityRgName)
  params: {
    secretValue: secretValue
    logAnalyticsId: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    tags: landingZones.security.tags
  }
  dependsOn: [
    securityRg
  ]
}

@description('The name of the Key Vault')
output AZURE_KEY_VAULT_NAME string = security.outputs.AZURE_KEY_VAULT_NAME

@description('The identifier of the secret')
output AZURE_KEY_VAULT_SECRET_IDENTIFIER string = security.outputs.AZURE_KEY_VAULT_SECRET_IDENTIFIER

@description('The endpoint URI of the Key Vault')
output AZURE_KEY_VAULT_ENDPOINT string = security.outputs.AZURE_KEY_VAULT_ENDPOINT

@description('DevCenter workload deployment')
module workload '../src/workload/workload.bicep' = {
  name: 'workload-${environmentName}-${dateTime}'
  scope: resourceGroup(workloadRgName)
  params: {
    logAnalyticsId: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    secretIdentifier: security.outputs.AZURE_KEY_VAULT_SECRET_IDENTIFIER
    securityResourceGroupName: securityRgName
  }
  dependsOn: [
    workloadRg
  ]
}

// Outputs with consistent naming and descriptions
@description('Name of the deployed Azure DevCenter')
output AZURE_DEV_CENTER_NAME string = workload.outputs.AZURE_DEV_CENTER_NAME

@description('List of project names deployed in the DevCenter')
output AZURE_DEV_CENTER_PROJECTS array = workload.outputs.AZURE_DEV_CENTER_PROJECTS
