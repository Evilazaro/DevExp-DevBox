@description('Name of the Log Analytics workspace')
param name string 

@description('Tags for the Log Analytics workspace')
param tags object = {
  environment: 'dev'
  workload: 'identityProvider'
}

@description('Create a Log Analytics workspace')
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${name}-${uniqueString(name, resourceGroup().id)}'
  location: resourceGroup().location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${name}-${uniqueString(name, resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output InstrumentationKey string = appInsights.properties.InstrumentationKey
output ConnectionString string = appInsights.properties.ConnectionString
