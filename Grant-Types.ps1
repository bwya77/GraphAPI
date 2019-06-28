# Docs for scopes, permissions and consent --> http://bit.ly/2RAGiv7

# Static Variables
$Client_ID = ""         # Azure AD App ID
$Client_Secret = ""     # Azure AD App Secret
$tenantID = ""          # Tenant ID, readable or gibberish format :)
$Username = ""          
$Password = ""

# My computer's Powershell is throwing some weird cert error so I'm doing this to bypass. YOu can ignore this. 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<# Client_Credentials Grant type
http://bit.ly/2K0rswY

Helicopter View: 
1. You send needed information to Token request Endpoint
2. You get token
3. You talk to Graph API with your token

With right permissions and admin grant or user authorization, this is the flow for CLient_Credentials:
1. YOu send the $reqTokenBody to token request endpoint. What's in the token body are the the basic requirements in Client_Credentials header.
2. YOu get the access token
3. You save the access the token in a variable $ReqHeader to proper format it (Bearer pre-fix and "Authorization" value name)
4. Use $reqheader as the Header for your request to Graph API endpoint
#>

$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $client_ID
    Client_Secret = $client_Secret
} 

$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$ReqHeader = @{
    Authorization = "Bearer $($TokReqRes.access_token)"
} 

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

<# Auth Code grant
http://bit.ly/2K4vmVG

Helicopter View: 
1. You access a URL with necessary parameters
2. You authenticate in the browser
3. You get a code upon successfull authentication
4. You Send the code to token request endpoint with other needed information
5. You get token
6. you talk to Graph API with your token

With right permissions and admin grant or user authorization, this is the flow for Authorization_Coe:
1. To acquire an Authorization code:
    1.1 using SDKs or by simply going to this URL in a browser (new line for legibility): 
        https://login.microsoftonline.com/{tenantID}/oauth2
            /v2.0/authorize?client_id={clientID}
            &redirect_uri={RedirectURI}&scope={Scope}
            &response_type=code
    1.2 Upon successul authentication, you will get code in the URL. Like this: https://monosnap.com/file/p8GwA4CciZqFXzICUgQeCEq7J94sZN
    1.3 Extract that code and save it to Variable
2. With all those other needed information, wrap them in variable to be the header for token request. IN my case its the $reqTokenBody
3. YOu send the $reqTokenBody to token request endpoint. What's in the token body are the the basic requirements in Authorization_Code header.
4. YOu get the access token
5. You save the access the token in a variable $ReqHeader to proper format it (Bearer pre-fix and "AUthorization" value name)
6. Use $reqheader as the Header for your request to Graph API endpoint
 
 #>

$AuthCode = "OAQABAAIAAADCoMpjJXrxTq9VG9te-7FXBF_jU73IqFoHuAZlOcmbg_BV7t8q40qVmz_Ft9j3VpLYQKk_0HOjl63HL1ygPARHwu0QgHmzur-8jN-SenbaHjuoN5kVgfcHuRDILtnUXdBxHIq4UaeiDtap9I1DeH3e1MPZQH8K_V1aYFgHjuOmkTiuCOCTmW6dw5CqEZ81ghgM_-vC37zTPM5S7nEOfSc7lXa9FcGG7toKeB007G5p2Liz4_Cmyhahy8RiyNSNkP8cjmz2b2GYr6UKepBGw5HAwD1HAdDxE_gl0iFPMcFP3czI37Zt6oNve6Y7bjHNIpcr2P_fTY2OTFynMsCrfKh-Mp-ptZtsDG2a0ImZXYqnFHSyQFTDcZw29-Fa5NFq2FbnZgmVA2mhxVrlT23ntLg6zCLwQv3VKbgcrPhJSiK-jwooki3IjgJj78pRkIsscTg_q7rhrNIz009MPRdU02n1OQ6RBthalxkJNQgGZq03eEN2g--RKeBQb1R0F81nAYeVZtSnXm0TaUXngZEbyKUpsdhb7HZ4-PDHNVfqcJ36wcgHZs2pVytzr0oTKJxPNLyJfOfZzNiNnv-Srh4I-HeVjrD-tuunJWv8XU2zFSRmVYuDGCpnJYLg-n1m21g_PslaAnEi01YSYPiXEgdvtahAtsNX6HBxw_k5TqX37w5eceJR5LXFh4xapC2j8FzrlU5SVps-itAgmzomIzpAfsA_IAA"

$ReqTokenBody = @{
    Grant_Type    = "Authorization_Code"
    Scope         = "https://graph.microsoft.com/Reports.Read.All"
    redirect_uri  = "http://localhost/" 
    client_Id     = $client_ID
    Client_Secret = $client_Secret
    code          = $AuthCode
} 

$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$ReqHeader = @{
    Authorization = "Bearer $($TokReqRes.access_token)"
} 

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

<# Password Grant
# http://bit.ly/2K4TWFP

A little similar to client_Credentials but with username and password in the header of the token request. 

Helicopter View: 
1. You send needed information to token request Endpoint (with username and password)
2. You get token
3. you talk to Graph API with your token

With right permissions and admin grant or user authorization, this is the flow for CLient_Credentials:
1. You send the $reqTokenBody to token request endpoint. What's in the token body are the the basic requirements in Client_Credentials header.
2. You get the access token
3. You save the access the token in a variable $ReqHeader to proper format it (Bearer pre-fix and "AUthorization" value name)
4. Use $reqheader as the Header for your request to Graph API endpoint

#>
$ReqTokenBody = @{
    Grant_Type    = "Password"
    client_Id     = $client_ID
    Client_Secret = $client_Secret
    Username      = $Username
    Password      = $Password
    Scope         = "https://graph.microsoft.com/Reports.Read.All"
} 

$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$ReqHeader = @{
    Authorization = "Bearer $($TokReqRes.access_token)"
} 

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

<# Device Code
http://bit.ly/2Xs06X2

Helicopter View: 
1. You send needed information to device code endpoint
2. You get an authentication code for authentication and a device code for token request
3. you get to a URL (Provided in the message property of the result) on any device and authenticate using 
4. You send needed information to Token request endpoint and you get token if you have authenticated succesfully in step 3.
5. you talk to Graph API with your token

With right permissions and admin grant or user authorization, this is the flow for Device_code:
1. Send $DevReqBody to deviceCode endpoint to request
2. You will receive a device code, an authentication code, and a URL in which you'll be able to authenticate. 
3. You browse to the URL and provide the authentication code and authenticate. 
4. You grab the Device code from Step 2 and along with the information in $reqTokenBody, send it to Token Request endpoint. 
5. You get the access token
6. You save the access the token in a variable $ReqHeader to proper format it (Bearer pre-fix and "AUthorization" value name)
7. Use $reqheader as the Header for your request to Graph API endpoint
#>

# Request device code for authentication
$DevReqBody = @{ 
    Client_ID = $Client_ID
    Scope     = "user.read offline_access Reports.Read.All"
}
$DevReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/devicecode" -Body $DevReqBody

# Token Request
$ReqTokenBody = @{
    Grant_Type = "Device_Code"
    client_Id  = $client_ID
    Code       = $DevReqRes.device_code
}
$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

<# Refresh_Token Grant
http://bit.ly/2K4vmVG
http://bit.ly/2RzwYYx

If you add "offline_access" (e.g.g https://graph.microsoft.com/reports.read.all offline_access)in to your scope when requesting a token,
    it will add refresh token to your result.
    You can use this refresh token to request for another access token. 

1. request a token and add "offline_acceess" to scope
2. use the refresh token to request another access token. The logic in your app may include a way to do math in terms of the expiration of the access token. 
    Know that fresh token expires in xx days (I'm not sure TBH but it says here 90 days http://bit.ly/2REqCHs) - access tokens expire in 1 hour when it was generated. 
3. The access token acquired from the refresh token can be used the same fashion as the rest of the grant types
    #>
$ReqTokenBody = @{
    Grant_Type    = "Refresh_Token"
    client_Id     = $client_ID
    Client_Secret = $client_Secret
    Refresh_TOken = $TokReqRes.refresh_token
}

$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$ReqHeader = @{
    Authorization = "Bearer $($TokReqRes.access_token)"
} 

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

## End of Req body samples

# Requesting a token header and formating
$TokReqRes = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$ReqHeader = @{
    Authorization = "Bearer $($TokReqRes.access_token)"
} 

# End

# Download from OneDrive
#http://bit.ly/2Ry4OwY
$Params = @{ 
    URI     = "https://graph.microsoft.com/v1.0/users/$username/drive/root:/tasks:/children"
    Headers = $ReqHeader
    Method  = "Get"
}

$Result = Invoke-RestMethod @params

$Result.value | 
Where-Object { $_.'@microsoft.graph.downloadUrl' -ne $null } | Select-Object name, '@microsoft.graph.downloadUrl' | 
ForEach-Object {
    
    Write-Host "Downloading $($_.name)"
    Invoke-WebRequest -Uri $_.'@microsoft.graph.downloadUrl' -OutFile "C:\temp\TestDownload\$($_.name)" -Verbose
        
}

# UPload to Onedrive
# http://bit.ly/2RB27dU

$ULChildren = Get-ChildItem C:\ODSpeedTest\ULDummyData
foreach ($Child in $ULChildren) {

    while (((get-job -State Running).count) -ge 3) {
        sleep -Milliseconds 1
    }

    start-job -ScriptBlock {
        $URI = "https://graph.microsoft.com/v1.0/users/$username/drive/root:/UploadDummy/$($args[1].Name):/content"
        Invoke-RestMethod -Uri $URI -Method PUT -Headers $args[0] -InFile $args[1].FullName

    } -ArgumentList $ReqHeader, $Child
}

while (((get-job -State Running).count) -gt 0) {
    sleep -Milliseconds 1
}

# REPORTING
# http://bit.ly/2RCxlkR

(Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='D7')" -Method Get -Headers $ReqHeader) -replace "\xEF\xBB\xBF" | ConvertFrom-Csv

# ALL USERS
# http://bit.ly/2RzL77W
$ReqResult = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?" -Method Get -Headers $ReqHeader 

$Allusers = @()
$NextFlag = 1
$page = 1
while ($NextFlag -eq 1) {

    Write-Host "Querying page $page"
    $Allusers += $ReqResult.value
    
    if ($ReqResult.psobject.properties.name -contains '@odata.nextlink') {

        $ReqResult = Invoke-RestMethod -Uri $ReqResult.'@odata.nextLink' -Method GET -Headers $ReqHeader
    }
    else { 
        $NextFlag = 0
    }
    $page++
}

$Allusers
# Count
$Allusers | Measure-Object

# ALL GROUPS
# Also doing pagination
$ReqResult = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups?`$select=mailNickname,displayName,securityEnabled,mailEnabled,mail,resourceProvisioningOptions" -Method Get -Headers $ReqHeader 

$AllGroups = @()
$NextFlag = 1
$page = 1
while ($NextFlag -eq 1) {

    Write-Host "Querying page $page"
    $AllGroups += $ReqResult.value
    
    if ($ReqResult.psobject.properties.name -contains '@odata.nextlink') {

        $ReqResult = Invoke-RestMethod -Uri $ReqResult.'@odata.nextLink' -Method GET -Headers $ReqHeader
    }
    else { 
        $NextFlag = 0
    }
    $page++
}

$AllGroups | Sort-Object mailNickname

# ALL TEAMS
$AllGroups | ? { $_.resourceProvisioningOptions -contains "team" }

# ALL SECURITY
$AllGroups | ? { $_.securityEnabled -eq $true }

# ALL DISTRO
$AllGroups | ? { $_.mailEnabled -eq $true }

# Batch Processing

$BatchReqHeader = @{
    Authorization  = "Bearer $($TokReqRes.access_token)"
    "Content-Type" = "Application/JSON"
} 

$BatchBody = @"
{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users/$username/drive/root:/tasks/"
    },
    {
      "id": "2",
      "method": "GET",
      "url": "/users"
    }
  ]
}
"@ 

$BatchRes = Invoke-RestMethod -Method POST -Uri "https://graph.microsoft.com/v1.0/`$batch" -Headers $BatchReqHeader -Body $BatchBody






