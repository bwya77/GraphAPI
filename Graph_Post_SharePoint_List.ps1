#Permissions needed, Sites.Read.All; Sites.ReadWrite.All

#Get all SharePoint Sites
$apiUrl = "https://graph.microsoft.com/v1.0/sites?search=* "
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Sites = ($Data | Select-Object Value).Value 

#Find my site named "Management" and get the ID 
$CommunitySiteID = ($Sites | Where-Object {$_.name -eq "Management"}).id
#https://bwya77.sharepoint.com/sites/Management

$apiUrl = "https://graph.microsoft.com/v1.0/sites/$CommunitySiteID/lists"

$body = @"
{
  "displayName": "Books",
  "columns": [
    {
      "name": "Author",
      "text": { }
    },
    {
      "name": "PageCount",
      "number": { }
    }
  ],
  "list": {
    "template": "genericList"
  }
}
"@
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Post -Body $body -ContentType 'application/json'


#https://bwya77.sharepoint.com/sites/Management/Lists/Books

