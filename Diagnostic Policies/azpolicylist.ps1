$rootName = (Get-AzManagementGroup)[0].Name
$root = Get-AzManagementGroup -GroupName $rootName -Expand -Recurse

Function Get-ChildrenInfo
{
  [CmdletBinding()]
  Param(
  [Parameter(Mandatory=$true)][object]$node,
  [int]$recursionDepth = 0
  )

  write-host $Node.DisplayName -ForegroundColor Green
  $PolicyAssignments = Get-AzPolicyAssignment -Scope $Node.id

  foreach($Policy in $policyAssignments)
  {
    write-host $policy.properties.displayName -foregroundcolor yellow
  }

  [array]$children = $node.children
  if($children.count -gt 1)
  {
    [array]::Reverse($Children)
  }

  foreach($child in $children)
  {
    if($child.type -ilike '/providers*')
    {
      Get-ChildrenInfo -node $child
    }
    if($child.type -ilike '/subscriptions')
    {
      write-host "$($child.displayname)'s Subscription Policy" -Foregroundcolor cyan
      $assignments = get-azpolicyassignment -scope $child.id

      foreach($assignment in $assignments)
      {
        if($assignment -ne $null)
        {
          write-host 'a' $assignment.properties.displayname -foregroundcolor red
        }

        else
        {
          write-host 'None' -foregroundcolor darkred
        }
      }
    }
  }
}
    

Get-ChildrenInfo -node $root