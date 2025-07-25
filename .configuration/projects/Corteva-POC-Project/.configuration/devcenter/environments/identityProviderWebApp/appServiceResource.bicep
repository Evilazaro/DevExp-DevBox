@description('App Service Name')
param name string

@description('App Service Environment')
@allowed([
  'dev'
  'prod'
])
param environment string

@description('App Service Location')
param location string = resourceGroup().location

@description('App Service Kind')
@allowed([
  'app'
  'app,linux'
  'app,linux,container'
  'hyperV'
  'app,container,windows'
  'app,linux,kubernetes'
  'app,linux,container,kubernetes'
  'functionapp'
  'functionapp,linux'
  'functionapp,linux,container,kubernetes'
  'functionapp,linux,kubernetes'
])
param kind string = 'app,linux'

@description('App Service Plan SKU')
param sku object = {
  name: 'P1V3'
  tier: 'PremiumV3'
  capacity: 1
}

@description('App Service Current Stack')
@allowed([
  'dotnetcore'
  'java'
  'node'
  'php'
])
param currentStack string = 'dotnetcore'

@description('netFrameworkVersion')
@allowed([
  '7.0'
  '8.0'
  '9.0'
  ''
])
param dotnetcoreVersion string = '9.0'

@secure()
param InstrumentationKey string

@secure()
param ConnectionString string

@description('App Settings')
var appSettings = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'PLATFORM_ENGINEERING_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: ConnectionString
  }
  {
    name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
    value: '1.0.0'
  }
  {
    name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
    value: '1.0.0'
  }
  {
    name: 'APPLICATIONINSIGHTS_ENABLESQLQUERYCOLLECTION'
    value: 'enabled'
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'DiagnosticServices_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'IdProviderTemplate'
    value: '2.0'
  }
]

@description('Tags')
param tags object = {}

@description('LinuxFxVersion')
var linuxFxVersion = (contains(kind, 'linux')) ? '${toUpper(currentStack)}|${dotnetcoreVersion}' : null

@description('App Service Plan Resource')
resource serviceplan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${name}-${uniqueString(resourceGroup().id,name)}-svcplan'
  location: location
  sku: sku
  kind: 'linux'
  properties: {
    reserved: (contains(kind, 'linux')) ? true : false
  }
  tags: tags
}

@description('App Service Resource')
resource identityProvider 'Microsoft.Web/sites@2024-04-01' = {
  name: '${name}-${uniqueString(resourceGroup().id)}-${environment}'
  location: location
  kind: kind
  tags: {
    'azd-service-name': 'identityProvider'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serviceplan.id
    enabled: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      minimumElasticInstanceCount: 1
      http20Enabled: true
      appSettings: appSettings
    }
  }
}

output webappName string = identityProvider.name
output webappUrl string = identityProvider.properties.defaultHostName
