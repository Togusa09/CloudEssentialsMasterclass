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

@description('Select the type of environment you want to provision. Allowed values are Production and Test.')
@allowed([
  'Production'
  'Test'
  'Development'
])
param environmentType string


@description('Location for all resources.')
param location string = resourceGroup().location

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

param linuxFxVersion string = 'DOTNETCORE|7.0' // The runtime stack of web app

@description('The name of the project.')
param projectName string = 'AzureMasterclass'

@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

// Define the names for resources.
var environmentAbbreviation = environmentConfigurationMap[environmentType].environmentAbbreviation
// var keyVaultName = 'kv-${projectName}-${environmentAbbreviation}'
var appServiceAppName = 'as-${projectName}-${resourceNameSuffix}-${environmentAbbreviation}'
var appServicePlanName = 'plan-${projectName}-${environmentAbbreviation}'
// var logAnalyticsWorkspaceName = 'log-${projectName}-${environmentAbbreviation}'
// var applicationInsightsName = 'appi-${projectName}-${environmentAbbreviation}'
var sqlServerName = 'sql-${projectName}-${resourceNameSuffix}-${environmentAbbreviation}'
var sqlDatabaseName = '${projectName}-${environmentAbbreviation}'

var environmentConfigurationMap = {
  Production: {
    environmentAbbreviation: 'prod'
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 1
      }
    }
    // storageAccount: {
    //   sku: {
    //     name: 'Standard_LRS'
    //   }
    // }
    sqlDatabase: {
      sku: {
        name: 'Standard'
        tier: 'Standard'
      }
    }
  }
  Development: {
    environmentAbbreviation: 'dev'
    appServicePlan: {
      sku: {
        name: 'F1'
      }
    }
    // storageAccount: {
    //   sku: {
    //     name: 'Standard_GRS'
    //   }
    // }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  sku: environmentConfigurationMap[environmentType].sqlDatabase.sku
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
  }
}

resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  kind: 'linux'
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
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
