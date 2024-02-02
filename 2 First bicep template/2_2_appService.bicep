@description('The environments into which these resources should be created.')
@allowed([ 'dev', 'test', 'preprod', 'prod' ])
param environmentType string 
param location string 
param appServiceAppName string


var appServicePlanName = 'toy-product-launch-plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  location: location
  name: appServicePlanName
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  location: location
  name: appServiceAppName
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
