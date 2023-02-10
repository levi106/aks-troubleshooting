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

resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name: dbName
  parent: sqlServer
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 100
  }
}
