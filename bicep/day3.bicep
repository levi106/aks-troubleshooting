targetScope = 'subscription'

param userBaseResourceGroupName string = 'aksWorkshopRG'
param location string = deployment().location
param serviceIPs array
param numOfUsers int

resource userResourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for i in range(0, numOfUsers): {
  name: '${userBaseResourceGroupName}-user${i}'
}]

resource ai 'Microsoft.Insights/components@2020-02-02' existing = [for i in range(0, numOfUsers): {
  name: 'ai-${i}'
  scope: userResourceGroups[i]
}]

module webtest 'modules/webtest.bicep' = [for i in range(0, numOfUsers): {
  name: 'webtest-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'webtest-${i}'
    location: location
    aiId: ai[i].id
    targetUrl: 'http://${serviceIPs[i]}:8080/db'
    enabled: false
  }
}]
