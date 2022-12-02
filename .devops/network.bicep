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
//var appServiceInsightsDiagnosticSetting1_var = 'nprd-ctcms-ct1-diag'
//var resourceGroup2 = 'nprd-ctcms-${dfN}-net-rg'
//var subnet1 = '${dfN}-asp-sn'
//var dfVirtualNetwork1  'nprd-ctcms-${dfN}-vnet'
//var cDNProfileFrontDoorEndpoint1 = 'df1-ct1-fd-endpoint'
//var cDNProfileFrontDoorEndpointsRoute1 = 'df1-ct1-route'
//var cDNProfileFrontDoorOriginGroup1 = 'df1-ct1-fd-orggrp'
//var cDNProfileFrontDoorSecurityPolicy1 = 'nprdfdsecpol'

resource networkPrivateEndpoint3 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: networkPrivateEndpoint3_var
  location: cmLocation1
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets' dfVirtualNetwork1, subnet1)
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: resourceId(resourceGroup3, 'Microsoft.Web/sites', appService1)
          groupIds: [
            'sites'
          ]
        }
        name: 'nprd-ctcms-ct1-app-pe'
      }
    ]
  }
}
