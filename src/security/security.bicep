@description('Key Vault Tags')
param tags object

@description('Secret Value')
@secure()
param secretValue string

@description('Log Analytics Workspace ID')
param logAnalyticsId string

@description('Azure Key Vault Configuration')
var securitySettings = loadYamlContent('../../infra/settings/security/security.yaml')

param dateTime string = utcNow('yyyyMMdd-HHmmss')

@description('Azure Key Vault')
module keyVault 'keyVault.bicep' = if (securitySettings.create) {
  name: 'keyVault-${securitySettings.keyVault.name}-${dateTime}'
  params: {
    tags: tags
    keyvaultSettings: securitySettings
  }
}

@description('Existing Key Vault')
resource existingKeyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (!securitySettings.create) {
  name: securitySettings.keyVault.name
  scope: resourceGroup()
}

@description('Key vault secret module')
module secret 'secret.bicep' = {
  name: 'keyVaultSecret-${securitySettings.keyVault.secretName}-${dateTime}'
  params: {
    name: securitySettings.keyVault.secretName
    keyVaultName: (securitySettings.create ? keyVault!.outputs.AZURE_KEY_VAULT_NAME : existingKeyVault!.name)
    logAnalyticsId: logAnalyticsId
    secretValue: secretValue
  }
}

@description('The name of the Key Vault')
output AZURE_KEY_VAULT_NAME string = (securitySettings.create ? keyVault!.outputs.AZURE_KEY_VAULT_NAME : existingKeyVault!.name)

@description('The identifier of the secret')
output AZURE_KEY_VAULT_SECRET_IDENTIFIER string = secret.outputs.AZURE_KEY_VAULT_SECRET_IDENTIFIER

@description('The endpoint URI of the Key Vault')
output AZURE_KEY_VAULT_ENDPOINT string = (securitySettings.create ? keyVault!.outputs.AZURE_KEY_VAULT_ENDPOINT : existingKeyVault!.properties.vaultUri)
