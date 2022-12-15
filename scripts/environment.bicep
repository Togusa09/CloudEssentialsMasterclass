@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@description('Location for all resources.')
param location string = resourceGroup().location

param webAppName string = uniqueString(resourceGroup().id)

param linuxFxVersion string = 'DOTNETCORE|7.0' // The runtime stack of web app

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: toLower('AppServicePlan-${webAppName}')
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
  }
  kind: 'linux'
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: toLower('wapp-${webAppName}')
  location: location
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      //netFrameworkVersion: 'v7.0'
      linuxFxVersion: linuxFxVersion
    }
  }
}

output appServiceAppName string = appServiceApp.name
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
