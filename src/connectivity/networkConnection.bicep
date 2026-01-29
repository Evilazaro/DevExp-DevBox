// ============================================================================
// Network Connection Module for DevCenter
// ============================================================================
// This module creates a network connection and attaches it to an existing
// DevCenter instance. The network connection enables DevCenter to provision
// Dev Boxes within the specified subnet using Azure AD Join.
//
// Parameters:
//   - name: Name of the network connection to be created
//   - devCenterName: Name of the existing DevCenter instance to attach to
//   - subnetId: Resource ID of the subnet for Dev Box connectivity
//   - location: Azure region for deployment (defaults to resource group location)
//   - tags: Optional tags to apply to resources
//
// Resources Created:
//   - Microsoft.DevCenter/networkConnections: Network connection with Azure AD Join
//   - Microsoft.DevCenter/devcenters/attachednetworks: Attachment to DevCenter
//
// Outputs:
//   - vnetAttachmentName: Name of the VNet attachment resource
//   - networkConnectionId: Resource ID of the network connection
//   - attachedNetworkId: Resource ID of the attached network
//   - networkConnectionName: Name of the network connection
//
// Usage Example:
//   module networkConnection 'networkConnection.bicep' = {
//     name: 'deploy-network-connection'
//     params: {
//       name: 'my-network-connection'
//       devCenterName: 'my-devcenter'
//       subnetId: '/subscriptions/.../subnets/dev-subnet'
//     }
//   }
// ============================================================================

@description('Name of the network connection to be created')
param name string

@description('Name of the existing DevCenter instance')
param devCenterName string

@description('Resource ID of the subnet to connect to DevCenter')
param subnetId string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Optional tags to apply to the network connection')
param tags object = {}

@description('Reference to existing DevCenter instance')
resource devcenter 'Microsoft.DevCenter/devcenters@2025-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Network Connection resource for DevCenter')
resource netConnection 'Microsoft.DevCenter/networkConnections@2025-10-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
  }
}

@description('DevCenter Network Connection Attachment')
resource vnetAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2025-10-01-preview' = {
  name: name
  parent: devcenter
  properties: {
    networkConnectionId: netConnection.id
  }
}

@description('The name of the Virtual Network Attachment')
output vnetAttachmentName string = vnetAttachment.name

@description('The ID of the Network Connection')
output networkConnectionId string = netConnection.id

@description('The resource ID of the attached network')
output attachedNetworkId string = vnetAttachment.id

@description('The name of the Network Connection')
output networkConnectionName string = netConnection.name
