/*
  Windows 365 Cloud PC provisioning-contract module
  --------------------------------------------------
  Windows 365 Enterprise Cloud PC resources (Azure Network Connection,
  provisioning policy, user settings, and group assignment) are provisioned
  through Microsoft Graph (deviceManagement/virtualEndpoint). Those resources
  have NO ARM/Bicep resource types, so this module does not create them.

  Instead, it normalizes and validates the declarative Cloud PC configuration,
  derives the networking binding (Azure Network Connection vs. Microsoft-hosted
  network), and emits a single provisioning contract consumed by
  scripts/Configure-Windows365.ps1 (run as an azd postprovision hook).

  References:
  - Windows 365 Enterprise: https://learn.microsoft.com/windows-365/enterprise/
  - Create provisioning policy: https://learn.microsoft.com/graph/api/virtualendpoint-post-provisioningpolicies
  - Create Azure network connection: https://learn.microsoft.com/graph/api/virtualendpoint-post-onpremisesconnections
*/

@description('Name of the project that owns these Cloud PCs')
@minLength(1)
param projectName string

@description('Azure region used for Microsoft-hosted Cloud PCs when no subnet is supplied')
param location string = resourceGroup().location

@description('Windows 365 Cloud PC configuration for the project')
param config CloudPcConfig

@description('Resource ID of the subnet used for the Azure Network Connection (empty for a Microsoft-hosted network)')
param subnetId string = ''

@description('Object ID of the Microsoft Entra group that receives Cloud PCs')
param userGroupId string

@description('Tags surfaced in the provisioning contract for governance traceability')
param tags object = {}

@description('Windows 365 Cloud PC configuration type')
type CloudPcConfig = {
  @description('Enable Windows 365 Cloud PCs for this project')
  enable: bool

  @description('Windows 365 license edition (Enterprise or Frontline)')
  licenseEdition: string

  @description('Cloud PC size assigned through the per-user license (for example, 8vCPU/32GB/256GB)')
  size: string

  @description('Type of OS image (gallery or custom)')
  imageType: string

  @description('Image identifier. Gallery format: {publisher}_{offer}_{sku}')
  imageId: string

  @description('Display name of the OS image')
  imageDisplayName: string

  @description('Domain join type. azureADJoin = Microsoft Entra join; hybridAzureADJoin = Hybrid join')
  joinType: string

  @description('Enable single sign-on for the Cloud PC')
  enableSingleSignOn: bool

  @description('License model used when provisioning Cloud PCs (dedicated or shared)')
  provisioningType: string

  @description('Optional Azure region override for Microsoft-hosted Cloud PCs')
  region: string?
}

@description('True when a customer subnet is supplied, so an Azure Network Connection is used instead of a Microsoft-hosted network')
var useAzureNetworkConnection = !empty(subnetId)

@description('Virtual network resource ID derived from the subnet resource ID (empty for Microsoft-hosted networks)')
var virtualNetworkId = useAzureNetworkConnection ? substring(subnetId, 0, indexOf(subnetId, '/subnets/')) : ''

@description('Region override supplied in configuration, if any')
var regionOverride = config.?region ?? ''

@description('Effective region for Microsoft-hosted Cloud PCs')
var effectiveRegion = empty(regionOverride) ? location : regionOverride

@description('Structured Windows 365 provisioning contract for the project, consumed by the postprovision configuration script')
output CLOUD_PC_CONTRACT object = {
  projectName: projectName
  enabled: config.enable
  provisioningPolicyName: 'w365-${projectName}'
  displayName: 'Windows 365 - ${projectName}'
  azureNetworkConnectionName: useAzureNetworkConnection ? 'anc-${projectName}' : ''
  networkType: useAzureNetworkConnection ? 'azureNetworkConnection' : 'microsoftHosted'
  licenseEdition: config.licenseEdition
  size: config.size
  imageType: config.imageType
  imageId: config.imageId
  imageDisplayName: config.imageDisplayName
  joinType: config.joinType
  enableSingleSignOn: config.enableSingleSignOn
  provisioningType: config.provisioningType
  subscriptionId: subscription().subscriptionId
  resourceGroupId: resourceGroup().id
  virtualNetworkId: virtualNetworkId
  subnetId: subnetId
  region: effectiveRegion
  userGroupId: userGroupId
  tags: tags
}
