param name string
param location string
param aksVersion string = ''
param systemNodeCount int = 2
param systemNodeVmSize string = 'Standard_D2s_v3'
param laId string
param vnetName string
param subnetName string
param subnetResourceGroupName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup(subnetResourceGroupName)
}

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
        vnetSubnetID: subnet.id
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.0.0.10'
      serviceCidr: '10.0.0.0/16'
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

output principalId string = aks.identity.principalId
