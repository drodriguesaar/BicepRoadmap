
@description('The location into which the resource will be deployed. Default value will be the location of the target resource group.')
param location string = resourceGroup().location

@allowed([
  'Production'
  'Test'
])
@description('The type of environment you will provision your azure resources')
param environmentType string

@minLength(10)
@maxLength(24)
param storageAccountName string = 'toywebsite${uniqueString(resourceGroup().id)}'

var blobContainerNames = [
  'productspecs'
  'productmanuals'
]

@description('Define the SKUs for each component based on the environment type.')
var environmentConfigurationMap = {
  Production: {
    storageAccount: {
      sku: {
        name: 'ZRS'
      }
    }
  }
  Test: {
    storageAccount: {
      sku: {
        name: 'LRS'
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobServiceContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for blobContainerName in blobContainerNames: {
  name: blobContainerName
  parent: storageAccountBlobService
}]


output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccounApiVersion string = storageAccount.apiVersion
