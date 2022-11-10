#https://www.rebeladmin.com/2020/06/step-step-guide-create-azure-windows-virtual-machine-snapshot-powershell-guide/
#https://www.jorgebernhardt.com/create-multiple-identical-vms-at-once-with-azure-powershell/

connect-azAccount
$subscription = "ae0e4f48-d135-461b-9843-132dcfvdg"
$RG = "demo-rg"
$VMNAMES = @("VM1")
Select-AzSubscription -Subscription "$subscription"

foreach($vmname in $VMNAMES){
Write-Host "$vmname is ready for snapshort creation" -ForegroundColor Yellow
$vm = Get-AzVM -ResourceGroupName $RG -Name $VMNAME
$location = $vm.Location

#$snapshot = Get-AzSnapshot -ResourceGroupName $RG -SnapshotName rebelvmsnap1
$snapshotconf = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
Write-Host "Creating Snapshort for $vmname" -ForegroundColor Cyan
$newsnap = New-AzSnapshot -Snapshot $snapshotconf -SnapshotName "$($vm.StorageProfile.OsDisk.Name)-snapshort" -ResourceGroupName $RG

Write-Host "Snapshort creation ProvisioningState is $($newsnap.ProvisioningState) for $($vmname) , the snapshort name is $($newsnap.Name) " -ForegroundColor Green


}