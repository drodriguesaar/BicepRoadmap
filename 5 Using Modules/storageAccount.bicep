@description('The region to deploy the resources')
param location string = resourceGroup().location

@description('The type of environment')
@allowed([
  'development'
  'production'
])
param environmentType string = 'development'

var staPrefix = 'toysta'

var staName = take('${staPrefix}${uniqueString(resourceGroup().id)}', 24)

var staSKU = (environmentType == 'production') ? 'Premium_LRS' : 'Standard_LRS'

var tags = {
  env: environmentType
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: staName
  location: location
  kind: 'StorageV2'
  tags: tags
  sku: {
    name: staSKU
  }
}
