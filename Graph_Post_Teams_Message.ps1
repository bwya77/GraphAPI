#Permissions needed: Group.ReadWrite.All


#Getting all Groups
$apiUrl = "https://graph.microsoft.com/beta/groups/"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Groups = ($Data | Select-Object Value).Value

#Get ID of management team group
$ManagementTeamID = ($Groups | Where-Object {$_.displayname -eq "Management"}).id

#List the channels in the group, grab the ID
$apiUrl = "https://graph.microsoft.com/beta/groups/$ManagementTeamID/Channels"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Channels = ($Data | Select-Object Value).Value | Where-Object {$_.displayName -eq "General"}
$ChannelID = ($Channels).ID

$apiUrl = "https://graph.microsoft.com/beta/teams/$ManagementTeamID/channels/$ChannelID/messages"
$body = @"
{ 
"body": { 
    "content": "Hello World" 
     } 
 }
"@

Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Body $Body -Method Post -ContentType 'application/json'




