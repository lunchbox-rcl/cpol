$subSource = Read-host "Enter the Subscription of the source Sentinel workspace"
$workspaceSource = Read-host "Enter the workspace name"

<# $subDest = Read-host "Enter the Subscription of the destination Sentinel workspace"
$workspaceDest = Read-host "Enter the destination workspace name" #>

Set-AzContext -Subscription $subSource <# az-pd-log01 #>

$allAlerts = Get-AzSentinelAlertRule -WorkspaceName $workspaceSource <# "az-pd-log-ws-us-priv-ent-all-azla-arm-001e" #>

<# Start the json file with '[' #>
$preText = "["
write-output $preText | add-content .\thisisafile.json

<# Iterate through all alerts and tailor them for upload #>
$i = 0

foreach ($alert in $allAlerts)
{

    $alert.PSObject.Properties.Remove('alertRuleTemplateName')
    $alert.PSObject.Properties.Remove('lastModifiedUtc')
    $alert.PSObject.Properties.Remove('name')
    $alert.PSObject.Properties.Remove('etag')
    $alert.PSObject.Properties.Remove('id')

    <# Creating a foreach loop to alter values that will not be accepted during upload time #>

    foreach ($element in $alert.PSObject.Properties)
    {
        $objName = $element.Name
        $objValue = $element.Value
        <# Regex to remove the ISO 8601 variables that are not accepted #>
        if ($objValue -match '^PT\d*\w')   
        {
            $element.Value = $objValue.Replace('PT', '')
        }
        if ($objValue -match 'P1D')   
        {
            $element.Value = $objValue.Replace('P', '')
        }
        <# Might need to input error handling for null fields etc. #>
    }

    <# Declaring variables to append strings to alert json #>
    $analyticsText = '{ "analytics": ['
    $suffixText1 = '] } ,'
    $suffixText2 = '] }'


    if ($i -le ($allAlerts.length-2))
    {
        <# Converts the alert to json for an output file #>
        $outputFile = $alert | convertto-json
        <# Write all of the components to the json #>
        <# Prefix + alert + suffix1 #>
        Write-Output $analyticsText | add-content .\thisisafile.json
        Write-Output $outputFile | add-content .\thisisafile.json
        Write-Output $suffixText1 | add-content .\thisisafile.json
    }

    else
    {
        <# Converts the alert to json for an out-file #>
        $outputFile = $alert | convertto-json
        <# Write all of the components to the json #>
        <# Prefix + alert + suffix2 #>
        Write-Output $analyticsText | add-content .\thisisafile.json
        Write-Output $outputFile | add-content .\thisisafile.json
        Write-Output $suffixText2 | add-content .\thisisafile.json
    }

    <# Increment #>
    $i += 1

}

<# Append ']' to the json file #>
$postText = "]"
write-output $postText | add-content .\thisisafile.json

<# Placeholder for testing since the destWorkspace is not intantiated through an input at the start #>
$destWorkspace = "az-sdg-asdg-txa"

<# Count array elements for the end output #>
$countarray = $allAlerts.Count

write-output " "

write-host "Successfully wrote $countarray analytics rule(s) to $destWorkspace."


<# Upload the analytics file to the new workspace #>
<# Set-AzContext -Subscription $subDest #>
<# Import-AzSentinelAlertRule -WorkspaceName $workspaceDest -SettingsFile ".\thisisafile.json"  #>