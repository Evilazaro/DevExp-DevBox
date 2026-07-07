/*
  Workload Module for DevCenter Resources
  -------------------------------------
  This module deploys the DevCenter workload and associated projects.
*/

// Parameters with improved validation and documentation
@description('Log Analytics Workspace Resource ID')
@minLength(1)
param logAnalyticsId string

@description('Secret Identifier for secured content')
@secure()
param secretIdentifier string

@description('Security Resource Group Name')
@minLength(3)
param securityResourceGroupName string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

// Resource types with documentation
@description('Landing Zone configuration type')
type LandingZone = {
  @description('Name of the landing zone')
  name: string

  @description('Flag indicating whether to create the landing zone')
  create: bool

  @description('Tags to apply to the landing zone resources')
  tags: Tags
}

@description('Tags type for resource tagging')
type Tags = {
  @description('Wildcard property for any tag key-value pairs')
  *: string
}

// Variables with clear naming
@description('Settings loaded from configuration file')
var devCenterSettings = loadYamlContent('../../infra/settings/workload/devcenter.yaml')

// Deploy core DevCenter infrastructure
@description('DevCenter Core Infrastructure')
module devcenter 'core/devCenter.bicep' = {
  scope: resourceGroup()
  params: {
    config: devCenterSettings
    catalogs: devCenterSettings.catalogs
    environmentTypes: devCenterSettings.environmentTypes
    logAnalyticsId: logAnalyticsId
    secretIdentifier: secretIdentifier
    securityResourceGroupName: securityResourceGroupName
    location: location
  }
}

@description('Name of the deployed DevCenter')
output AZURE_DEV_CENTER_NAME string = devcenter.outputs.AZURE_DEV_CENTER_NAME

@description('True when any project enables Windows 365 Cloud PCs')
var anyCloudPc = length(filter(devCenterSettings.projects, project => (project.?platforms.?cloudPc.?enable ?? false))) > 0

@description('Name of the shared Azure Compute Gallery for Windows 365 image definitions')
var cloudPcGalleryName = 'gal_${replace(devCenterSettings.name, '-', '_')}_cloudpc'

@description('Shared Azure Compute Gallery for Windows 365 Cloud PC custom images (created only when a project enables Cloud PC)')
module cloudPcGallery 'cloudpc/gallery.bicep' = if (anyCloudPc) {
  scope: resourceGroup()
  params: {
    name: cloudPcGalleryName
    location: location
    tags: devCenterSettings.tags
  }
}

// Deploy individual projects with proper dependencies
@description('DevCenter Projects')
module projects 'project/project.bicep' = [
  for (project, i) in devCenterSettings.projects: {
    scope: resourceGroup()
    params: {
      name: project.name
      logAnalyticsId: logAnalyticsId
      projectDescription: project.description ?? project.name
      devCenterName: devcenter.outputs.AZURE_DEV_CENTER_NAME
      catalogs: project.catalogs
      projectEnvironmentTypes: project.environmentTypes
      projectPools: project.pools
      projectNetwork: project.network
      secretIdentifier: secretIdentifier
      securityResourceGroupName: securityResourceGroupName
      identity: project.identity
      galleryName: cloudPcGalleryName
      platforms: project.?platforms ?? {
        devBox: { enable: true }
        cloudPc: {
          enable: false
          licenseEdition: 'Enterprise'
          size: ''
          imageType: 'gallery'
          imageId: ''
          imageDisplayName: ''
          joinType: 'azureADJoin'
          enableSingleSignOn: true
          provisioningType: 'dedicated'
        }
      }
      tags: project.tags
      location: location
    }
    dependsOn: [
      cloudPcGallery
    ]
  }
]

@description('List of project names deployed in the DevCenter')
output AZURE_DEV_CENTER_PROJECTS array = [
  for (project, i) in devCenterSettings.projects: projects[i].outputs.AZURE_PROJECT_NAME
]

@description('Windows 365 Cloud PC provisioning contracts for all projects (consumed by the postprovision hook)')
output AZURE_CLOUD_PC_PROVISIONING array = [
  for (project, i) in devCenterSettings.projects: projects[i].outputs.AZURE_PROJECT_CLOUD_PC
]
