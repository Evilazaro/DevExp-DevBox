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
      tags: project.tags
      location: location
    }
  }
]

@description('List of project names deployed in the DevCenter')
output AZURE_DEV_CENTER_PROJECTS array = [
  for (project, i) in devCenterSettings.projects: projects[i].outputs.AZURE_PROJECT_NAME
]
