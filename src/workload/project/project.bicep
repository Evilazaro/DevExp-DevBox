@description('Dev Center Name')
param devCenterName string

@description('Project Name')
param name string

@description('Project Description')
param projectDescription string

@description('Project Catalogs')
param projectCatalogs object

@description('Project Environment Types')
param projectEnvironmentTypes object[]

@description('Project Pools')
param projectPools object[]

@description('Network Connection Name')
param networkConnectionName string

@description('Secret Identifier')
@secure()
param secretIdentifier string

@description('Key Vault Name')
param keyVaultName string

@description('Security Resource Group Name')
param securityResourceGroupName string

@description('Project Identity')
param identity Identity

@description('Tags')
param tags object

type Identity = {
  type: string
  roleAssignments: RoleAssignment[]
}

type AzureRBACRole = {
  id: string
  name: string
}

type RoleAssignment = {
  azureADGroupId: string
  azureADGroupName: string
  azureRBACRoles: AzureRBACRole[]
}

@description('Dev Center')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
}

@description('Dev Center Project')
resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: identity.type
  }
  properties: {
    description: projectDescription
    devCenterId: devCenter.id
    displayName: name
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
        'ImageDefinition'
      ]
    }
  }
  tags: tags
}

@description('Key Vault Access Policies')
module keyVaultAccessPolicies '../../security/keyvault-access.bicep' = {
  name: '${project.name}-keyvaultAccess'
  scope: resourceGroup(securityResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    principalId: project.identity.principalId
  }
}

@description('Project Identity')
module projectIdentity '../../identity/projectIdentityRoleAssignment.bicep' = [
  for identity in identity.roleAssignments: {
    name: 'projectIdentity-${guid(project.name,identity.azureADGroupName,identity.azureADGroupId)}'
    scope: resourceGroup()
    params: {
      projectName: project.name
      principalId: identity.azureADGroupId
      roles: identity.azureRBACRoles
    }
  }
]

@description('Environment Definition Catalog')
module catalogs 'projectCatalog.bicep' = {
  name: 'catalogs-${project.name}'
  scope: resourceGroup()
  params: {
    projectName: project.name
    catalogConfig: projectCatalogs
    secretIdentifier: secretIdentifier
  }
  dependsOn: [
    projectIdentity
  ]
}

@description('Project Environment Types')
module environmentTypes 'projectEnvironmentType.bicep' = [
  for environmentType in projectEnvironmentTypes: {
    name: 'environmentType-${project.name}-${environmentType.name}'
    scope: resourceGroup()
    params: {
      projectName: project.name
      environmentConfig: environmentType
    }
    dependsOn: [
      projectIdentity
    ]
  }
]

@description('Project Pools')
module pools 'projectPool.bicep' = [
  for pool in projectPools: {
    name: 'pool-${project.name}-${pool.name}'
    scope: resourceGroup()
    params: {
      name: pool.name
      projectName: project.name
      catalogName: projectCatalogs.imageDefinition.name
      imageDefinitionName: pool.imageDefinitionName
      networkConnectionName: networkConnectionName
    }
    dependsOn: [
      projectIdentity
      catalogs
    ]
  }
]

output AZURE_PROJECT_NAME string = project.name

