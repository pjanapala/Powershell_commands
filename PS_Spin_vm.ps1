$ResouceGroup = "JPKRG"
$Location = "eastus"
$Storageaccountname = "jpkstore"
$Vnetname = "JPVNET"
$nicName = "JPNIC"
$nicName = "JPNIC"
$vmname = "win-web"
$diskname="os-disk"
    
New-AzureRMResourcegroup -name $ResouceGroup -Location $Location
New-AzureRmStorageAccount -name $Storageaccountname -type Standard_LRS -ResourceGroupName $ResouceGroup -Location $Location

$Vnetname = "JPVNET"
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name FrontendSubnet -AddressPrefix 10.0.1.0/24
$vnet = New-AzureRmVirtualNetwork -Name $Vnetname -ResourceGroupName $ResouceGroup -Location $Location -AddressPrefix 10.0.0.0/16 -subnet $subnet

$nicName = "JPNIC"
$pip = New-AzureRmPublicIpAddress -Name $nicName -ResourceGroupName $ResouceGroup -Location $Location -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResouceGroup -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$vmname = "win-web"
$diskname="os-disk"
$vm = New-AzureRmVMConfig -VMName $vmname -VMSize "basic_A1"
$cred = Get-Credential -Message "Admin Credentials"
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmname -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMSourceImage -vm $vm -PublisherName "Microsoftwindowsserver" -Offer "windowsserver" -Skus "2012-R2-datacenter" -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -Vm $vm -ID $nic.Id
$storageAcc = Get-AzureRMStorageAccount -ResourceGroupName $ResouceGroup -Name $Storageaccountname
$osdiskuri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskname + ".vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskname  -VhdUri $osdiskuri -CreateOption fromimage

New-AzureRmVM -ResourceGroupName $ResouceGroup -Location $Location -VM $vm