param name string
param location string
param aksVersion string = ''
param systemNodeCount int = 1
param systemNodeVmSize string = 'Standard_D2s_v3'
param laId string

resource aks 'Microsoft.ContainerService/managedClusters@2022-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  properties: {
    kubernetesVersion: aksVersion
    enableRBAC: true
    dnsPrefix: '${name}-${uniqueString(resourceGroup().id)}'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: systemNodeCount
        mode: 'System'
        vmSize: systemNodeVmSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        osDiskType: 'Managed'
        enableAutoScaling: false
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: laId
        }
        enabled: true
      }
    }
  }
}
