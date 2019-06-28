#Permissions needed, SecurityEvents.Read.All, SecurityEvents.ReadWrite.All

#Get my recent security alerts
$apiUrl = "https://graph.microsoft.com/v1.0/security/alerts/"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Alerts = ($Data | Select-Object Value).Value 


$Alerts | Select-Object  Status, category, severity, description, @{Name = 'Affected User'; Expression = {($_.userstates).userPrincipalName}}