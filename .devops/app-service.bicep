@allowed([
  '1'
  '2'
  '3'
])
param siteFarmId string = '1'
param siteId string = '009'
param cmLocation string = resourceGroup().location

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
var resourceGroupNet = '${environment}-ctcms-net-rg'

var cDNProfileFrontDoor1 = '${environment}-ctcms-fd'
var cDNProfileFrontDoorOriginGroup1 = 'df${siteFarmId}-ct${siteId}-fd-orggrp'
var cDNProfileFrontDoorOriginGroupOrigin1 = 'df${siteFarmId}-ct${siteId}-fd-origin'
var subscriptionId = '539516a7-6f4e-450d-b99e-be9dcc48a4c4'

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1 'Microsoft.Cdn/profiles/originGroups@2021-06-01' existing = {
  name: '${cDNProfileFrontDoorOriginGroup1}'
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
          name: 'setting1'
          value: 'valueOfSetting1'
        }
        {
          name: 'setting2'
          value: 'valueOfSetting2'
        }
      ]
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
    virtualNetworkSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/$(resourceGroupNet)/providers/Microsoft.Network/virtualNetworks/$(environment)-ctcms-df${siteFarmId}-vnet/subnets/df${siteFarmId}-asp-sn'
  }
}

resource appService1_appServiceConfigRegionalVirtualNetworkIntegration1 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appService1
  name: 'appsettings'
  properties: {
    subnetResourceId: resourceId(resourceGroupNet, 'Microsoft.Network/virtualNetworks/subnets', virtualNetwork1, subnet1)
  }
  dependsOn: [
    appService1
  ]
}

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint3_var
  location: cmLocation
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork1, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroupApp, 'Microsoft.Web/sites', appService)
          groupIds: [
            'sites'
          ]
        }
        name: '$(environtment)-ctcms-ct$(siteId)-app-pe'
      }
    ]
  }
  dependsOn: [
    appService1
  ]
}

resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  parent: cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1
  name: '${cDNProfileFrontDoorOriginGroupOrigin1}'
  properties: {
    enabledState: 'Enabled'
    hostName: '${appService}.azurewebsites.net'
    originHostHeader: '${appService}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 100
    sharedPrivateLinkResource: {
      privateLink: {
        id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupApp}/providers/Microsoft.Web/sites/${appService}'
      }
      groupId: 'sites'
      privateLinkLocation: cmLocation
      requestMessage: 'Approve for FD'
    }
  }
}

