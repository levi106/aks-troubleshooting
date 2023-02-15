param name string
param location string
param numOfUsers int = 1

resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'nsg-vmsubnet'
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

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'nsg-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
          destinationPortRanges: ['8080','5701']
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          destinationPortRanges: ['22','3389']
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
          destinationPortRanges: ['8080','5701']
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

resource aksSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = [for i in range(0, numOfUsers): {
  name: 'nsg-aks-${i}'
  location: location
}]

var aksSubnetConfigurations = [for i in range(0, numOfUsers): {
  name: 'aksSubnet${i}'
  addressPrefix: '172.16.${(i+1)*4}.0/23'
  nsgId: aksSubnetNsg[i].id
}]

var subnetConfigurations = concat([
  {
    name: 'vmSubnet'
    addressPrefix: '172.16.1.0/24'
    nsgId: vmSubnetNsg.id
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '172.16.2.0/24'
    nsgId: bastionNsg.id
  }
], aksSubnetConfigurations)

resource vnet 'Microsoft.Network/virtualNetworks@2019-12-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    subnets: [for (config,i) in subnetConfigurations: {
      name: config.name
      properties: {
        addressPrefix: config.addressPrefix
        networkSecurityGroup: {
          id: config.nsgId
        }
      }
    }]
  }
}

resource aksSubnets 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = [for i in range(0, numOfUsers): {
  name: 'aksSubnet${i}'
  parent: vnet
}]

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: 'vmSubnet'
  parent: vnet
}

output name string = vnet.name
output id string = vnet.id
output vmSubnetId string = vmSubnet.id
output aksSubnets array = [for i in range(0, numOfUsers): {
  name: aksSubnets[i].name
  id: aksSubnets[i].id
}]
