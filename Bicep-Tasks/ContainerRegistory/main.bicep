param location string
param acrName string
@allowed([
  'Basic' 
  'Premium' 
  'Standard'
]  
)
param skuName string
resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name:acrName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
  }
}
output arcLoginServer string =acr.properties.loginServer
