// ============================================================================
// Security Module
// ============================================================================
// Description: This module deploys Azure Key Vault and related security 
//              resources for the DevExp-DevBox project. It supports both
//              creating a new Key Vault or referencing an existing one based
//              on configuration settings.
//
// Parameters:
//   - tags: Resource tags to apply to deployed resources
//   - secretValue: Secure secret value to store in Key Vault
//   - logAnalyticsId: Log Analytics Workspace ID for diagnostics
//
// Outputs:
//   - AZURE_KEY_VAULT_NAME: The name of the Key Vault
//   - AZURE_KEY_VAULT_SECRET_IDENTIFIER: The identifier of the stored secret
//   - AZURE_KEY_VAULT_ENDPOINT: The endpoint URI of the Key Vault
//
// Dependencies:
//   - keyVault.bicep: Module for creating new Key Vault
//   - secret.bicep: Module for managing Key Vault secrets
//   - security.yaml: Configuration file for security settings
// ============================================================================

metadata name = 'Security Module'
metadata description = 'This module deploys Azure Key Vault and related security resources for the DevExp-DevBox project.'
metadata owner = 'DevExp Team'

@description('Key Vault Tags')
param tags Tags

@description('Secret Value')
@secure()
param secretValue string

@description('Log Analytics Workspace ID')
param logAnalyticsId string

@description('Tags type for resource tagging')
type Tags = {
  @description('Wildcard property for any tag key-value pairs')
  *: string
}

@description('Azure Key Vault Configuration')
var securitySettings = loadYamlContent('../../infra/settings/security/security.yaml')

@description('Azure Key Vault')
module keyVault 'keyVault.bicep' = if (securitySettings.create) {
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
  params: {
    name: securitySettings.keyVault.secretName
    keyVaultName: (securitySettings.create ? keyVault.?outputs.?AZURE_KEY_VAULT_NAME : existingKeyVault.?name) ?? ''
    logAnalyticsId: logAnalyticsId
    secretValue: secretValue
  }
}

@description('The name of the Key Vault')
output AZURE_KEY_VAULT_NAME string = (securitySettings.create
  ? keyVault.?outputs.?AZURE_KEY_VAULT_NAME
  : existingKeyVault.?name) ?? ''

@description('The identifier of the secret')
output AZURE_KEY_VAULT_SECRET_IDENTIFIER string = secret.outputs.AZURE_KEY_VAULT_SECRET_IDENTIFIER

@description('The endpoint URI of the Key Vault')
output AZURE_KEY_VAULT_ENDPOINT string = (securitySettings.create
  ? keyVault.?outputs.?AZURE_KEY_VAULT_ENDPOINT
  : existingKeyVault.?properties.?vaultUri) ?? ''
