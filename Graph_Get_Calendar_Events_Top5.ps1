#Permissions needed: Calendars.Read, Calendars.ReadWrite


#Getting all Cal Events
$apiUrl = "https://graph.microsoft.com/v1.0/me/events?`$top=5"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Events = ($Data | Select-Object Value).Value

$Events | Select-Object subject, importance, showas,  @{Name = 'Organizer'; Expression = {((($_).organizer).emailaddress).name}},  @{Name = 'Location'; Expression = {(($_).locations).displayname}}

