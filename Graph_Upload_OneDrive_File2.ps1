#Permissions Files.Read, Files.ReadWrite, Files.Read.All, Files.ReadWrite.All, Sites.Read.All, Sites.ReadWrite.All

$apiUrl = 'https://graph.microsoft.com/v1.0/me/drive/root:/test.txt:/content'
$body = "test"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Put -InFile "C:\graph\test.txt" -ContentType "text/plain" 

