#Permissions Files.Read, Files.ReadWrite, Files.Read.All, Files.ReadWrite.All, Sites.Read.All, Sites.ReadWrite.All

$apiUrl = 'https://graph.microsoft.com/v1.0/me/drive/root/children'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$DriveItems = ($Data | Select-Object Value).Value 

$DriveItems | Select-Object name, size
