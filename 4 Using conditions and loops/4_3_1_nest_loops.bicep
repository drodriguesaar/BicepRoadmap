@description('The Azure region into which the resources should be deployed')
param location string = resourceGroup().location

var subnetList = [for i in range(1, 2): {
  name: 'subnet-${i}'
  properties: {
    addressPrefix: '10.0.${i}.0/24'
  }
}]

var virtualNetworkList = [
  { name: 'vnet1', location: location, subnets: subnetList }
  { name: 'vnet2', location: location, subnets: subnetList }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-06-01' = [for vNet in virtualNetworkList: {
  name: vNet.vnetName
  location: vNet.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: vNet.subnets
  }
}]
