param vnetName string
param subnetName string
param principalId string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetName}/${subnetName}'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subnet.id, principalId, 'Network Contributor')
  scope: subnet
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
  }
}
