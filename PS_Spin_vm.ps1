$ResouceGroup = "JPKRG"
$Location = "eastus"
$Storageaccountname = "jpkstore"

    
New-AzureRMResourcegroup -name $ResouceGroup -Location $Location
New-AzureRmStorageAccount -name $Storageaccountname -type Standard_LRS -ResourceGroupName $ResouceGroup -Location $Location

#Create vnet
$Vnetname = "JPVNET"
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name FrontendSubnet -AddressPrefix 10.0.1.0/24
$vnet = New-AzureRmVirtualNetwork -Name $Vnetname -ResourceGroupName $ResouceGroup -Location $Location -AddressPrefix 10.0.0.0/16 -subnet $subnet

#windows server
$nicName = "JPNICWin"
$pip = New-AzureRmPublicIpAddress -Name $nicName -ResourceGroupName $ResouceGroup -Location $Location -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResouceGroup -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$vmname = "win-web"
$vm = New-AzureRmVMConfig -VMName $vmname -VMSize "basic_A1"
$cred = Get-Credential -Message "Admin Credentials"
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmname -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMSourceImage -vm $vm -PublisherName "Microsoftwindowsserver" -Offer "windowsserver" -Skus "2012-R2-datacenter" -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -Vm $vm -ID $nic.Id

$diskname="os-disk"
$storageAcc = Get-AzureRMStorageAccount -ResourceGroupName $ResouceGroup -Name $Storageaccountname
$osdiskuri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskname + ".vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskname  -VhdUri $osdiskuri -CreateOption fromimage

New-AzureRmVM -ResourceGroupName $ResouceGroup -Location $Location -VM $vm

#linux server
$nic2Name = "JPNICLINUX"
$pip2 = New-AzureRmPublicIpAddress -Name $nic2Name -ResourceGroupName $ResouceGroup -Location $Location -AllocationMethod Dynamic
$nic2 = New-AzureRmNetworkInterface -Name $nic2Name -ResourceGroupName $ResouceGroup -Location $Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$vm2name = "Linux-web"
$vm2 = New-AzureRmVMConfig -VMName $vm2name -VMSize "basic_A1"
$cred2 = Get-Credential -Message "Admin Credentials"
$vm2 = Set-AzureRmVMOperatingSystem -VM $vm2 -Linux -ComputerName $vm2name -Credential $cred2 
$vm2 = Set-AzureRmVMSourceImage -vm $vm2 -PublisherName "Canonical" -Offer "Ubuntuserver" -Skus "14.04.5-LTS" -Version "latest"
$vm2 = Add-AzureRmVMNetworkInterface -Vm $vm2 -ID $nic2.Id

$disk2name="ub-os-disk"
$storageAcc = Get-AzureRMStorageAccount -ResourceGroupName $ResouceGroup -Name $Storageaccountname
$osdisk2uri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskname + ".vhd"
$vm2 = Set-AzureRmVMOSDisk -VM $vm2 -Name $disk2name  -VhdUri $osdisk2uri -CreateOption fromimage

New-AzureRmVM -ResourceGroupName $ResouceGroup -Location $Location -VM $vm2