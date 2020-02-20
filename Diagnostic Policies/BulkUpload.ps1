$directories = Get-ChildItem -Directory
$location = "westus"
$managementGroupID = "/providers/Microsoft.Management/managementGroups/CC1"
$ParentDirectory = Get-Location
foreach($directory in $directories){
  Set-Location -Path $directory
  
  $PolicyInfo = Get-Content -Raw -Path ./azurepolicy.json | ConvertFrom-Json 
  $path = $pwd
  $Params = @{
    name = $PolicyInfo.displayName
    displayName = $PolicyInfo.displayName
    description = $PolicyInfo.description
    policy =  "./azurepolicy.rules.json"
    metaData = $PolicyInfo.metadata | ConvertTo-Json -Depth 10
    parameter = $PolicyInfo.parameters | ConvertTo-Json -Depth 10 
    mode = $PolicyInfo.mode
    # TODO: CHANGE THIS TO APPROPRIATE MANAGEMENTGROUP
    ManagementGroupName = 'CC1'
  }

  $policyDefObj = New-AzPolicyDefinition @Params 
  
  <#$assignmentParams = @{
    name = ((New-Guid).ToString().Split("-")[0])
    scope = $managementGroupID
    displayName = $PolicyInfo.displayName
    policyDefinition = $policyDefObj
    location = $location
    policyParameter = "./azurepolicy.parameters.json"
  }
  New-AzPolicyAssignment -Name ((new-guid).ToString().Split("-")[0]) -Scope $managementGroupID `
                          -DisplayName $PolicyInfo.displayName `
                          -PolicyDefinition $policyDefObj `
                          -PolicyParameter ./azurepolicy.parameters.json | Out-Null#>
  Set-Location -Path $ParentDirectory
}


#DONT USE THIS IN COSTCO ENV
$assignmentsToDelte = Get-AzPolicyAssignment | Where-Object {$_.Properties.displayName -ilike '*2020.01'}
foreach($ass in $assignmentsToDelte){
  Remove-AzPolicyAssignment -Id $ass.resourceID | Out-Null
}

$PoliciesToDelete = Get-AzPolicyDefinition -Custom | Where-Object {$_.Name -ilike '*2020.01'}
foreach($policyToDelete in $PoliciesToDelete){
  Remove-AzPolicyDefinition -Id $policyToDelete.ResourceID -Force| Out-Null
}