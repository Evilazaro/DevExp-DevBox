/*
  Module: secret.bicep
  Description: Creates an Azure Key Vault secret and configures diagnostic settings
               for monitoring the Key Vault using Log Analytics.

  This module performs the following:
    1. References an existing Azure Key Vault in the current resource group
    2. Creates a new secret with the specified name and value
    3. Configures diagnostic settings to send all logs and metrics to Log Analytics

  Parameters:
    - name (string): The name of the secret to create in the Key Vault
    - secretValue (securestring): The sensitive value to store in the secret
    - keyVaultName (string): The name of the existing Key Vault resource
    - logAnalyticsId (string): The resource ID of the Log Analytics workspace for diagnostics

  Resources Created:
    - Microsoft.KeyVault/vaults/secrets: The Key Vault secret with the provided value
    - Microsoft.Insights/diagnosticSettings: Diagnostic settings for the Key Vault

  Outputs:
    - AZURE_KEY_VAULT_SECRET_IDENTIFIER (string): The full URI of the created secret
      (e.g., https://<vault-name>.vault.azure.net/secrets/<secret-name>)

  Usage Example:
    module secret 'security/secret.bicep' = {
      name: 'deploySecret'
      params: {
        name: 'mySecret'
        secretValue: 'supersecretvalue'
        keyVaultName: 'myKeyVault'
        logAnalyticsId: '/subscriptions/.../workspaces/myWorkspace'
      }
    }
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
