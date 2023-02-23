param name string
param location string
param chaosTargetResourceIds array
param jsonSpec string

resource experiment 'Microsoft.Chaos/experiments@2022-10-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    startOnCreation: false
    selectors: [
      {
        id: 'Selector1'
        type: 'List'
        targets: [for id in chaosTargetResourceIds: {
          type: 'ChaosTarget'
          id: id
        }]
      }
    ]
    steps: [
      {
        name: 'Step1'
        branches: [
          {
            name: 'Branch1'
            actions: [
              {
                duration: 'PT10M'
                selectorId: 'Selector1'
                type: 'continuous'
                name: 'urn:csci:microsoft:azureKubernetesServiceChaosMesh:networkChaos/2.1'
                parameters: [
                  {
                    key: 'jsonSpec'
                    value: jsonSpec
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
