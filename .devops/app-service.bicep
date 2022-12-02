//  --- this is Kyle'  pile of var from other templates in the event he needs them
//var appService1 = 'nprd-ctcms-ct1-app${uniqueMod}'
//var cDNProfileFrontDoor1 = 'nprd-ctcms-fd'
//var cDNProfileFrontDoorOriginGroup1 = 'df1-ct1-fd-orggrp'
//var cDNProfileFrontDoorOriginGroupOrigin1 = 'df1-ct1-fd-origin'
//var resourceGroup2 = 'nprd-ctcms-${dfN}-app-rg'
//var resourceGroup3 = 'nprd-ctcms-${dfN}-admin-rg'
//var appService1 = 'nprd-ctcms-ct1-app${uniqueMod}'
//var networkPrivateEndpoint3_var = 'nprd-ctcms-ct1-app-pe'
//var networkPrivateEndpointPrivateDnsZoneGroup3 = 'nprd-ctcms-ct1-app-pe-dns'
//var appDns = 'privatelink.azurewebsites.net'
//var resourceGroup3 = 'nprd-ctcms-${dfN}-app-rg'
//var appService1_var = 'nprd-ctcms-ct1-app${uniqueMod}'
//var appServiceConfigRegionalVirtualNetworkIntegration1 = 'virtualNetwork'


@allowed([
  '1'
  '2'
  '3'
])
param siteFarmId string = '1'
param siteId string = '009'
param cmLocation string = resourceGroup().location
param siteName string = ''
param uniqueMod string = ''
param subscriptionId string = '539516a7-6f4e-450d-b99e-be9dcc48a4c4'

@allowed([
  'nprd'
  'uat'
  'prod'
])
param env string = 'nprd'

var appService = '${env}-ctcms-ct${siteId}-app'
var webServerfarm = '${env}-ctcms-df${siteFarmId}-asp'


var resourceGroupNet = '${env}-ctcms-df${siteFarmId}-net-rg'
var dfVirtualNetwork = '${env}-ctcms-df${siteFarmId}-vnet'
var aspsubnet = 'df${siteFarmId}-asp-sn'

var networkPrivateEndpoint3_var = '${env}-ctcms-ct${siteId}-app-pe'
var resourceGroupApp = '${env}-ctcms-df${siteFarmId}-app-rg'
var resourceGroupNetRg = '${env}-ctcms-net-rg'

var appServiceInsightsDiagnosticSetting1_var = 'nprd-ctcms-ct1-diag'

var storageAccountName = '${env}ctcmsdf${siteFarmId}}sa${uniqueMod}'
var shareName = 'courtsfileshare'
var mountPath = '/storage/files'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
scope: resourceGroup('${env}-ctcms-df${siteFarmId}-data-rg')
name: storageAccountName
}

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
          value: 'supdevmdb01.mariadb.database.azure.com'
        }
        {
          name: 'DATABASE_NAME'
          value: siteName
        }
        {
          name: 'DATABASE_PASSWORD'
          value: 'AdamTheGreat1!'
        }
        {
          name: 'DATABASE_USER'
          value: 'azuremdb@supdevmdb01'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: '5Q+HLzRMaHGF=weHScWHkwp65wtvZ3or'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://devopswebcourtsnp.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: 'devopswebcourtsnp'
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
          value: 'supdev.redis.cache.windows.net'
        }
        {
          name: 'REDIS_PASSWORD'
          value: 'Ji1AizWN74MT4G0wRLMxOZICFsUVro93QAzCaJXe6nE='
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
          value: siteName
        }
        {
          name: 'SITE_MAP_DOMAINS'
          value: '${env}-ctcms-ct${siteId}-app.azurewebsites.net'
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
    virtualNetworkSubnetId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupNetRg}/providers/Microsoft.Network/virtualNetworks/${dfVirtualNetwork}/subnets/${aspsubnet}'
  }
}

resource storageSetting 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${appService1}/azurestorageaccounts'
  properties: {
    '${shareName}': {
      type: 'AzureFiles'
      shareName: shareName
      mountPath: mountPath
      accountName: storageAccountName
    }
  }
}

resource appService1_appServiceConfigRegionalVirtualNetworkIntegration1 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appService1
  name: 'appsettings'
  properties: {
    subnetResourceId: resourceId(resourceGroupNet, 'Microsoft.Network/virtualNetworks/subnets', dfVirtualNetwork, aspsubnet)
  }
}

resource appServiceInsightsDiagnosticSetting1 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: appService1
  name: appServiceInsightsDiagnosticSetting1_var
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: []
    metrics: []
    storageAccountId: resourceId(resourceGroup1, 'Microsoft.Storage/storageAccounts', storageAccount1)
    workspaceId: resourceId(resourceGroup1, 'Microsoft.OperationalInsights/workspaces', operationalInsightsWorkspace1)
  }
}






// this is where glen had it###KCP

/*
resource appService1_appServiceConfigRegionalVirtualNetworkIntegration1 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appService1
  name: 'appsettings'
  properties: {
    subnetResourceId: resourceId(resourceGroupNet, 'Microsoft.Network/virtualNetworks/subnets' dfVirtualNetwork1, subnet1)
  }
  dependsOn: [
    appService1
  ]
}

resource appServiceInsightsDiagnosticSetting1 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: appService1
  name: appServiceInsightsDiagnosticSetting1_var
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: []
    metrics: []
    storageAccountId: resourceId(resourceGroup1, 'Microsoft.Storage/storageAccounts', storageAccount1)
    workspaceId: resourceId(resourceGroup1, 'Microsoft.OperationalInsights/workspaces', operationalInsightsWorkspace1)
  }
}

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint3_var
  location: cmLocation
  properties: {
    aspsubnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets' dfVirtualNetwork1, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroupApp, 'Microsoft.Web/sites', appService)
          groupIds: [
            'sites'
          ]
        }
        name: '${environtment}-ctcms-ct${siteId}-app-pe'
      }
    ]
  }
  dependsOn: [
    appService1
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1 'Microsoft.Cdn/profiles/originGroups@2021-06-01' existing = {
  name: '${cDNProfileFrontDoorOriginGroup1}'
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  //parent: cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1
  name: '${cDNProfileFrontDoor1}/${cDNProfileFrontDoorOriginGroup1}/${cDNProfileFrontDoorOriginGroupOrigin1}'
  properties: {
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    hostName: '${appService}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 100
    sharedPrivateLinkResource: {
      groupId: 'sites'
      privateLink: {
        // id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupApp}/providers/Microsoft.Web/sites/${appService}'
        id: resourceId(resourceGroup2, 'Microsoft.Web/sites', appService)
      }
      privateLinkLocation: cmLocation
      requestMessage: 'AutomationRequest'
    }
  }
}

*/

