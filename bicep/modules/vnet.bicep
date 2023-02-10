param name string
param location string
param vnetPrefix string
param subnetPrefix string

resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'nsg-default'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-12-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: defaultNsg.id
          }
        }
      }
    ]
  }
}

output name string = vnet.name
