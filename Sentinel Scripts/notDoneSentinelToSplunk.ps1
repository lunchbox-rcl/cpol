# Needs the AzureAD module, the AzAD commands don't surface what we need
$TenantID = "34983cf0-c783-459e-8b5e-e8623fe9f343"
# TODO: Find best practice logon code
$AzConnection = Connect-AzureAD -TenantID $TenantID 


# Needs to be unique in tennant
$appName = "Microsoft Graph Security API Splunk Add-On TEST TEST TEST"

# TODO: fix the below line
if(!(Get-AzureADApplication -DisplayName $appName  -ErrorAction SilentlyContinue))
{
  #Create a new Azure AD Application and set the secret password
  $myApp = New-AzureADApplication -DisplayName $appName
  $credObject = New-AzureADApplicationPasswordCredential -ObjectId $myApp.ObjectId 
  
  # Grant API Permissions
  $graphServicePrincipal = Get-AzureADServicePrincipal | Where-Object {$_.DisplayName -eq "Microsoft Graph"}
  $allowID = $graphServicePrincipal.Oauth2Permissions | Where-Object {$_.Value -eq "SecurityEvents.Read.All"}
  $req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
  $acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $allowID.ID,"Scope"
  $req.ResourceAccess = $acc1
  $req.ResourceAppId = $graphServicePrincipal.AppID
  Set-AzureADApplication -ObjectId $myApp.ObjectId -RequiredResourceAccess $req
  
  # Grant Consent

}