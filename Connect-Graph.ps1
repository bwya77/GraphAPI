function Connect-Graph
{
	$clientId = "" 
	$redirectUrl = [System.Uri]"urn:ietf:wg:oauth:2.0:oob" # This is the standard Redirect URI for Windows Azure PowerShell
	$tenant = "DOMAIN.onmicrosoft.com"
	$resource = "https://graph.microsoft.com/";
	$serviceRootURL = "https://graph.microsoft.com//$tenant"
	$authUrl = "https://login.microsoftonline.com/$tenant";
	
	$postParams = @{ resource = "$resource"; client_id = "$clientId" }
	$response = Invoke-RestMethod -Method POST -Uri "$authurl/oauth2/devicecode" -Body $postParams
	Write-Host $response.message
	#I got tired of manually copying the code, so I did string manipulation and stored the code in a variable and added to the clipboard automatically
	$code = ($response.message -split "code " | Select-Object -Last 1) -split " to authenticate."
	Set-Clipboard -Value $code
	#Start-Process "https://microsoft.com/devicelogin"
	Add-Type -AssemblyName System.Windows.Forms
	
	$form = New-Object -TypeName System.Windows.Forms.Form -Property @{ Width = 440; Height = 640 }
	$web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{ Width = 440; Height = 600; Url = "https://www.microsoft.com/devicelogin" }
	
	$web.Add_DocumentCompleted($DocComp)
	$web.DocumentText
	
	$form.Controls.Add($web)
	$form.Add_Shown({ $form.Activate() })
	$web.ScriptErrorsSuppressed = $true
	
	$form.AutoScaleMode = 'Dpi'
	$form.text = "Graph API Authentication"
	$form.ShowIcon = $False
	$form.AutoSizeMode = 'GrowAndShrink'
	$Form.StartPosition = 'CenterScreen'
	
	
	$form.ShowDialog() | Out-Null
	
	
	$tokenParams = @{ grant_type = "device_code"; resource = "$resource"; client_id = "$clientId"; code = "$($response.device_code)" }
	
	$global:tokenResponse = $null
	
	try
	{
		$global:tokenResponse = Invoke-RestMethod -Method POST -Uri "$authurl/oauth2/token" -Body $tokenParams
	}
	catch [System.Net.WebException]
	{
		if ($_.Exception.Response -eq $null)
		{
			throw
		}
		
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$errBody = ConvertFrom-Json $reader.ReadToEnd();
		
		if ($errBody.Error -ne "authorization_pending")
		{
			throw
		}
	}
	
	If ($null -eq $global:tokenResponse)
	{
		Write-Warning "Not Connected"
	}
	Else
	{
		Write-Host -ForegroundColor Green "Connected"
	}
}



