$subSource = Read-host "Enter the Subscription of the source Sentinel workspace"
$workspaceSource = Read-host "Enter the workspace name"

<# $subDest = Read-host "Enter the Subscription of the destination Sentinel workspace"
$workspaceDest = Read-host "Enter the destination workspace name" #>

Set-AzContext -Subscription $subSource <# az-pd-log01 #>

<# Get all custom Sentinel alerts.  The 'builtIn' Alerts do not have a value for 'eTag' set for them as of 2/17/2020 #>
$allHuntingQueries = Get-AzSentinelHuntingRule -WorkspaceName $workspaceSource | Where-Object {$_.etag -ne $null}


<# Start the json file with '[' #>
$preText = "{ ""analytics"": ["
write-output $preText | add-content .\thisisafile.json

<# Iterate through all alerts and tailor them for upload #>
$i = 0

foreach ($alert in $allHuntingQueries)
{
    $alert.PSObject.Properties.Remove('name')
    $alert.PSObject.Properties.Remove('etag')
    $alert.PSObject.Properties.Remove('id')
    $alert.PSObject.Properties.Remove('Version')
    $alert.PSObject.Properties.Remove('Category')
    $alert | Add-Member -NotePropertyName 'Description' -NotePropertyValue ($alert.Tags | Where-Object {$_.name -like 'description'}).Value | Out-Null

    $TacticsString = ($alert.Tags | Where-Object {$_.name -like 'tactics'}).Value
    [array]$tacticsArray = $TacticsString -split ","
    $alert | Add-Member -NotePropertyName 'Tactics' -NotePropertyValue $tacticsArray | Out-Null
    $alert.PSObject.Properties.Remove('Tags')
    

    <# Declaring variables to append strings to alert json #>
    #$analyticsText = '{ '
    $suffixText1 = ','
    $suffixText2 = '] }'

    if ($i -le ($allHuntingQueries.length-2))
    {
        <# Converts the alert to json for an output file #>
        $outputFile = $alert | convertto-json
        Write-Output $outputFile | add-content .\thisisafile.json
        Write-Output $suffixText1 | add-content .\thisisafile.json
    }

    else
    {
        <# Converts the alert to json for an out-file #>
        $outputFile = $alert | convertto-json
        Write-Output $outputFile | add-content .\thisisafile.json
    }

    <# Increment #>
    $i += 1

}

<# Append ']' to the json file #>
$postText = "]}"
write-output $postText | add-content .\thisisafile.json

