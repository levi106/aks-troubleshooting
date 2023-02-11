param name string
param location string
param laId string

resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: laId
  }
}

output name string = ai.name
output id string = ai.id
