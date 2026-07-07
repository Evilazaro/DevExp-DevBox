/*
  Windows 365 Cloud PC module (per project)
  -----------------------------------------
  Windows 365 Enterprise Cloud PC control-plane resources (Azure Network
  Connection, provisioning policy, group assignment) are provisioned through
  Microsoft Graph (deviceManagement/virtualEndpoint) - they have NO ARM/Bicep
  resource types. This module therefore:

    1. Creates a Windows 365 image DEFINITION in the shared Compute Gallery
       (real ARM type) as the target for organization-published custom versions.
    2. Normalizes the declarative Cloud PC configuration - including the WinGet
       Configuration DSC customizations that are applied at Cloud PC provisioning
       (mirroring how Dev Box applies them at box creation) - into a single
       provisioning contract consumed by scripts/Configure-Windows365.ps1.

  Schema verified via the Bicep schema service:
  - Microsoft.Compute/galleries/images@2024-03-03
*/

@description('Name of the project that owns these Cloud PCs')
@minLength(1)
param projectName string

@description('Azure region for the image definition and Microsoft-hosted Cloud PCs')
param location string = resourceGroup().location

@description('Windows 365 Cloud PC configuration for the project')
param config CloudPcConfig

@description('Name of the shared Azure Compute Gallery that holds the image definition')
@minLength(1)
param galleryName string

@description('Resource ID of the subnet for the Azure Network Connection (empty = Microsoft-hosted network)')
param subnetId string = ''

@description('Object ID of the Microsoft Entra group that receives Cloud PCs')
param userGroupId string

@description('Base URI used by the provisioning script to fetch the DSC customization files')
param dscBaseUri string = 'https://raw.githubusercontent.com/Evilazaro/DevExp-DevBox/main/'

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

  @description('Type of OS image the provisioning policy uses (gallery or custom)')
  imageType: string

  @description('Image identifier the provisioning policy uses. Gallery format: {publisher}_{offer}_{sku}')
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

  @description('Customization parity with Dev Box: DSC files applied at provisioning')
  customizations: CloudPcCustomizations?
}

@description('Windows 365 customization configuration')
type CloudPcCustomizations = {
  @description('Repo-relative paths of WinGet Configuration DSC files applied via winget configure at provisioning')
  dscConfigurations: string[]?
}

@description('Reference to the shared Compute Gallery')
resource gallery 'Microsoft.Compute/galleries@2024-03-03' existing = {
  name: galleryName
}

@description('Windows 365 image definition (target for organization-published custom image versions)')
resource imageDefinition 'Microsoft.Compute/galleries/images@2024-03-03' = {
  name: 'w365-${projectName}'
  parent: gallery
  location: location
  tags: tags
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    hyperVGeneration: 'V2'
    description: 'Windows 365 Cloud PC image definition for project ${projectName}'
    identifier: {
      publisher: 'DevExp'
      offer: 'Windows365-CloudPC'
      sku: projectName
    }
    features: [
      {
        name: 'SecurityType'
        value: 'TrustedLaunch'
      }
    ]
  }
}

@description('True when a customer subnet is supplied, so an Azure Network Connection is used instead of a Microsoft-hosted network')
var useAzureNetworkConnection = !empty(subnetId)

@description('Virtual network resource ID derived from the subnet resource ID (empty for Microsoft-hosted networks)')
var virtualNetworkId = useAzureNetworkConnection ? substring(subnetId, 0, indexOf(subnetId, '/subnets/')) : ''

@description('Region override supplied in configuration, if any')
var regionOverride = config.?region ?? ''

@description('Effective region for Microsoft-hosted Cloud PCs')
var effectiveRegion = empty(regionOverride) ? location : regionOverride

@description('DSC customization files applied at provisioning (empty when none configured)')
var dscConfigurations = config.?customizations.?dscConfigurations ?? []

@description('The resource ID of the Windows 365 image definition')
output imageDefinitionId string = imageDefinition.id

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
  galleryImageDefinitionId: imageDefinition.id
  dscBaseUri: dscBaseUri
  dscConfigurations: dscConfigurations
  tags: tags
}
