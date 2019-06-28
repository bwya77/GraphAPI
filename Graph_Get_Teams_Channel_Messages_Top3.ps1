#Permissions needed: Group.Read.All,Group.ReadWrite.All


#Getting all Groups
$apiUrl = "https://graph.microsoft.com/beta/groups/"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Groups = ($Data | Select-Object Value).Value

#Get ID of management team group
$ManagementTeamID = ($Groups | Where-Object {$_.displayname -eq "Management"}).id

#List the channels in the group, grab the ID for the General chat
$apiUrl = "https://graph.microsoft.com/beta/groups/$ManagementTeamID/Channels"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Channels = ($Data | Select-Object Value).Value | Where-Object {$_.displayName -eq "General"}
$ChannelID = ($Channels).ID

#Grab newest 3 messages from channel
$apiUrl = "https://graph.microsoft.com/beta/teams/$ManagementTeamID/channels/$ChannelID/messages?`$top=3"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get 
$Messages = ($Data | Select-Object Value).Value
$Messages | Select-Object @{Name = 'Message'; Expression = {(($_).body).content}}, @{Name = 'From'; Expression = {((($_).from).user).displayName}}  | Format-List
