@description('Key Vault Settings')
param keyvaultSettings object

@description('Key Vault Location')
param location string = resourceGroup().location

@description('Key Vault Tags')
param tags object

@description('Unique string for resource naming')
param unique string = uniqueString(resourceGroup().id, location, subscription().subscriptionId, deployer().tenantId)

@description('Azure Key Vault')
resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: '${keyvaultSettings.keyVault.name}-${unique}-kv'
  location: location
  tags: tags
  properties: {
    enablePurgeProtection: keyvaultSettings.keyVault.enablePurgeProtection
    enableSoftDelete: keyvaultSettings.keyVault.enableSoftDelete
    softDeleteRetentionInDays: keyvaultSettings.keyVault.softDeleteRetentionInDays
    enableRbacAuthorization: keyvaultSettings.keyVault.enableRbacAuthorization
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        objectId: deployer().objectId
        permissions: {
          secrets: ['get', 'list', 'set', 'delete', 'backup', 'restore', 'recover']
          keys: ['get', 'list', 'create', 'delete', 'backup', 'restore', 'recover']
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}

@description('The name of the Key Vault')
output AZURE_KEY_VAULT_NAME string = keyVault.name

@description('The endpoint URI of the Key Vault')
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.properties.vaultUri
