/*
  Key Vault Bicep Module
  ----------------------
  This module deploys an Azure Key Vault resource with configurable settings for security,
  soft delete, purge protection, and RBAC authorization.

  Features:
    - Configurable soft delete with customizable retention period
    - Purge protection to prevent permanent deletion
    - RBAC-based authorization support
    - Standard SKU with 'A' family
    - Default access policies for deployer with secrets and keys permissions

  Parameters:
    - keyvaultSettings: Configuration settings for the Key Vault instance
      - keyVault.name: Base name for the Key Vault (will be suffixed with unique string and '-kv')
      - keyVault.enablePurgeProtection: Enable/disable purge protection
      - keyVault.enableSoftDelete: Enable/disable soft delete
      - keyVault.softDeleteRetentionInDays: Number of days to retain soft-deleted vaults
      - keyVault.enableRbacAuthorization: Enable/disable RBAC authorization
    - location: Azure region for deployment (defaults to resource group location)
    - tags: Resource tags to apply (key-value pairs)
    - unique: Unique string for resource naming to ensure global uniqueness
             (defaults to uniqueString based on resource group, location, subscription, and tenant)

  Outputs:
    - AZURE_KEY_VAULT_NAME: The deployed Key Vault name (includes unique suffix)
    - AZURE_KEY_VAULT_ENDPOINT: The Key Vault URI endpoint for accessing secrets and keys

  Usage Example:
    module keyVault 'security/keyVault.bicep' = {
      name: 'keyVaultDeployment'
      params: {
        keyvaultSettings: {
          keyVault: {
            name: 'mykeyvault'
            enablePurgeProtection: true
            enableSoftDelete: true
            softDeleteRetentionInDays: 90
            enableRbacAuthorization: true
          }
        }
        location: 'eastus'
        tags: {
          environment: 'production'
        }
      }
    }
*/

@description('Key Vault configuration settings')
param keyvaultSettings KeyVaultSettings

@description('Key Vault Location')
param location string = resourceGroup().location

@description('Key Vault Tags')
param tags Tags

@description('Unique string for resource naming')
param unique string = uniqueString(resourceGroup().id, location, subscription().subscriptionId, deployer().tenantId)

@description('Key Vault configuration type')
type KeyVaultSettings = {
  @description('Key Vault instance configuration')
  keyVault: KeyVaultConfig
}

@description('Key Vault instance configuration type')
type KeyVaultConfig = {
  @description('Name of the Key Vault')
  name: string

  @description('Flag to enable purge protection')
  enablePurgeProtection: bool

  @description('Flag to enable soft delete')
  enableSoftDelete: bool

  @description('Number of days to retain deleted vaults')
  softDeleteRetentionInDays: int

  @description('Flag to enable RBAC authorization')
  enableRbacAuthorization: bool
}

@description('Tags to apply to resources')
type Tags = {
  @description('Wildcard property for any tag key-value pairs')
  *: string
}

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
