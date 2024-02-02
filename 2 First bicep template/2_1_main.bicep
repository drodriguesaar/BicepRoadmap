@description('The environments into which these resources should be created.')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environmentType string

@minLength(10)
@maxLength(24)
param storageAccountName string = 'tpstorage${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location
param appServiceAppName string = 'tp-app-${uniqueString(resourceGroup().id)}'

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
  }
}

module appService '2_2_appService.bicep' = {
  name: 'app'
  params: {
    appServiceAppName: appServiceAppName
    environmentType: environmentType
    location: location
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
