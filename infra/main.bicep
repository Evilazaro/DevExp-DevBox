/*
  Main Bicep Deployment Template
  ==============================
  This template deploys the DevExp-DevBox infrastructure at the subscription scope.
  It provisions a complete development environment with security, monitoring, and 
  DevCenter workload resources organized into separate resource groups.
  
  Architecture Overview:
  ----------------------
  The deployment follows a landing zone pattern with three resource groups:
  
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │                         Subscription Scope                                   │
  ├─────────────────┬─────────────────────┬─────────────────────────────────────┤
  │ Security RG     │ Monitoring RG       │ Workload RG                         │
  │ - Key Vault     │ - Log Analytics     │ - Azure DevCenter                   │
  │ - Secrets       │   Workspace         │ - Projects                          │
  │ - Diagnostics   │                     │ - Dev Box Definitions               │
  └─────────────────┴─────────────────────┴─────────────────────────────────────┘
  
  Resources Deployed:
  -------------------
  - Security Resource Group: Contains Key Vault for secret management with 
    diagnostic settings forwarding logs to Log Analytics
  - Monitoring Resource Group: Contains Log Analytics Workspace for centralized 
    monitoring and log aggregation across all resources
  - Workload Resource Group: Contains Azure DevCenter with projects, pools, 
    and developer self-service configurations
  
  Module Dependencies:
  --------------------
  1. monitoring → Deploys first (Log Analytics Workspace)
  2. security   → Depends on monitoring (uses workspace ID for diagnostics)
  3. workload   → Depends on security & monitoring (uses secret identifier)
  
  Configuration:
  --------------
  - Resource organization loaded from 'settings/resourceOrganization/azureResources.yaml'
  - Supports conditional resource group creation based on YAML 'create' flag
  - Resource naming follows pattern: {name}-{environment}-{location}-RG
  
  Parameters:
  -----------
  - location        : Azure region for deployment (restricted to supported regions)
  - environmentName : Environment identifier (dev, test, prod) - 2-10 characters
  - secretValue     : Secure GitHub Access Token stored in Key Vault
  
  Outputs:
  --------
  - Resource group names for security, monitoring, and workload
  - Log Analytics Workspace ID and name
  - Key Vault name, endpoint, and secret identifier
  - DevCenter name and project list
  
  Usage:
  ------
    # Deploy to a subscription
    az deployment sub create \
      --location eastus2 \
      --template-file main.bicep \
      --parameters location=eastus2 \
                   environmentName=dev \
                   secretValue=<github-token>
    
    # Deploy with parameter file
    az deployment sub create \
      --location eastus2 \
      --template-file main.bicep \
      --parameters @main.bicepparam
  
  Repository: Evilazaro/DevExp-DevBox
  Branch: docs/refacto
*/

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
resource securityRg 'Microsoft.Resources/resourceGroups@2025-04-01' = if (landingZones.security.create) {
  name: securityRgName
  location: location
  tags: union(landingZones.security.tags, {
    component: 'security'
  })
}

output SECURITY_AZURE_RESOURCE_GROUP_NAME string = securityRg.name

// Monitoring resources
@description('Monitoring Resource Group for Log Analytics and related resources')
resource monitoringRg 'Microsoft.Resources/resourceGroups@2025-04-01' = if (landingZones.monitoring.create) {
  name: monitoringRgName
  location: location
  tags: union(landingZones.monitoring.tags, {
    component: 'monitoring'
  })
}

output MONITORING_AZURE_RESOURCE_GROUP_NAME string = monitoringRg.name

// Workload resources
@description('Workload Resource Group for DevCenter resources')
resource workloadRg 'Microsoft.Resources/resourceGroups@2025-04-01' = if (landingZones.workload.create) {
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
