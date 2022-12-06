param siteFarmId string
param env string
param siteId string
param siteName string
param uniqueMod string
param subscriptionId string = subscription().subscriptionId
param cmLocation string = resourceGroup().location
//param umiId string

var appService = '${env}-ctcms-ct${siteId}-app${uniqueMod}'
var webServerfarm = '${env}-ctcms-df${siteFarmId}-asp'
var operationalInsightsWorkspace1 = '${env}-ctcms-law'
var admResourceGroup = '${env}-ctcms-admin-rg'
var resourceGroupNet = '${env}-ctcms-df${siteFarmId}-net-rg'
var dfVirtualNetwork = '${env}-ctcms-df${siteFarmId}-vnet'
var aspsubnet = 'df${siteFarmId}-asp-sn'

var networkPrivateEndpoint3_var = '${env}-ctcms-ct${siteId}-app-pe'
var resourceGroupApp = '${env}-ctcms-df${siteFarmId}-app-rg'
var resourceGroupData = '${env}-ctcms-df${siteFarmId}-data-rg'
var appServiceInsightsDiagnosticSetting1_var = '${env}-ctcms-ct${siteId}-diag'

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
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscriptionId}/resourceGroups/${admResourceGroup}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userMiId-${env}': {}
    }
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
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DATABASEHOST)'
        }
        {
          name: 'DATABASE_NAME'
          value: siteName
        }
        {
          name: 'DATABASE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DATABASEPASSWORD)'
        }
        {
          name: 'DATABASE_USER'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DATABASEUSER)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DOCKERREGISTRYSERVERPASSWORD)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DOCKERREGISTRYSERVERURL)'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=DOCKERREGISTRYSERVERUSERNAME)'
        }
        {
          name: 'GIT_BRANCH'
          value: 'master'
        }
        {
          name: 'GIT_REPO'
          value: 'https://github.com/judicialcouncilcalifornia/trialcourt.git'
        }
        {
          name: 'REDIS_HOST'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=REDISHOST)'
        }
        {
          name: 'REDIS_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${env}-ctcms-df${siteFarmId}-kv${uniqueMod};SecretName=REDISPASSWORD)'
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

/* - System Managed Identity - deprecated to use User MI 
@description('Specifies the role definition ID (contrib) used in the role assignment.')
var roleDefinitionID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the principal ID assigned to the role.')
var principalId = appService1.identity.principalId

module ResourceGroupRoleAssignment './role-assign.bicep' = {
  name: 'ResourceGroupRoleAssignment'
  scope: resourceGroup(resourceGroupData)
  params: {
    PrincipalId: principalId
    RoleDefinitionId: roleDefinitionID
  }
}

*/
