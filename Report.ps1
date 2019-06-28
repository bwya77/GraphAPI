$ReportSavePath = "C:\Graph\"
$rightlogo = "https://www.psmpartners.com/wp-content/themes/psm/images/psm-logo.png"


$Table = New-Object 'System.Collections.Generic.List[System.Object]'
$UserTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupTable = New-Object 'System.Collections.Generic.List[System.Object]'
$DevicesTable = New-Object 'System.Collections.Generic.List[System.Object]'
$LicenseTable = New-Object 'System.Collections.Generic.List[System.Object]'
$SitesTable = New-Object 'System.Collections.Generic.List[System.Object]'
$SecurityAlerts = New-Object 'System.Collections.Generic.List[System.Object]'

Write-Host "Getting Company Admins"
#Company Admins

$apiUrl = 'https://graph.microsoft.com/v1.0/directoryRoles/'
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$CompanyAdminID = ($Data | Select-Object Value).Value | Where-Object { $_.displayName -eq "Company Administrator" } | Select-Object id

$apiUrl = "https://graph.microsoft.com/v1.0/directoryRoles/$($CompanyAdminID.id)/members"
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$Members = ($Data | select-object Value).Value

$Members | ForEach-Object {
	
	$obj = [PSCustomObject]@{
		'Name' = $_.DisplayName
		'UserPrincipalName' = $_.userPrincipalName
	}
	
	$Table.add($obj)
}
Write-Host "Done!" -ForegroundColor Green

Write-Host "Getting Security Alerts"
#Get my recent security alerts
$apiUrl = "https://graph.microsoft.com/v1.0/security/alerts/"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Alerts = ($Data | Select-Object Value).Value 
$Alerts | ForEach-Object {
	
	$obj = [PSCustomObject]@{
        'Status' = $_.Status
        'Category' = $_.Category
        'Severity' = $_.Severity
		'Name' = ($_.userstates).userPrincipalName
		'Description' = $_.Description
	}
	
	$SecurityAlerts.add($obj)
}
Write-Host "Done!" -ForegroundColor Green

Write-Host "Getting Users"
#Get all users, sort by displayName


$apiUrl = 'https://graph.microsoft.com/v1.0/users?$orderby=displayName'
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$Users = ($Data | Select-Object Value).Value


$Users | ForEach-Object {
	$obj = [PSCustomObject]@{
		'Name' = $_.DisplayName
		'UserPrincipalName' = $_.userPrincipalName
	}
	
	$UserTable.add($obj)
}
Write-Host "Done!" -ForegroundColor Green

Write-Host "Getting Groups"
#Get all Azure AD Groups
# ALL Groups, only grab one at a time to show paging
[system.string]$apiUrl = "https://graph.microsoft.com/v1.0/groups?`$top=1"

[pscustomobject]$ReqResult = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get

#Create an array
[array]$AllGroups = @()

[int]$NextFlag = 1



while ($NextFlag -eq 1)
{
	$AllGroups += $ReqResult.value
	
	if ($ReqResult.psobject.properties.name -contains '@odata.nextlink')
	{
		$ReqResult = Invoke-RestMethod -Uri $ReqResult.'@odata.nextLink' -Method GET -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" }
	}
	
	else
	{
		$NextFlag = 0
	}
}
$AllGroups | ForEach-Object {
	$obj = [PSCustomObject]@{
		'Name' = $_.DisplayName
		'E-Mail' = $_.mail
	}
	
	$GroupTable.add($obj)
}
Write-Host "Done!" -ForegroundColor Green

Write-Host "Getting Devices"
#Get all Azure AD Devices
$apiUrl = 'https://graph.microsoft.com/v1.0/devices/'
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$Computers = ($Data | select-object Value).Value

$Computers | ForEach-Object {
	$obj = [PSCustomObject]@{
		'Name' = $_.DisplayName
		'Trust Type' = $_.trustType
		'Operating System' = $_.operatingSystem
	}
	
	$DevicesTable.add($obj)
}
Write-Host "Done!" -ForegroundColor Green


#Licenses
$apiUrl = 'https://graph.microsoft.com/v1.0/subscribedSkus/'
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$LicInfo = ($Data | Select-Object Value).Value
$LicInfo | ForEach-Object {
	$service = ($_.serviceplans).serviceplanname
	$list = $service -join ", "
	
	$obj = [PSCustomObject]@{
		'Name' = $_.skuPartNumber
		'Services' = $list
	}
	
	$LicenseTable.add($obj)
	
}

#SharePoint Sites
#Get all SharePoint Sites
Write-Host "Getting all SharePoint Sites"
$apiUrl = "https://graph.microsoft.com/v1.0/sites?search=* "
$Data = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($Tokenresponse.access_token)" } -Uri $apiUrl -Method Get
$Sites = ($Data | Select-Object Value).Value
$Sites | ForEach-Object {
	$obj = [PSCustomObject]@{
		'Name' = $_.Displayname
		'URL'  = $_.webUrl
	}
	
	$SitesTable.add($obj)
	
}
Write-Host "Done!" -ForegroundColor Green

Write-Host "Generating HTML Report..." -ForegroundColor Yellow
Write-Host "Creating Tab array"
$tabarray = @('Dashboard', 'SharePoint')
Write-Host "Creating report object"
$rpt = New-Object 'System.Collections.Generic.List[System.Object]'
#C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2
$rpt += get-htmlopenpage -TitleText 'Enviornment Report' -CSSName "psm" -RightLogoString $rightlogo

$rpt += Get-HTMLTabHeader -TabNames $tabarray 
    $rpt += get-htmltabcontentopen -TabName $tabarray[0] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))
        Write-Host "Creating Dashboard Page"
        $rpt+= Get-HtmlContentOpen -HeaderText "Dashboard"
            Write-Host "Creating Permission Report"
          $rpt += Get-HTMLContentOpen -HeaderText "Permissions - Company Administrators"
            $rpt += Get-HtmlContentTable $Table 
          $rpt += Get-HTMLContentClose
          $rpt += Get-HTMLContentOpen -HeaderText "Security Alerts"
          Write-Host "Creating Security Alerts Report"
            $rpt += Get-HtmlContentTable $SecurityAlerts
          $rpt += Get-HTMLContentClose

	        $rpt+= get-HtmlColumn1of2
		        $rpt+= Get-HtmlContentOpen -BackgroundShade 1 -HeaderText 'Users'
                    Write-Host "Creating User Report"
			        $rpt+= get-htmlcontentdatatable  $UserTable -HideFooter
		        $rpt+= Get-HtmlContentClose
	        $rpt+= get-htmlColumnClose
	            $rpt+= get-htmlColumn2of2
                    Write-Host "Creating Computer Report"
		            $rpt+= Get-HtmlContentOpen -HeaderText 'Computers'
			            $rpt+= get-htmlcontentdatatable $DevicesTable -HideFooter 
		        $rpt+= Get-HtmlContentClose
	        $rpt+= get-htmlColumnClose
          Write-Host "Creating License Report"
          $rpt += Get-HTMLContentOpen -HeaderText "Licenses"
            $rpt += Get-HtmlContentTable $LicenseTable 
          $rpt += Get-HTMLContentClose

        $rpt+= Get-HtmlContentClose 
        $rpt += get-htmltabcontentclose
   
        $rpt += get-htmltabcontentopen -TabName $tabarray[1] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))
         $rpt+= Get-HtmlContentOpen -HeaderText "SharePoint"
        $rpt += Get-HTMLContentOpen -HeaderText "SharePoint Sites"
            $rpt += get-htmlcontentdatatable $SitesTable -HideFooter
        $rpt += Get-HTMLContentClose
      $rpt += Get-HTMLContentClose
    $rpt += get-htmltabcontentclose

$rpt += Get-HTMLClosePage

$Day = (Get-Date).Day
$Month = (Get-Date).Month
$Year = (Get-Date).Year
Write-Host "Compiling Report"
$ReportName = ( "$Month" + "-" + "$Day" + "-" + "$Year" + "-" + "O365 Tenant Report") 
Save-HTMLReport -ReportContent $rpt -ShowReport -ReportName $ReportName -ReportPath $ReportSavePath 