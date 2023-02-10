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
