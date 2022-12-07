$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", ${env:basicAuth})

$body = "{
`n    `"definitionId`": { `"id`": 187 },
`n    `"templateParamenters`": [
`n        { `"countyId`": `"007`" },
`n        { `"countyName`": `"MasterCounty`" },
`n        { `"farmId`": `"521`" },
`n        { `"prefix`": `"MasterPrefix`" },
`n        { `"imageLabel`": `"Ultimate`" }
`n    ]
`n}
`n"

$response = Invoke-RestMethod 'https://dev.azure.com/calcourtsdevops/Hosted-Court-Web-Services-Non-Prod/_apis/pipelines/187/runs?&api-version=6.1-preview.1' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json
