#Get all tenant sku information

#Get tenant sku information
$apiUrl = 'https://graph.microsoft.com/v1.0/domains/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Domains = ($Data | Select-Object Value).Value 


$Domains | Select-Object id, supportedServices


