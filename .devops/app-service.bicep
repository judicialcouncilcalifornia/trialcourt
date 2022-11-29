@allowed([
  '1'
  '2'
  '3'
])
param deploymentFarm string = '1'
param siteId string = '008'

@allowed([
  'nprd'
  'stage'
  'prod'
])
param environment string = 'nprd'

var appService_var = '${environment}-ctcms-ct${siteId}-app'
var webServerfarm = '${environment}-ctcms-df${deploymentFarm}-asp'

var resourceGroup2 = 'nprd-ctcms-df1-net-rg'
var virtualNetwork1 = 'nprd-ctcms-df1-vnet'
var subnet1 = 'df1-asp-sn'

var networkPrivateEndpoint3_var = 'nprd-ctcms-ct1-app-pe'
var resourceGroup3 = 'nprd-ctcms-df1-app-rg'

var cDNProfileFrontDoor1 = 'nprd-ctcms-fd'
var cDNProfileFrontDoorOriginGroup1 = 'df1-ct1-fd-orggrp'
var cDNProfileFrontDoorOriginGroupOrigin1 = 'df1-ct1-fd-origin'
var subscription = '539516a7-6f4e-450d-b99e-be9dcc48a4c4'

resource appService1 'Microsoft.Web/sites@2020-12-01' = {
  name: appService_var
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app,linux,container'
  location: resourceGroup().location
  properties: {
    enabled: true
    httpsOnly: true
    redundancyMode: 'None'
    reserved: true
    serverFarmId: resourceId('Microsoft.Web/serverfarms', webServerfarm)
    siteConfig: {
      alwaysOn: true
      appSettings: []
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
      connectionStrings: []
      defaultDocuments: []
      ftpsState: 'FtpsOnly'
      handlerMappings: []
      ipSecurityRestrictions: []
      loadBalancing: 'LeastResponseTime'
      minTlsVersion: '1.2'
      scmIpSecurityRestrictions: []
    }
    virtualNetworkSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/nprd-ctcms-net-rg/providers/Microsoft.Network/virtualNetworks/nprd-ctcms-df${deploymentFarm}-vnet/subnets/df${deploymentFarm}-asp-sn'
  }
}

resource appService1_appServiceConfigRegionalVirtualNetworkIntegration1 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appService1
  name: 'appsettings'
  properties: {
    subnetResourceId: resourceId(resourceGroup2, 'Microsoft.Network/virtualNetworks/subnets', virtualNetwork1, subnet1)
  }
  dependsOn: [
    appService1
  ]
}

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint3_var
  location: resourceGroup().location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork1, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup3, 'Microsoft.Web/sites', appService_var)
          groupIds: [
            'sites'
          ]
        }
        name: 'nprd-ctcms-ct1-app-pe'
      }
    ]
  }
  dependsOn: [
    appService1
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: '${cDNProfileFrontDoor1}/${cDNProfileFrontDoorOriginGroup1}/${cDNProfileFrontDoorOriginGroupOrigin1}'
  properties: {
    enabledState: 'Enabled'
    hostName: '${appService_var}.azurewebsites.net'
    originHostHeader: '${appService_var}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 100
    sharedPrivateLinkResource: {
      privateLink: {
        id: '/subscriptions/${subscription}/resourceGroups/${resourceGroup3}/providers/Microsoft.Web/sites/${appService_var}'
      }
      groupId: 'sites'
      privateLinkLocation: resourceGroup().location
      requestMessage: 'Approve for FD'
    }
  }
  dependsOn: [
    appService1
  ]
}

