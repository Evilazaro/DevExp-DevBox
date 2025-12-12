@description('The name of the DevCenter instance')
param devCenterName string

@description('Environment Type configuration')
param environmentConfig EnvironmentType

@description('Environment Type definition')
type EnvironmentType = {
  @description('Name of the environment type')
  name: string
}

@description('Reference to the existing DevCenter')
resource devCenter 'Microsoft.DevCenter/devcenters@2025-10-01-preview' existing = {
  name: devCenterName
}

@description('DevCenter Environment Type resource')
resource environmentType 'Microsoft.DevCenter/devcenters/environmentTypes@2025-10-01-preview' = {
  name: environmentConfig.name
  parent: devCenter
  properties: {
    displayName: environmentConfig.name
  }
}

@description('The name of the created Environment Type')
output environmentTypeName string = environmentType.name

@description('The ID of the created Environment Type')
output environmentTypeId string = environmentType.id
