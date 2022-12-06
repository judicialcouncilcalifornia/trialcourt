param PrincipalId string
param RoleDefinitionId string

resource KeyVault_RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' ={
  name: guid(resourceGroup().id, PrincipalId, RoleDefinitionId)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', RoleDefinitionId)
    principalId: PrincipalId
  }
}
