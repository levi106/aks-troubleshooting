param aksName string
param principalId string

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-01' existing = {
  name: aksName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(aks.id, principalId, 'Azure Kubernetes Cluster Admin Role')
  scope: aks
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')
  }
}
