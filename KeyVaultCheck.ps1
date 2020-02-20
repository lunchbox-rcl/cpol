Import-Module -Name Az.ResourceGraph

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null

    Connect-AzAccount -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId | Out-Null
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$results = Search-AzGraph -Query "Resources | where type =~ 'microsoft.keyvault/vaults' | where properties.softDeleteRetentionInDays <= 90"
$objArray = @()
foreach($result in $results){
    $obj = [PSCustomObject]@{
        ResourceName = $result.Name
        ResourceGroupName = $result.ResourceGroup
        ResourceID = $result.ResourceID
        ResourceLocation = $result.Location
    }

    $objArray += $obj
}

Write-Output ($objArray | Convertto-Json -Depth 5 -AsArray)