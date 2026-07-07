/*
  Azure Compute Gallery for Windows 365 Cloud PC custom images
  ------------------------------------------------------------
  Provisions the Shared Image Gallery that holds custom Cloud PC image
  definitions. This makes the accelerator self-contained: the gallery is
  created as part of `azd up` rather than being a prerequisite.

  Image *versions* are published into the gallery's image definitions by the
  organization's own image pipeline. This module intentionally does NOT hand-roll
  an Azure Image Builder template, because that resource type is not available in
  the Bicep schema service and would have to be fabricated.

  Schema verified via the Bicep schema service:
  - Microsoft.Compute/galleries@2024-03-03
*/

@description('Name of the Azure Compute Gallery. Allowed characters: alphanumerics, underscores, and periods.')
@minLength(1)
@maxLength(80)
param name string

@description('Azure region for the gallery')
param location string = resourceGroup().location

@description('Tags applied to the gallery')
param tags object = {}

@description('Azure Compute Gallery that stores Windows 365 Cloud PC custom image definitions')
resource gallery 'Microsoft.Compute/galleries@2024-03-03' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: 'Windows 365 Cloud PC custom image gallery for the DevExp accelerator'
  }
}

@description('The name of the Compute Gallery')
output galleryName string = gallery.name

@description('The resource ID of the Compute Gallery')
output galleryId string = gallery.id
