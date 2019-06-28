#Permissions needed: Directory.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#Get all Devices in Azure AD


$apiUrl = 'https://graph.microsoft.com/v1.0/devices/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Computers = ($Data | select-object Value).Value


$Computers | Format-Table DisplayName, trustType, operatingSystem -AutoSize