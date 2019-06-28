#Permissions needed: DeviceManagementConfiguration.ReadWrite.All, DeviceManagementConfiguration.Read.All


#Getting all device compliance policies
$apiUrl = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$CompliancePolicies = ($Data | Select-Object Value).Value

$CompliancePolicies 

