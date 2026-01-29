// ============================================================================
// Environment Type Bicep Module
// ============================================================================
// This module creates a DevCenter Environment Type resource.
// Environment Types define the different environments (e.g., Dev, Test, Prod)
// that can be used within a DevCenter for project deployments.
//
// Parameters:
//   - devCenterName: The name of the existing DevCenter instance to attach to
//   - environmentConfig: Configuration object containing the environment type name
//
// Outputs:
//   - environmentTypeName: The name of the created Environment Type
//   - environmentTypeId: The resource ID of the created Environment Type
//
// Usage:
//   module envType 'environmentType.bicep' = {
//     name: 'deploy-env-type'
//     params: {
//       devCenterName: 'myDevCenter'
//       environmentConfig: {
//         name: 'Development'
//       }
//     }
//   }
// ============================================================================

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
