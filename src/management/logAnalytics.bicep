param name string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceId string = logAnalyticsWorkspace.id
output logAnalyticsId string = logAnalyticsWorkspace.id
output logAnalyticsName string = logAnalyticsWorkspace.name

@description('Log Analytics Diagnostic Settings')
resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: logAnalyticsWorkspace.name
  scope: logAnalyticsWorkspace
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}


output diagnosticSettingsId string = logAnalyticsDiagnosticSettings.id
output diagnosticSettingsName string = logAnalyticsDiagnosticSettings.name
output diagnosticSettingsType string = logAnalyticsDiagnosticSettings.type
