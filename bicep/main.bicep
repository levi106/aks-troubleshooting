targetScope = 'subscription'

param systemResourceGroupName string = 'aksWorkshopRG'
param userBaseResourceGroupName string = 'aksWorkshopRG'
param location string = deployment().location
param vmCount int = 2
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

resource userResourceGroups 'Microsoft.Resources/resourceGroups@2021-04-01' = [for i in range(0, vmCount): {
  name: '${userBaseResourceGroupName}-user${i}'
  location: location
}]

module sql 'modules/sql.bicep' = {
  name: 'sql-${uniqueString(systemResourceGroup.id)}}'
  scope: systemResourceGroup
  params: {
    sqlServerName: 'sql-${uniqueString(systemResourceGroup.id)}}'
    dbName: 'db-${uniqueString(systemResourceGroup.id)}}'
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

module la 'modules/la.bicep' = [for i in range(0, vmCount): {
  name: 'la-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'la-${i}'
    location: location
  }
}]

module ai 'modules/ai.bicep' = [for i in range(0, vmCount): {
  name: 'ai-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'ai-${i}'
    location: location
    laId: la[i].outputs.id
  }
}]

module vnet 'modules/vnet.bicep' = [for i in range(0, vmCount): {
  name: 'vnet-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'vnet-${i}'
    location: location
    vnetPrefix: '172.17.${i}.0/16'
    subnetPrefix: '172.17.${i}.0/24'
  }
}]

module vm 'modules/vm.bicep' = [for i in range(0, vmCount): {
  name: 'vm-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'vm-${i}'
    location: location
    vnetName: vnet[i].outputs.name
    privateIPAddress: '172.17.${i}.10'
    imageReferenceId: imageReferenceId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}]

module aks 'modules/aks.bicep' = [for i in range(0, vmCount): {
  name: 'aks-${i}'
  scope: userResourceGroups[i]
  params: {
    name: 'aks-${i}'
    location: location
    laId: la[i].outputs.id
  }
}]
