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

var sqlserverName = '${environmentType}-ToyDb-${uniqueString(resourceGroup().id)}'

var environmentConfigurationMap = {
  Production: {
    sqlDataBase: {
      sku: {
        name: 'S1'
        tier: 'Standard'
      }
    }
  }
  Test: {
    sqlDataBase: {
      sku: {
        name: 'Basic'
      }
    }
  }
}


resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlserverName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    version: '12.0'
  }
}

var databaseName = 'ToyCompanyWebsite'
resource sqlserverName_databaseName 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: environmentConfigurationMap[environmentType].sqlDataBase.sku
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource sqlServerNameAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}
