param env string
param siteId string
param uniqueMod string
param cmLocation string = resourceGroup().location
param siteFarmId string

var dfVnet_name = '${env}-ctcms-df${siteFarmId}-vnet'
var dfAppSn_name = 'df${siteFarmId}-app-sn'
var dfDataResourceGroup = '${env}-ctcms-df${siteFarmId}-app-rg'
var appService = '${env}-ctcms-ct${siteId}-app${uniqueMod}'
var appDns = 'privatelink.azurewebsites.net'
var dfAppPe_name = '${appService}-pe'
var dfAppPeDns_config = '${appService}-pe-dns'
var envAdminResourceGroup = '${env}-ctcms-admin-rg'

resource dfAppPe 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: dfAppPe_name
  location: cmLocation
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', dfVnet_name, dfAppSn_name)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(dfDataResourceGroup, 'Microsoft.Web/sites', appService)
          groupIds: [
            'sites'
          ]
        }
        name: dfAppPe_name
      }
    ]
  }
}

resource dfAppPeDnsConfig 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = {
  parent: dfAppPe
  name: dfAppPeDns_config
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${env}-ctcms-ct${siteId}-app-dns'
        properties: {
          privateDnsZoneId: resourceId(envAdminResourceGroup, 'Microsoft.Network/privateDnsZones', appDns)
        }
      }
    ]
  }
}
