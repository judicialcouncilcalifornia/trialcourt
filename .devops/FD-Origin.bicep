param cmLocation1 string = resourceGroup().location


var appService1 = 'nprd-ctcms-ct003-app'
var cDNProfileFrontDoor1 = 'nprd-ctcms-fd'
var cDNProfileFrontDoorOriginGroup1 = 'df1-ct1-fd-orggrp'
var cDNProfileFrontDoorOriginGroupOrigin1 = 'df1-ct1-fd-origin'

var resourceGroup2 = 'nprd-ctcms-df1-app-rg'


resource cDNProfileFrontDoor1_cDNProfileFrontDoorOriginGroup1_cDNProfileFrontDoorOriginGroupOrigin1 'Microsoft.Cdn/profiles/originGroups/origins@2022-05-01-preview' = {
  name: '${cDNProfileFrontDoor1}/${cDNProfileFrontDoorOriginGroup1}/${cDNProfileFrontDoorOriginGroupOrigin1}'
  properties: {
    enabledState: 'Enabled'
    //enforceCertificateNameCheck: true
    hostName: 'nprd-ctcms-ct003-app.azurewebsites.net'
    originHostHeader: 'nprd-ctcms-ct003-app.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    priority: 1
    //sharedPrivateLinkResource: {
      //groupId: 'sites'
      //privateLink: '/subscriptions/539516a7-6f4e-450d-b99e-be9dcc48a4c4/resourceGroups/nprd-ctcms-df1-app-rg/providers/Microsoft.Web/sites/nprd-ctcms-ct003-app'
      //requestMessage: 'AutomationRequest'
    weight: 100
    sharedPrivateLinkResource: {
      privateLink: {
        id: '/subscriptions/539516a7-6f4e-450d-b99e-be9dcc48a4c4/resourceGroups/nprd-ctcms-df1-app-rg/providers/Microsoft.Web/sites/nprd-ctcms-ct003-app'
      }
      groupId: 'sites'
      privateLinkLocation: cmLocation1
      requestMessage: 'Approve for FD'
      //status: 'Approved'
    }
    }
    //}
    
    
  }
//}
