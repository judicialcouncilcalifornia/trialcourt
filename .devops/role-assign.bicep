param PrincipalId string
param RoleDefinitionId string

resource KeyVault_RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' ={
  name: guid(resourceGroup().id, PrincipalId, RoleDefinitionId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', RoleDefinitionId)
    principalId: PrincipalId
  }
}




resource symbolicname 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  kind: 'string'
  parent: resourceSymbolicName
  properties: {
    acrUseManagedIdentityCreds: bool
    acrUserManagedIdentityID: 'string'
    alwaysOn: bool
    apiDefinition: {
      url: 'string'
    }
    apiManagementConfig: {
      id: 'string'
    }
    appCommandLine: 'string'
    appSettings: [
      {
        name: 'string'
        value: 'string'
      }
    ]
    autoHealEnabled: bool
    autoHealRules: {
      actions: {
        actionType: 'string'
        customAction: {
          exe: 'string'
          parameters: 'string'
        }
        minProcessExecutionTime: 'string'
      }
      triggers: {
        privateBytesInKB: int
        requests: {
          count: int
          timeInterval: 'string'
        }
        slowRequests: {
          count: int
          path: 'string'
          timeInterval: 'string'
          timeTaken: 'string'
        }
        slowRequestsWithPath: [
          {
            count: int
            path: 'string'
            timeInterval: 'string'
            timeTaken: 'string'
          }
        ]
        statusCodes: [
          {
            count: int
            path: 'string'
            status: int
            subStatus: int
            timeInterval: 'string'
            win32Status: int
          }
        ]
        statusCodesRange: [
          {
            count: int
            path: 'string'
            statusCodes: 'string'
            timeInterval: 'string'
          }
        ]
      }
    }
    autoSwapSlotName: 'string'
    azureStorageAccounts: {}
    connectionStrings: [
      {
        connectionString: 'string'
        name: 'string'
        type: 'string'
      }
    ]
    cors: {
      allowedOrigins: [
        'string'
      ]
      supportCredentials: bool
    }
    defaultDocuments: [
      'string'
    ]
    detailedErrorLoggingEnabled: bool
    documentRoot: 'string'
    experiments: {
      rampUpRules: [
        {
          actionHostName: 'string'
          changeDecisionCallbackUrl: 'string'
          changeIntervalInMinutes: int
          changeStep: int
          maxReroutePercentage: int
          minReroutePercentage: int
          name: 'string'
          reroutePercentage: int
        }
      ]
    }
    ftpsState: 'string'
    functionAppScaleLimit: int
    functionsRuntimeScaleMonitoringEnabled: bool
    handlerMappings: [
      {
        arguments: 'string'
        extension: 'string'
        scriptProcessor: 'string'
      }
    ]
    healthCheckPath: 'string'
    http20Enabled: bool
    httpLoggingEnabled: bool
    ipSecurityRestrictions: [
      {
        action: 'string'
        description: 'string'
        headers: {}
        ipAddress: 'string'
        name: 'string'
        priority: int
        subnetMask: 'string'
        subnetTrafficTag: int
        tag: 'string'
        vnetSubnetResourceId: 'string'
        vnetTrafficTag: int
      }
    ]
    javaContainer: 'string'
    javaContainerVersion: 'string'
    javaVersion: 'string'
    keyVaultReferenceIdentity: 'string'
    limits: {
      maxDiskSizeInMb: int
      maxMemoryInMb: int
      maxPercentageCpu: int
    }
    linuxFxVersion: 'string'
    loadBalancing: 'string'
    localMySqlEnabled: bool
    logsDirectorySizeLimit: int
    managedPipelineMode: 'string'
    managedServiceIdentityId: int
    minimumElasticInstanceCount: int
    minTlsVersion: 'string'
    netFrameworkVersion: 'string'
    nodeVersion: 'string'
    numberOfWorkers: int
    phpVersion: 'string'
    powerShellVersion: 'string'
    preWarmedInstanceCount: int
    publicNetworkAccess: 'string'
    publishingUsername: 'string'
    push: {
      kind: 'string'
      properties: {
        dynamicTagsJson: 'string'
        isPushEnabled: bool
        tagsRequiringAuth: 'string'
        tagWhitelistJson: 'string'
      }
    }
    pythonVersion: 'string'
    remoteDebuggingEnabled: bool
    remoteDebuggingVersion: 'string'
    requestTracingEnabled: bool
    requestTracingExpirationTime: 'string'
    scmIpSecurityRestrictions: [
      {
        action: 'string'
        description: 'string'
        headers: {}
        ipAddress: 'string'
        name: 'string'
        priority: int
        subnetMask: 'string'
        subnetTrafficTag: int
        tag: 'string'
        vnetSubnetResourceId: 'string'
        vnetTrafficTag: int
      }
    ]
    scmIpSecurityRestrictionsUseMain: bool
    scmMinTlsVersion: 'string'
    scmType: 'string'
    tracingOptions: 'string'
    use32BitWorkerProcess: bool
    virtualApplications: [
      {
        physicalPath: 'string'
        preloadEnabled: bool
        virtualDirectories: [
          {
            physicalPath: 'string'
            virtualPath: 'string'
          }
        ]
        virtualPath: 'string'
      }
    ]
    vnetName: 'string'
    vnetPrivatePortsCount: int
    vnetRouteAllEnabled: bool
    websiteTimeZone: 'string'
    webSocketsEnabled: bool
    windowsFxVersion: 'string'
    xManagedServiceIdentityId: int
  }
}
