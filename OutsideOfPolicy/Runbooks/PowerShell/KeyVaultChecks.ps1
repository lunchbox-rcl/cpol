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
#TODO: Figure out how we can just have this as a CSV that Azure Automation can ingest
$queries = "Resources | where type =~ 'microsoft.keyvault/vaults' | where properties.softDeleteRetentionInDays < 90", `
            "Resources | where type =~ 'microsoft.keyvaults/vaults' | where properties.softDeleteRetentionInDays > 180"
$resourceType = 'microsoft.keyvault'


$objArray = @()
foreach($query in $queries)
{
    $results = Search-AzGraph -Query $query
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
}

Write-Output ($objArray | Convertto-Json -Depth 5)