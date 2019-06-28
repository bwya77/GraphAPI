#Permissions needed: Group.Read.All, Directory.Read.All, Group.ReadWrite.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#https://docs.microsoft.com/en-us/graph/paging

# ALL Groups, only grab one at a time to show paging
[system.string]$apiUrl = "https://graph.microsoft.com/v1.0/groups?`$top=1"

[pscustomobject]$ReqResult = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get

#Create an array
[array]$AllGroups = @()

[int]$NextFlag = 1
[int]$Page = 0


while ($NextFlag -eq 1)
{
	$AllGroups += $ReqResult.value
	
	if ($ReqResult.psobject.properties.name -contains '@odata.nextlink')
	{
		$Page++
		Write-Host "Querying page $page"
		$ReqResult = Invoke-RestMethod -Uri $ReqResult.'@odata.nextLink' -Method GET -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" }
		
	}
	
	else
	{
		
		$NextFlag = 0
		
	}
}


$AllGroups | Select-Object displayName, mail

