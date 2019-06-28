#Permissions needed: User.ReadBasic.All, User.Read.All, User.ReadWrite.All, Directory.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#https://docs.microsoft.com/en-us/graph/query-parameters#format-parameter

#Get all users, sort by displayName
$apiUrl = 'https://graph.microsoft.com/v1.0/users?$orderby=displayName'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Users = ($Data | Select-Object Value).Value 


$Users | Select-Object DisplayName, userPrincipalName