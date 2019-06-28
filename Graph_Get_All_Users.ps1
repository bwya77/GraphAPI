#Permissions needed: User.ReadBasic.All, User.Read.All, User.ReadWrite.All, Directory.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#Get all Azure AD Users

$apiUrl = 'https://graph.microsoft.com/v1.0/users/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Users = ($Data | select-object Value).Value


$Users | Format-Table displayName, UserPrincipalName -AutoSize