param siteFarmId string = '1'
param env string = 'nprd'
param siteId string = '001'
param siteName string = ''
param uniqueMod string = '42'
param subscriptionId string = subscription().subscriptionId
param cmLocation string = resourceGroup().location

var appService = '${env}-ctcms-ct${siteId}-app${uniqueMod}'
var webServerfarm = '${env}-ctcms-df${siteFarmId}-asp'
var operationalInsightsWorkspace1 = 'nprd-ctcms-law'
var admResourceGroup = 'nprd-ctcms-admin-rg'
var resourceGroupNet = '${env}-ctcms-df${siteFarmId}-net-rg'
var dfVirtualNetwork = '${env}-ctcms-df${siteFarmId}-vnet'
var aspsubnet = 'df${siteFarmId}-asp-sn'

var networkPrivateEndpoint3_var = '${env}-ctcms-ct${siteId}-app-pe'
var resourceGroupApp = '${env}-ctcms-df${siteFarmId}-app-rg'
var resourceGroupData = '${env}-ctcms-df${siteFarmId}-data-rg'
var appServiceInsightsDiagnosticSetting1_var = 'nprd-ctcms-ct1-diag'

var siteStorageAccountName = '${env}ctcmsdf${siteFarmId}sa${uniqueMod}'
var admStorageAccountName = '${env}ctcmsadmsa${uniqueMod}'
var shareName = 'courtsfileshare'
var mountPath = '/storage/files'


resource siteStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
scope: resourceGroup('${env}-ctcms-df${siteFarmId}-data-rg')
name: siteStorageAccountName
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
          value: '${appService}.azurewebsites.net'
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
    virtualNetworkSubnetId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupNet}/providers/Microsoft.Network/virtualNetworks/${dfVirtualNetwork}/subnets/${aspsubnet}'
  }
}


resource storageSetting 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: appService1
  name: 'azurestorageaccounts'
  properties: {
    '${shareName}': {
      type: 'AzureFiles'
      shareName: shareName
      mountPath: mountPath
      accountName: siteStorageAccountName
      accessKey: '${listKeys(siteStorageAccount.id, siteStorageAccount.apiVersion).keys[0].value}'
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
    storageAccountId: resourceId(admResourceGroup, 'Microsoft.Storage/storageAccounts', admStorageAccountName)
    workspaceId: resourceId(admResourceGroup, 'Microsoft.OperationalInsights/workspaces', operationalInsightsWorkspace1)
  }
}

/* - MI role assignment to implement
resource dataDfResourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  scope: subscription()
  name: resourceGroupData
}

@description('Specifies the role definition ID (contrib) used in the role assignment.')
var roleDefinitionID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the principal ID assigned to the role.')
var principalId = appService1.identity.principalId

var roleAssignmentName= guid(appService1.name, roleDefinitionID, resourceGroup().id)


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    scope: dataDfResourceGroup
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
  }
}
*/


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
    storageAccountId: resourceId(admresourceGroup, 'Microsoft.Storage/storageAccounts', storageAccount1)
    workspaceId: resourceId(admresourceGroup, 'Microsoft.OperationalInsights/workspaces', operationalInsightsWorkspace1)
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
          value: '${appService}.azurewebsites.net'
        }



*/

