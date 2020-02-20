Import-Module -Name Az.ResourceGraph

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

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

#modify these
$query = "Resources | where type =~ 'microsoft.keyvault/vaults' | where properties.softDeleteRetentionInDays < 90"
$resourceType = 'microsoft.keyvault'

$results = Search-AzGraph -Query $query
$objArray = @()
foreach($result in $results){
    $obj = [PSCustomObject]@{
        ResourceName = $result.Name
        ResourceGroupName = $result.ResourceGroup
        ResourceID = $result.ResourceID
        ResourceLocation = $result.Location
        FailedQuery = $query
        ResourceType = $resourceType
    }

    $objArray += $obj
}

Write-Output ($objArray | Convertto-Json -Depth 5)