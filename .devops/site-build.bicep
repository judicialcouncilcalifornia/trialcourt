targetScope = 'subscription'

// Parameters for deployment here
@allowed([
  '1'
  '2'
  '3'
])
param siteFarmId string

@allowed([
  'nprd'
  'uat'
  'prod'
])
param env string

param siteId string
param siteName string
param uniqueMod string = ''

param location1 string = 'West US 3'
param subId string = subscription().subscriptionId
param utcValue string = utcNow()


// Initialize Resource Groups
var adminResourceGroup_name = '${env}-ctcms-admin-rg'
var appDfResourceGroup_name = '${env}-ctcms-df${siteFarmId}-app-rg'
var dataDfResourceGroup_name = '${env}-ctcms-df${siteFarmId}-data-rg'
var netDfResourceGroup_name = '${env}-ctcms-df${siteFarmId}-net-rg'

resource adminResourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  name: adminResourceGroup_name
}

resource appDfResourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  name: appDfResourceGroup_name
}

resource dataDfResourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  name: dataDfResourceGroup_name
}

resource netResourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  name: netDfResourceGroup_name
}

// Module Deployments start here

module dfappmod './app-rg.bicep'= {
  name: 'SiteApp-${utcValue}'
  params: {
    env: env
    siteId: siteId
    siteName: siteName
    uniqueMod: uniqueMod
    //umiId: umiId
    cmLocation: location1
    siteFarmId: siteFarmId
  }
  scope: appDfResourceGroup
}


module dfnetmod './net-rg.bicep'= {
  name: 'SiteNet-${utcValue}'
  params: {
    env: env
    siteId: siteId
    uniqueMod: uniqueMod
    cmLocation: location1
    siteFarmId: siteFarmId
  }
  dependsOn: [
    dfappmod
  ]
  scope: netResourceGroup
}

module dfadmmod './adm-rg.bicep'= {
  name: 'SiteAdm-${utcValue}'
  params: {
    env: env
    siteId: siteId
    uniqueMod: uniqueMod
    cmLocation: location1
    siteFarmId: siteFarmId
  }
  dependsOn: [
    dfappmod
  ]
  scope: adminResourceGroup
}
