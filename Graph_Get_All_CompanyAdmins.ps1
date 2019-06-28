#Permissions needed Directory.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#Get all members in the Company Administrators role

#Get the id of the role
$apiUrl = 'https://graph.microsoft.com/v1.0/directoryRoles/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$CompanyAdminID = ($Data | Select-Object Value).Value | Where-Object {$_.displayName -eq "Company Administrator"} | Select-Object id

$apiUrl = "https://graph.microsoft.com/v1.0/directoryRoles/$($CompanyAdminID.id)/members"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Members = ($Data | select-object Value).Value


$Members | Format-Table DisplayName, userPrincipalName -AutoSize