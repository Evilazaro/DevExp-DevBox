@description('Key Valult Settings')
param keyvaultSettings object

@description('Key Vault Location')
param location string = resourceGroup().location

@description('Key Vault Tags')
param tags object

@description('Unique string for resource naming')
param unique string = utcNow('yyyyMMddHHmm')

@description('Azure Key Vault')
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: '${keyvaultSettings.keyVault.name}-${uniqueString(deployer().tenantId, location, unique, subscription().subscriptionId)}-kv'
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
          secrets: ['all']
          keys: ['all']
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}

@description('The name of the Key Vault')
output keyVaultName string = keyVault.name

@description('The endpoint URI of the Key Vault')
output endpoint string = keyVault.properties.vaultUri
