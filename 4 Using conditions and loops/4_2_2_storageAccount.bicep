
@description('The name of the storage account')
@minLength(10)
@maxLength(24)
param storageAccountName string

@description('The location of the storage account')
param storageAccountLocation string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: storageAccountLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output newStorage string = storageAccount.name
