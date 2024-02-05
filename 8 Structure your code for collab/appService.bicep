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

var appServiceAppName = 'toyApp${uniqueString(resourceGroup().id)}'

var appServicePlanName = take('toyAppServicePlan${uniqueString(resourceGroup().id)}', 24)

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

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  tags: tags
}

resource AppInsightsWebSiteName 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
  }
}

resource appUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: appUserAssignedIdentityName
  location: location
  tags: tags
}

resource webSite 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: (environmentType != 'Production') ? [] : [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsightsWebSiteName.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${appInsightsStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(appInsightsStorageAccountId, appInsightsStorageAccountApiVersion).keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appUserAssignedIdentity.id}': {}
    }
  }
}

resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(contributorRoleDefinitionId, resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: appUserAssignedIdentity.properties.principalId
  }
}


