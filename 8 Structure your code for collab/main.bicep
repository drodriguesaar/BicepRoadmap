@description('The location into which the resource will be deployed. Default value will be the location of the target resource group.')
param location string = resourceGroup().location

@allowed([
  'Production'
  'Test'
])
@description('The type of environment you will provision your azure resources')
param environmentType string

@secure()
param sqlServerAdministratorLogin string

@secure()
param sqlServerAdministratorLoginPassword string

@secure()
@description('The role definition id for the managed identity. Default value is Contributor Role.')
param contributorRoleDefinitionId string

module storageAccount 'storageAccount.bicep' = {
  name: 'toyWebsiteStorageAccount'
  params: {
    environmentType: environmentType
    location: location
  }
}

module dataBase 'dataBase.bicep' = {
  name: 'toyWebsiteDataBase'
  params: {
    environmentType: environmentType
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
    location: location
  }
}

module appService 'appService.bicep' = {
  name: 'toyWebSiteAppService'
  params: {
    appInsightsStorageAccountApiVersion: storageAccount.outputs.storageAccounApiVersion
    appInsightsStorageAccountId: storageAccount.outputs.storageAccountId
    appInsightsStorageAccountName: storageAccount.outputs.storageAccountName
    environmentType: environmentType
    location: location
    contributorRoleDefinitionId: contributorRoleDefinitionId
  }
}
