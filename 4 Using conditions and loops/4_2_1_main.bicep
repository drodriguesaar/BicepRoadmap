param storageAccounts array = [
  { location: 'westeurope', name: 'stawesteurope${uniqueString(resourceGroup().id)}', env: 'prod' }
  { location: 'eastus2', name: 'staeastus2${uniqueString(resourceGroup().id)}', env: 'dev' }
  { location: 'eastasia', name: 'staeastasia${uniqueString(resourceGroup().id)}', env: 'test' }
]

module newStorageAccount '4_2_2_storageAccount.bicep' = [for storageAccount in storageAccounts: if (storageAccount.env != 'prod') {
  name: 'sta${storageAccount.location}'
  scope: resourceGroup()
  params: {
    storageAccountLocation: storageAccount.location
    storageAccountName: storageAccount.name
  }
}]

