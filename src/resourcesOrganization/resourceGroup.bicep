targetScope = 'subscription'

param landingZone object

param location string = 'eastus2'

@description('Management Resource Group')
resource managementRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.management.create) {
  name: landingZone.management.name
  location: location
  tags: landingZone.management.tags
}

@description('Compute Resource Group')
resource computeRg 'Microsoft.Resources/resourceGroups@2024-11-01' = if (landingZone.compute.create) {
  name: landingZone.compute.name
  location: location
  tags: landingZone.compute.tags
}

