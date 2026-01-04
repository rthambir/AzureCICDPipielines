param location string = resourceGroup().location
param dataFactoryName string
param storageAccountName string
param integrationRuntimeName string = 'AutoResolveIntegrationRuntime'
param configContainerName string = 'config'
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: '${storageAccount.name}/default'
}

resource configContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${blobService.name}/${configContainerName}'
  properties: {
    publicAccess: 'None'
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${dataFactory.name}/${integrationRuntimeName}'
  properties: {
    type: 'Managed'
    typeProperties: {}
  }
}

output dataFactoryId string = dataFactory.id
output storageAccountId string = storageAccount.id
