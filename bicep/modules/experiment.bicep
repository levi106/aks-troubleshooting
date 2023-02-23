param name string
param location string
param targets array
param jsonSpec string
param duration string

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
        targets: targets
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
                duration: duration
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

output principalId string = experiment.identity.principalId
