#Get all groups in Azure AD


$apiUrl = 'https://graph.microsoft.com/v1.0/Groups/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Groups = ($Data | select-object Value).Value


$Groups | Format-Table DisplayName, Description -AutoSize