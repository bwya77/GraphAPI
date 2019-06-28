#Permissions needed, Mail.Read

#Get my recent emails
$apiUrl = "https://graph.microsoft.com/v1.0/me/messages?`$top=10"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Emails = ($Data | Select-Object Value).Value 



$Emails | Select-Object  @{Name = 'From'; Expression = {(($_.sender).emailaddress).name}}, @{Name = 'To'; Expression = {(($_.toRecipients).emailaddress).name}}, subject, hasattachments