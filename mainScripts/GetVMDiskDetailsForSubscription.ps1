# Login to Azure Account
Login-AzAccount

# Connect to Azure Account
Connect-AzAccount
 
# Create Report Array
$report = @()
# Record all the subscriptions in a Text file  
# $SubscriptionIds = Get-Content -Path "c:\inputs\Subscriptions.txt"
$SubscriptionIds = Get-AzSubscription
Foreach ($SubscriptionId in $SubscriptionIds) {
    $reportName = "VM-Details.csv"
 
    # Select the subscription  
    Select-AzSubscription $subscriptionId
 
    # Get all the VMs from the selected subscription
    $vms = Get-AzVM
 
    # Get all the Public IP Address
    $publicIps = Get-AzPublicIpAddress

    # Get all the Network Interfaces
    $nics = Get-AzNetworkInterface | ? { $_.VirtualMachine -NE $null }
    foreach ($nic in $nics) {
        # Creating the Report Header, taken maxium 3 disks but it can be extended based on the need
        $ReportDetails = "" | Select VmName, ResourceGroupName, subscriptionId, Region, VmSize, VirtualNetwork, PrivateIpAddress, PublicIPAddress, OSDiskName, OSDiskSize (GiB), DataDiskCount, DataDisk1Name, DataDisk1Size (GiB), DataDisk2Name, DataDisk2Size (GiB), DataDisk3Name, DataDisk3Size (GiB)
        #Get VM IDs
        $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id
        foreach ($publicIp in $publicIps) {
            if ($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                $ReportDetails.PublicIPAddress = $publicIp.ipaddress
            }
        }        
        $ReportDetails.VMName = $vm.Name
        $ReportDetails.ResourceGroupName = $vm.ResourceGroupName
        $ReportDetails.Region = $vm.Location
        $ReportDetails.VmSize = $vm.HardwareProfile.VmSize
        $ReportDetails.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3]
        $ReportDetails.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress
        $ReportDetails.OSDiskName = $vm.StorageProfile.OsDisk.Name
        $ReportDetails.OSDiskSize = $vm.StorageProfile.OsDisk.DiskSizeGB
        $ReportDetails.DataDiskCount = $vm.StorageProfile.DataDisks.count
 
        if ($vm.StorageProfile.DataDisks.count -gt 0) {
            $disks = $vm.StorageProfile.DataDisks
            foreach ($disk in $disks) {
                If ($disk.Lun -eq 0) {
                    $ReportDetails.DataDisk1Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name
                    $ReportDetails.DataDisk1Size = $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB
         
                }
                elseif ($disk.Lun -eq 1) {
                    $ReportDetails.DataDisk2Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name
                    $ReportDetails.DataDisk2Size = $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB
                }
                elseif ($disk.Lun -eq 2) {
                    $ReportDetails.DataDisk3Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name
                    $ReportDetails.DataDisk3Size = $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB
       
                }
            }
        }
        $report += $ReportDetails
    }
}
     
$report | ft VmName, ResourceGroupName, Region, VmSize, OSDiskName, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Size  
#Path to save the generated spreadsheet
$report | Export-CSV "U:\Scripts\$reportName"