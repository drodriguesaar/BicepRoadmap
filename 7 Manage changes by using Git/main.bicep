@description('The Azure region into which the resources should be deployed')
param location string = resourceGroup().location

@description('The type of environment. This must be nonprod or prod')
@allowed([
  'nonprod'
  'prod'
])
param envinronmentType string

module app 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: envinronmentType
    appServiceAppName: 'toy-store-app'
  }
}
