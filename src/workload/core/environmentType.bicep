// ============================================================================
// Environment Type Bicep Module
// ============================================================================
// 
// Description:
//   This module creates a DevCenter Environment Type resource. Environment Types
//   define the different deployment environments (e.g., Development, Testing, 
//   Staging, Production) that can be used within a DevCenter for project deployments.
//
// Resources Created:
//   - Microsoft.DevCenter/devcenters/environmentTypes: The environment type attached
//     to an existing DevCenter instance.
//
// Parameters:
//   - devCenterName (string, required): The name of the existing DevCenter instance
//     to which the environment type will be attached.
//   - environmentConfig (EnvironmentType, required): Configuration object containing
//     the environment type settings, including the name property.
//
// Outputs:
//   - environmentTypeName (string): The name of the created Environment Type resource.
//   - environmentTypeId (string): The fully qualified resource ID of the created
//     Environment Type.
//
// Dependencies:
//   - An existing DevCenter resource must be deployed before using this module.
//
// API Version: 2025-10-01-preview
//
// Usage Example:
//   module envType 'environmentType.bicep' = {
//     name: 'deploy-env-type'
//     params: {
//       devCenterName: 'myDevCenter'
//       environmentConfig: {
//         name: 'Development'
//       }
//     }
//   }
//
//   // Access outputs
//   var envTypeName = envType.outputs.environmentTypeName
//   var envTypeId = envType.outputs.environmentTypeId
//
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
