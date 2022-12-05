// ================ //
// Parameters       //
// ================ //
@description('Conditional. The name of the parent site resource. Required if the template is used in a standalone deployment.')
param appName string
param siteName string 
param kind string = 'app,linux,container'

@description('Optional. Resource ID of the app insight to leverage for this resource.')
param appInsightId string = ''

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

// =========== //
// Variables   //
// =========== //
@description('Optional. The app settings key-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.')
param appSettingsKeyValuePairs object = {
  ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
  DATABASE_HOST: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DATABASEHOST)'
  DATABASE_NAME: siteName
  DATABASE_PASSWORD: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DATABASEPASSWORD)'
  DATABASE_USER: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DATABASEUSER)'
  DOCKER_REGISTRY_SERVER_PASSWORD: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DOCKERREGISTRYSERVERPASSWORD)'
  DOCKER_REGISTRY_SERVER_URL: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DOCKERREGISTRYSERVERURL)'
  DOCKER_REGISTRY_SERVER_USERNAME: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=DOCKERREGISTRYSERVERUSERNAME)'
  GIT_BRANCH: 'master'
  GIT_REPO: 'https://github.com/judicialcouncilcalifornia/trialcourt.git'
  REDIS_HOST: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=REDISHOST)'
  REDIS_PASSWORD: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-sr1;SecretName=REDISPASSWORD)'
  REDIS_PORT: '6379'
  RESET_INSTANCE: 'false'
  WEBSITE_HTTPLOGGING_RETENTION_DAYS: '7'
  WEBSITE_PULL_IMAGE_OVER_VNET: '1'
  WEBSITE_USE_DIAGNOSTIC_SERVER: 'true'
  WEBSITES_CONTAINER_START_TIME_LIMIT: '300'
  WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'true'
  XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
  SITE_MAP_ID: siteName
  SITE_MAP_DOMAINS: '${appName}.azurewebsites.net'
  }

var appInsightsValues = {
  APPINSIGHTS_INSTRUMENTATIONKEY: 'c0f63aa2-5037-4ac4-8aab-af33114aeeaa'
  APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=c0f63aa2-5037-4ac4-8aab-af33114aeeaa;IngestionEndpoint=https://westus-0.in.applicationinsights.azure.com/;LiveEndpoint=https://westus.livediagnostics.monitor.azure.com/'
}

var expandedAppSettings = union(appSettingsKeyValuePairs, appInsightsValues)

// =========== //
// Existing resources //
// =========== //
resource app 'Microsoft.Web/sites@2020-12-01' existing = {
  name: appName
}


// =========== //
// Deployments //
// =========== //
resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource appSettings 'Microsoft.Web/sites/config@2020-12-01' = {
  name: 'appsettings'
  kind: kind
  parent: app
  properties: expandedAppSettings
}

// =========== //
// Outputs     //
// =========== //
@description('The name of the site config.')
output name string = appSettings.name

@description('The resource ID of the site config.')
output resourceId string = appSettings.id

@description('The resource group the site config was deployed into.')
output resourceGroupName string = resourceGroup().name
