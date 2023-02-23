param name string
param location string
param aiId string
param targetUrl string
param enabled bool

resource availabilityTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: name
  location: location
  kind: 'standard'
  tags: {
    'hidden-link:${aiId}': 'Resource'
  }
  properties: {
    Name: name
    SyntheticMonitorId: name
    Enabled: enabled
    Frequency: 300
    Timeout: 30
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'apac-jp-kaw-edge'
      }
    ]
    Request: {
      RequestUrl: targetUrl
      HttpVerb: 'GET'
      ParseDependentRequests: false
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: false
      IgnoreHttpsStatusCode: false
    }
  }
}
