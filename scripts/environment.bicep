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
var storageAccountName = 'sa${projectName}${resourceNameSuffix}${environmentAbbreviation}'
var blobStorageName = 'blob-${projectName}-${resourceNameSuffix}-${environmentAbbreviation}'
var messageQueueName = 'queue-${projectName}-${resourceNameSuffix}-${environmentAbbreviation}'

// Per environment variable configurations
var environmentConfigurationMap = {
  Production: {
    environmentAbbreviation: 'prod'
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
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
    storageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  }
}

// SQL server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    version: '12.0'
  }
}

// SQL Database
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

// Database firewall restrictions
resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// App service plan for app service
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  kind: 'linux'
}

// App service to run API and website
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

// Storage account for hosting blob storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
  properties: {
    accessTier: 'Hot'
  }
}

// Blob storage containers
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for i in range(0, 2): {
  name: '${storageAccount.name}/default/storage${i}'
}]

// Inject configuration into app service
resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceApp
  name: 'connectionstrings'
  properties: {
    EvTrackingDb: {
      //value: 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};User Id=${sqlAdministratorLogin}@${sqlServer.properties.fullyQualifiedDomainName};Password=${sqlAdministratorLoginPassword};'
      value: 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlServerAdministratorLogin};Password=${sqlServerAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      type: 'SQLAzure'
    }
  }
}

output appServiceAppName string = appServiceApp.name
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
output sqlServerName string = sqlServer.properties.fullyQualifiedDomainName
