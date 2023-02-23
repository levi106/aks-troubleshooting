param aksName string
param location string

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-01' existing = {
  name: aksName
}

resource target 'Microsoft.ContainerService/managedClusters/providers/targets@2021-09-15-preview' = {
  name: '${aksName}/Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh'
  location: location
  dependsOn: [aks]
  properties: {}
}

resource networkChaos 'Microsoft.ContainerService/managedClusters/providers/targets/capabilities@2021-09-15-preview' = {
  name: '${aksName}/Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/NetworkChaos-2.1'
  location: location
  dependsOn: [target]
  properties: {}
}

resource podChaos 'Microsoft.ContainerService/managedClusters/providers/targets/capabilities@2021-09-15-preview' = {
  name: '${aksName}/Microsoft.Chaos/Microsoft-AzureKubernetesServiceChaosMesh/PodChaos-2.1'
  location: location
  dependsOn: [target]
  properties: {}
}
