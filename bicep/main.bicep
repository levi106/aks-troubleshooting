targetScope = 'subscription'

param systemResourceGroupName string = 'aksWorkshopRG'
param userBaseResourceGroupName string = 'aksWorkshopRG'
param location string = deployment().location
param numOfUsers int = 2
param imageReferenceId string
param adminUsername string = 'azureuser'
@secure()
param adminPassword string
param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string

resource systemResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: systemResourceGroupName
  location: location
}

resource userResourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for i in range(0, numOfUsers): {
  name: '${userBaseResourceGroupName}-user${i}'
  location: location
}]

module sql 'modules/sql.bicep' = {
  name: 'sql-${uniqueString(systemResourceGroup.id)}'
  scope: systemResourceGroup
  params: {
    sqlServerName: 'sql-${uniqueString(systemResourceGroup.id)}'
    dbName: 'db-${uniqueString(systemResourceGroup.id)}'
    location: location
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
  }
}

module storage 'modules/storage.bicep' = {
  name: take(replace(toLower('aksws${uniqueString(systemResourceGroup.id)}'),'-',''), 24)
  scope: systemResourceGroup
  params: {
    name: take(replace(toLower('aksws${uniqueString(systemResourceGroup.id)}'),'-',''), 24)
    location: location
  }
}

module la 'modules/la.bicep' = [for i in range(0, numOfUsers): {
  name: 'la-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'la-${i}'
    location: location
  }
}]

module ai 'modules/ai.bicep' = [for i in range(0, numOfUsers): {
  name: 'ai-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'ai-${i}'
    location: location
    laId: la[i].outputs.id
  }
}]

module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: systemResourceGroup
  params: {
    name: 'vnet'
    location: location
    numOfUsers: numOfUsers
  }
}

module vm 'modules/vm.bicep' = [for i in range(0, numOfUsers): {
  name: 'vm-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'vm-${i}'
    location: location
    subnetId: vnet.outputs.vmSubnetId
    privateIPAddress: '172.16.1.${10+i}'
    imageReferenceId: imageReferenceId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}]

module aks 'modules/aks.bicep' = [for i in range(0, numOfUsers): {
  name: 'aks-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'aks-${i}'
    location: location
    laId: la[i].outputs.id
    vnetName: vnet.name
    subnetName: vnet.outputs.aksSubnets[i].name
    subnetResourceGroupName: systemResourceGroup.name
  }
}]

module roleAssignment 'modules/roleAssignment.bicep' = [for i in range(0, numOfUsers): {
  name: 'roleassignment${i}'
  scope: systemResourceGroup
  params: {
    vnetName: vnet.name
    subnetName: vnet.outputs.aksSubnets[i].name
    principalId: aks[i].outputs.principalId
  }
}]
