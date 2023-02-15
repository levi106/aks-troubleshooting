param name string
param location string

resource pip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    dnsSettings: {
      domainNameLabel: '${name}-${uniqueString(resourceGroup().id)}'
    }
    publicIPAllocationMethod: 'Static'
  }
}
