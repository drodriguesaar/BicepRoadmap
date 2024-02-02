param cosmosDBAccountName string = take('toyrnd1-${uniqueString(resourceGroup().id)}', 24)

param cosmosDBDatabaseThroughput int = 400

param location string = resourceGroup().location

var cosmosDBDatabaseName = 'FlightTests'
var cosmosDBContainerName = 'FlightTests'
var cosmosDBContainerPartitionKey = '/droneId'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

//Child resource, cosmos Db Databse
resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: cosmosDBAccount //One way of defining Parent/Child resources
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  //Another way of defining nested container inside a cosmosDB Database
  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {
        throughput: cosmosDBDatabaseThroughput
      }
    }
  }
}
