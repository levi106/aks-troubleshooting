targetScope = 'subscription'

param systemResourceGroupName string = 'aksWorkshopRG'
param userBaseResourceGroupName string = 'aksWorkshopRG'
param location string = deployment().location
param serviceIPs array
param numOfUsers int

var jsonSpec = '{"action":"loss","mode":"all","selector":{"namespaces":["day2"],"labelSelectors":{"app":"webapp"}},"loss":{"loss":"100","correlation":"100"},"direction":"to","externalTargets":["0.0.0.0/1:1433","128.0.0.0/1:1433"],"duration":"30m"}'
var chaosName = 'day2Exp'
var targets = [for i in range(0, numOfUsers): {
  type: 'ChaosTarget'
  id: '${subscription().id}/resourceGroups/${userBaseResourceGroupName}-user${i}/providers/Microsoft.ContainerService/managedClusters/aks-${i}'
}]

resource systemResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: systemResourceGroupName
}

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

module chaos 'modules/chaos.bicep' = {
  name: chaosName
  scope: systemResourceGroup
  params: {
    name: chaosName
    location: location
    targets: targets
    jsonSpec: jsonSpec
  }
}

