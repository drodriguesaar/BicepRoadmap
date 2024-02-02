@description('The type of environment')
@allowed([
  'development'
  'production'
])
param environmentType string = 'development'

@description('The server farm type of the service plan')
@allowed([
  'windows'
  'linux'
])
param serverType string = 'windows'

@description('The location of the server farms')
param location string = resourceGroup().location

var appServicePlanName = '${environmentType}-toy-app-srv'

var appServiceAppName = '${environmentType}-toy-app'

var isProdEnv = (environmentType == 'production')

var appServicePlanSku = isProdEnv ? 'P2v3' : 'F1'

var numberOfInstances = isProdEnv ? 3 : 1

var tags = {
  env: environmentType
}

//Create the app service plan (web famrs)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  location: location
  name: appServicePlanName
  tags: tags
  kind: serverType
  sku: {
    capacity: numberOfInstances
    name: appServicePlanSku
  }
}

//Create the web app host of the application
resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  location: location
  name: appServiceAppName
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

//Create the storage account that will be used by the web app
module storageAccount 'storageAccount.bicep' = {
  name: '${environmentType}stadeployment'
  params: {
    environmentType: environmentType
    location: location
  }
}
