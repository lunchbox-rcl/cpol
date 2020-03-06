Param
(
  [Parameter (Mandatory= $true)]
  [String] $ResourceGroupName,

  [Parameter (Mandatory= $true)]
  [String] $VMName 
)                                              


$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

foreach($networkInterface in $Vm.NetworkProfile){
    $nic = Get-AzNetworkInterface -ResourceId "/subscriptions/79490eff-7f62-4a19-b295-9fb341ced347/resourceGroups/dick-rg/providers/Microsoft.Network/networkInterfaces/dicktesting31"

    # If there is already a NSG
    if($nic.NetworkSecurityGroup){
        # Get the id for the NSG
        $nsgId = $nic.NetworkSecurityGroup.Id
        $resource = Get-AzResource -ResourceId $nsgId
        $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resource.ResourceGroupName -Name $resource.Name

        Add-AzNetworkSecurityRuleConfig -Name "QuarantineInboundRule" `
            -NetworkSecurityGroup $nsg `
            -Access Deny `
            -Protocol * `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange * | Out-Null
        Add-AzNetworkSecurityRuleConfig -Name "QuarantineOutboundRule" `
            -NetworkSecurityGroup $nsg `
            -Access Deny `
            -Protocol * `
            -Direction Outbound `
            -Priority 100 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange * | Out-Null
        Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg | Out-Null
    }
    # If no NSG on NIC, put one there
    else{
        $rule1 = New-AzNetworkSecurityRuleConfig -Name "QuarantineInboundRule" `
            -Access Deny `
            -Protocol * `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange * 
        $rule2 = New-AzNetworkSecurityRuleConfig -Name "QuarantineOutboundRule" `
            -Access Deny `
            -Protocol * `
            -Direction Outbound `
            -Priority 100 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange * 
        $newNSG = New-AzNetworkSecurityGroup -Name 'QuarantineSecurityGroup' -Location $VM.Location -ResourceGroupName $VM.ResourceGroupName -SecurityRules $rule1, $rule2 
        $nic.NetworkSecurityGroup = $newNSG
        Set-AzNetworkInterface -NetworkInterface $nic | Out-Null
    }
}
