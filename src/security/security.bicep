@description('Key Vault Name')
param keyVaultName string

@description('Secret Name')
param secretName string

@description('Key Vault Location')
param location string = resourceGroup().location

@description('Key Vault Tags')
param tags object

@description('Secret Value')
@secure()
param secretValue string

param unique string = utcNow('yyyyMMddHHmmss')

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: '${keyVaultName}-${uniqueString(deployer().tenantId, location,unique,subscription().subscriptionId)}-kv'
  location: location
  tags: tags
  properties: {
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

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretName
  tags: tags
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
      exp: 0
      nbf: 0
    }
    contentType: 'string'
    value: secretValue
  }
}

@description('The name of the Key Vault')
output keyVaultName string = keyVault.name

@description('The identifier of the secret')
output secretIdentifier string = secret.properties.secretUri

@description('The endpoint URI of the Key Vault.')
output endpoint string = keyVault.properties.vaultUri
