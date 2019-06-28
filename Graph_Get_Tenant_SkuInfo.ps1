#Get all tenant sku information

#Get tenant sku information
$apiUrl = 'https://graph.microsoft.com/v1.0/subscribedSkus/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$LicInfo = ($Data | Select-Object Value).Value 



$LicInfo | Select-Object consumedunits, skuPartNumber,  @{Name = 'Services'; Expression = {(($_).serviceplans).serviceplanname}}, appliesto -ExpandProperty prepaidUnits | fl  

