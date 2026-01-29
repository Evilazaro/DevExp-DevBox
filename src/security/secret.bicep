/*
  This Bicep module creates an Azure Key Vault secret and configures diagnostic settings
  for the Key Vault to send logs and metrics to a Log Analytics workspace.

  Parameters:
    - name: The name of the secret to create
    - secretValue: The secure value of the secret
    - keyVaultName: The name of the existing Key Vault to store the secret
    - logAnalyticsId: The resource ID of the Log Analytics workspace for diagnostics

  Outputs:
    - AZURE_KEY_VAULT_SECRET_IDENTIFIER: The URI of the created secret
*/

@description('Secret Name')
param name string

@description('Secret Value')
@secure()
param secretValue string

@description('Key Vault Name')
param keyVaultName string

@description('Log Analytics Workspace ID')
param logAnalyticsId string

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

@description('Azure Key Vault Secret')
resource secret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  name: name
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'text/plain'
    value: secretValue
  }
}

@description('Log Analytics Diagnostic Settings')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyVault.name}-diagnostic-settings'
  scope: keyVault
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
    workspaceId: logAnalyticsId
  }
}

@description('The identifier of the secret')
output AZURE_KEY_VAULT_SECRET_IDENTIFIER string = secret.properties.secretUri
