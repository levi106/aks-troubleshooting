param sqlServerName string
param dbName string
param location string
param adminUsername string
@secure()
param adminPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource fwrule 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name: dbName
  parent: sqlServer
  location: location
  sku: {
    name: 'Basic'
  }
}
