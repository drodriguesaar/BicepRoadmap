@description('The location into which the resource will be deployed. Default value will be the location of the target resource group.')
param location string = resourceGroup().location

@allowed([
  'Production'
  'Test'
])
@description('The type of environment you will provision your azure resources')
param environmentType string

@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

@description('The role definition id for the managed identity. Default value is Contributor Role.')
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

param storageAccountName string = 'toywebsite${uniqueString(resourceGroup().id)}'

module storageAccount 'storageAccount.bicep' = {
  name: 'toyWebsiteStorageAccount'
  params: {
    environmentType: environmentType
    location: location
    storageAccountName: storageAccountName
  }
}

module dataBase 'dataBase.bicep' = {
  name: 'toyWebsiteDataBase'
  params: {
    environmentType: environmentType
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
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
