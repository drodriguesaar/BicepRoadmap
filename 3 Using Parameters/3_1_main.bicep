@description('The name of the environment. This must be dev, test or prod')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The name of the solution')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('The number of instances accepted by the service plan')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@secure()
@description('The administrator login username for the SQL server')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL databse SKU')
param sqlDatabaseSKU object

var sqlServerName = '${environmentName}-${solutionName}'
var sqlDatabaseName = 'Employees'

@description('The name and tier of the App Service plan SKU')
param appServicePlanSKU object

@description('The Azure region into which the resources should be deployed')
param location string = 'westus3'

var appServicePlanName = '${environmentName}-${solutionName}'
var appServiceAppName = '${environmentName}-${solutionName}'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSKU.name
    tier: appServicePlanSKU.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDataBase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSKU.name
    tier: sqlDatabaseSKU.tier
  }
}

//az keyvault create --name $keyVaultName -g Demo1 --location westus --enabled-for-template-deployment true 
