param location string ='eastus'
param appserviceplanname string = 'myappservice'
@description('The SKU for the App Service Plan')
@allowed([
  'F1' ,'D1'
  'B1' ,'B2' ,'B3'
  'S1' ,'S2' ,'S3'
  'P1v2' ,'P2v2' ,'P3v2'
  'P1v3' ,'P2v3' ,'P3v3'
  'I1' ,'I2' ,'I3'
  'I1v2' ,'I2v2' ,'I3v2'
])

param skuName string = 'P1v2'
param webappName string = 'first-webapp-1-deploy'
@description('The scaling rule threshold for CPU usage')
param cpuThreshold int = 70
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appserviceplanname
  location: location
  sku: {
    name: skuName
    capacity: 1
  }
}
resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: webappName
  location: location
  
  properties: {
    serverFarmId:appServicePlan.id
    httpsOnly:true
  }
}
resource appInsightsAutoScaleSettings 'Microsoft.Insights/autoscalesettings@2015-04-01' = {
  name: 'autoscaling'
  location: location
  tags: {
    Application_Type: 'web'
    'hidden-link:appServiceId': 'Resource'
  }
  properties: {

    profiles: [
      {
        name: 'defaultProfile'
        capacity: {
          minimum: '1'
          maximum: '5'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'cpupercentage'
              metricNamespace:'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: cpuThreshold
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value:  '1'
              cooldown: 'PT10M'
            }
          }
          {
            metricTrigger: {
              metricName: 'cpupercentage'
              metricNamespace:'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT1H'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1H'
            }
          }
        ]
      }
    ]
    enabled: false
    targetResourceUri: appServicePlan.id
  }
}
