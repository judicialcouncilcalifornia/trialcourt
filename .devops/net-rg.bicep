param env string = 'nprd'
param siteId string = '001'
param uniqueMod string = '42'
param cmLocation string = resourceGroup().location
param siteFarmId string = '1'

var appPrivateEndpointName = '${env}-ctcms-ct${siteId}-app-pe'
var dfVirtualNetwork1 = '${env}-ctcms-df${siteFarmId}-vnet'
var appSubnet = 'df${siteFarmId}-app-sn'
var appResourceGroup = '${env}-ctcms-df${siteFarmId}-app-rg'
var appService = '${env}-ctcms-ct${siteId}-app${uniqueMod}'
var appDns = 'privatelink.azurewebsites.net'
var networkPrivateEndpointPrivateDnsZoneGroup3 = '${env}-ctcms-ct${siteId}-app-pe-dns'
var admResourceGroup = '${env}-ctcms-admin-rg'

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: appPrivateEndpointName
  location: cmLocation
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', dfVirtualNetwork1, appSubnet)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(appResourceGroup, 'Microsoft.Web/sites', appService)
          groupIds: [
            'sites'
          ]
        }
        name: appPrivateEndpointName
      }
    ]
  }
}

resource networkPrivateEndpoint3_networkPrivateEndpointPrivateDnsZoneGroup3 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = {
  parent: networkPrivateEndpoint3
  name: networkPrivateEndpointPrivateDnsZoneGroup3
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${env}-ctcms-ct${siteId}-app-dns'
        properties: {
          privateDnsZoneId: resourceId(admResourceGroup, 'Microsoft.Network/privateDnsZones', appDns)
        }
      }
    ]
  }
}
