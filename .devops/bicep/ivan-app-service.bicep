@allowed([
  '1'
  '2'
  '3'
])
param siteFarmId string = '1'
param siteId string = '009'
param cmLocation string = resourceGroup().location
param siteName string = ''

@allowed([
  'nprd'
  'uat'
  'prod'
])
param environment string = 'nprd'

var appService = '${environment}-ctcms-ct${siteId}-app'
var webServerfarm = '${environment}-ctcms-df${siteFarmId}-asp'

var resourceGroupNet = '${environment}-ctcms-df${siteFarmId}-net-rg'
var virtualNetwork1 = '${environment}-ctcms-df${siteFarmId}-vnet'
var subnet1 = 'df${siteFarmId}-asp-sn'

var networkPrivateEndpoint3_var = '${environment}-ctcms-ct${siteId}-app-pe'
var resourceGroupApp = '${environment}-ctcms-df${siteFarmId}-app-rg'
// var resourceGroupNetRg = '${environment}-ctcms-net-rg'
var resourceGroupNetRg = '${environment}-ctcms-df${siteFarmId}-net-rg'

var cDNProfileFrontDoor1 = '${environment}-ctcms-fd'
var cDNProfileFrontDoorOriginGroup1 = 'df${siteFarmId}-ct${siteId}-fd-orggrp'
var cDNProfileFrontDoorOriginGroupOrigin1 = 'df${siteFarmId}-ct${siteId}-fd-origin'

// Non-Prod
// var subscriptionId = '539516a7-6f4e-450d-b99e-be9dcc48a4c4'
// POC
var subscriptionId = '981cd141-7390-4618-808e-7c57fcf96d93'

var storageAccountName = '${environment}ctcmsdf${siteFarmId}sa'
var shareName = 'courtsfileshare'
var mountPath = '/storage/files'

resource appService1 'Microsoft.Web/sites@2020-12-01' = {
  name: appService
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app,linux,container'
  location: cmLocation
  properties: {
    enabled: true
    httpsOnly: true
    redundancyMode: 'None'
    reserved: true
    serverFarmId: resourceId('Microsoft.Web/serverfarms', webServerfarm)
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: 'c0f63aa2-5037-4ac4-8aab-af33114aeeaa'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=c0f63aa2-5037-4ac4-8aab-af33114aeeaa;IngestionEndpoint=https://westus-0.in.applicationinsights.azure.com/;LiveEndpoint=https://westus.livediagnostics.monitor.azure.com/'
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DATABASE_HOST'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DATABASEHOST)'
        }
        {
          name: 'DATABASE_NAME'
          value: '${siteName}'
        }
        {
          name: 'DATABASE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DATABASEPASSWORD)'
        }
        {
          name: 'DATABASE_USER'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DATABASEUSER)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DOCKERREGISTRYSERVERPASSWORD)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DOCKERREGISTRYSERVERURL)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=DOCKERREGISTRYSERVERUSERNAME)'
        }
        {
          name: 'GIT_BRANCH'
          value: 'master'
        }
        {
          name: 'GIT_REPO'
          value: 'https://github.com/JudicialCouncilOfCalifornia/trialcourt'
        }
        {
          name: 'REDIS_HOST'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=REDISHOST)'
        }
        {
          name: 'REDIS_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=nprd-ctcms-df1-kv-01;SecretName=REDISPASSWORD)'
        }
        {
          name: 'REDIS_PORT'
          value: '6379'
        }
        {
          name: 'RESET_INSTANCE'
          value: 'false'
        }
        {
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '7'
        }
        {
          name: 'WEBSITE_PULL_IMAGE_OVER_VNET'
          value: '1'
        }
        {
          name: 'WEBSITE_USE_DIAGNOSTIC_SERVER'
          value: 'true'
        }
        {
          name: 'WEBSITES_CONTAINER_START_TIME_LIMIT'
          value: '300'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'true'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        {
          name: 'SITE_MAP_ID'
          value: '${siteName}'
        }
        {
          name: 'SITE_MAP_DOMAINS'
          value: '${environment}-ctcms-ct${siteId}-app.azurewebsites.net'
        }
      ]
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
      connectionStrings: []
      defaultDocuments: []
      ftpsState: 'Disabled'
      handlerMappings: []
      ipSecurityRestrictions: []
      loadBalancing: 'LeastResponseTime'
      minTlsVersion: '1.2'
      scmIpSecurityRestrictions: []
    }
    //virtualNetworkSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupNetRg}/providers/Microsoft.Network/virtualNetworks/${environment}-ctcms-df${siteFarmId}-vnet/subnets/df${siteFarmId}-asp-sn'
    //virtualNetworkSubnetId: '/subscriptions/981cd141-7390-4618-808e-7c57fcf96d93/resourceGroups/nprd-ctcms-df1-net-rg/providers/Microsoft.Network/virtualNetworks/nprd-ctcms-df1-vnet/subnets/df1-asp-sn'
  }
}
