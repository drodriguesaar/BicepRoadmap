@description('The azure region into which the resources should be deployed')
param location string = resourceGroup().location

@secure()
@description('The administrator login username for SQL server')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server')
param sqlServerAdministratorLoginPassword string

@description('The name and tier of the SQL database SKU')
param sqlDatabseSKU object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The name of the environment. This mus be Development or Production')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Development'

@description('The name of the audit storage account SKU')
param auditStorageAccountSkuName string = 'Standard_LRS'

@description('A list of names for all storage accounts to be created')
param storageAccountNames array = [
  take('saauditus${uniqueString(resourceGroup().id)}', 24)
  take('saauditeurope${uniqueString(resourceGroup().id)}', 24)
  take('saauditapac${uniqueString(resourceGroup().id)}', 24)
]

var sqlServerName = 'teddy${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'TeddyBear'

var auditingEnabled = environmentName == 'Production'
var auditStorageAccountName = take('bearaudit${location}${uniqueString(resourceGroup().id)}', 24)

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}

resource sqlDataBase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabseSKU
}

//deploy conditionally
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (auditingEnabled) {
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditStorageAccountSkuName
  }
  kind: 'StorageV2'
}

//deploy conditionally
resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2023-05-01-preview' = if (auditingEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: auditingEnabled ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: auditingEnabled ? auditStorageAccount.listKeys().keys[0].value : ''
  }
}

// resource storageAccountResources 'Microsoft.Storage/storageAccounts@2023-01-01' = [for name in storageAccountNames: {
//   name: name
//   location: location
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }]

param dataBases array = [
  { location: 'westeurope', name: 'sqlserverwesteurope', env: 'prod' }
  { location: 'eastus2', name: 'sqlservereastus2', env: 'dev' }
  { location: 'eastasia', name: 'sqlservereastasia', env: 'test' }
]

resource storageAccountResources2 'Microsoft.Storage/storageAccounts@2023-01-01' = [for db in dataBases: if(db.env == 'prod') {
  name: db.name
  location: db.location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]

//az deployment group create -g Demo1 -f 4_1_main.bicep --parameters 4_main.parameters.dev.json environmentName='Production'
