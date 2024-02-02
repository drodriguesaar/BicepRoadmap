@description('The Azure region into which the resources should be deployed')
param location string = resourceGroup().location

@description('The type of environment. This must be nonprod or prod')
@allowed([
  'nonprod'
  'prod'
])
param envinronmentType string

module appPlanAndApp 'modules/app-service.bicep' = {
  name: 'appServicePlanAndAPp'
  params: {
    location: location
    environmentType: envinronmentType
    appServiceAppName: 'toy-store-app'
  }
}

//here Im gonna add the output of the app service module ABCDEFGHIJ
