param baseName string = 'aks-ws-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param vnetPrefix string = '172.17.0.0/16'
param defaultSubnetPrefix string = '172.17.0.0/24'
param vmCount int = 2
param imageReferenceId string
param adminUsername string = 'azureuser'
@secure()
param adminPassword string
param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string

var vnetName = toLower('vnet-${baseName}')
var vmName = toLower('vm')
var sqlServerName = toLower('sql-${baseName}')
var dbName = toLower('db-${baseName}')
var laName = toLower('la-${baseName}')
var aiName = toLower('ai-${baseName}')
var aksName = toLower(baseName)
var storageName = take(replace(toLower('${baseName}'),'-',''), 24)

resource la 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: laName
  location: location
}

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: aiName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: la.id
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
}

module vnet 'modules/vnet.bicep' = {
  name: vnetName
  scope: resourceGroup()
  params: {
    name: vnetName
    location: location
    vnetPrefix: vnetPrefix
    subnetPrefix: defaultSubnetPrefix
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${vnet.name}/default'
}

module vm 'modules/vm.bicep' = [for i in range(0, vmCount): {
  name: '${vmName}-${i}'
  scope: resourceGroup()
  params: {
    name: '${vmName}-${i}'
    location: location
    subnetId: subnet.id
    privateIPAddress: '172.17.0.1${i}'
    imageReferenceId: imageReferenceId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}]

module sql 'modules/sql.bicep' = {
  name: sqlServerName
  scope: resourceGroup()
  params: {
    sqlServerName: sqlServerName
    dbName: dbName
    location: location
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
  }
}

module aks 'modules/aks.bicep' = {
  name: aksName
  scope: resourceGroup()
  params: {
    name: aksName
    location: location
    laId: la.id
  }
}
