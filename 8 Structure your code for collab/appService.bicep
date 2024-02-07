@description('The location into which the resource will be deployed. Default value will be the location of the target resource group.')
param location string = resourceGroup().location

@allowed([
  'Production'
  'Test'
])
@description('The type of environment you will provision your azure resources')
param environmentType string

@description('The role definition id for the managed identity. Default value is Contributor Role.')
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Storage acccount name for storing app insights data')
param appInsightsStorageAccountName string

@description('Storage acccount id for storing app insights data')
param appInsightsStorageAccountId string

@description('Storage acccount api version for storing app insights data')
param appInsightsStorageAccountApiVersion string

var appUserAssignedIdentityName = guid(contributorRoleDefinitionId, resourceGroup().id)

var appServiceAppName = '${environmentType}-ToyApp-${uniqueString(resourceGroup().id)}'

var appServicePlanName = '${environmentType}-ToySrvPlan-${uniqueString(resourceGroup().id)}'

var tags = {
  environment: environmentType
}

@description('Define the SKUs for each component based on the environment type.')
var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'P2V3'
        capacity: 3
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
  }
}

var isProduction = (environmentType == 'Production')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  tags: tags
}

resource appInsightsWebSiteName 'Microsoft.Insights/components@2020-02-02' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
  }
}

resource appUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: appUserAssignedIdentityName
  location: location
  tags: tags
}

resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: (isProduction) ? [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsWebSiteName.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${appInsightsStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(appInsightsStorageAccountId, appInsightsStorageAccountApiVersion).keys[0].value}'
        }
      ] : []
    }
  }
}
