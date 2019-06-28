#Permissions needed, Sites.Read.All; Sites.ReadWrite.All

#Get all SharePoint Sites
$apiUrl = "https://graph.microsoft.com/v1.0/sites?search=* "
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Sites = ($Data | Select-Object Value).Value 


$Sites | Select-Object DisplayName, webUrl