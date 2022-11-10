$StartTime = get-date
Connect-AzAccount
$date = Get-Date -UFormat("%m-%d-%yT%H-%M-%S")
$currentDir = $(Get-Location).Path
#To open directory and select subscriptions list CSV file.
Add-Type -AssemblyName System.Windows.Forms
$File = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Filter = 'File Name (*.csv, *.xlsx)|*.csv;*.xlsx'
}
$File.ShowDialog()
$sourcefilePath = $File.FileName
Write-Host "Src File Path>>>>>>>>" $sourcefilePath
$subscriptionsList = Import-Csv $sourcefilePath
Write-Host "No Of Subscriptions Given:" $subscriptionsList.count
$targetFilePath = "$($currentDir)\Azure_VM_Cost_Report-$($date).csv"
# Generated report will be available at the following location - ""
"VM_NAME,SUBSCRIPTION_NAME,RESOURCE_GROUP_NAME,DEPARTMENT,COST_CENTER,ENV_TYPE,MONTHLY_COST$" | Out-File $targetFilePath -Append -Encoding ascii
foreach ($subscription in $subscriptionsList) {
    Write-Host "subscription>>>>>>>>" $subscription.subName
    $_ = Select-AzSubscription -SubscriptionName $subscription.subName
    $subscriptionId = $_.Subscription
    $subscriptionName = $subscription.subName
    $TenentID = $_.Tenant
    Set-AzContext -SubscriptionId $subscriptionId
    Get-AzResourceGroup | ForEach-Object {
        $resourceGroupName = $_.ResourceGroupName
        Get-AzVM -ResourceGroupName  $resourceGroupName | ForEach-Object {
            $vmName = $_.Name
            $vmId = $_.Id
            $dept = $_.Tags.Department
            $Department = $dept -replace(", "," ")
            $costCntr = $_.Tags.CostCenter
            $CostCentre = $costCntr -replace(", "," ")
            $EnvType = $_.Tags.EnvType
            Write-Host "VM Name>>>>>>>>>>>>" $vmName -ForegroundColor Red
                $Consumption = Get-AzConsumptionUsageDetail -StartDate (Get-Date).adddays(-30) -EndDate (Get-Date) -InstanceID $vmId
                $Costs = $Consumption.PretaxCost
                $MonthlyCostTotal = 0
                foreach ($Cost in $Costs) { $MonthlyCostTotal += $Cost }
                $MonthlyCostTotalRound = [math]::Round($MonthlyCostTotal)
                Write-Host "VM Monthly Cost>>>>>>>>>>>>>>>>>>>>"  $vmName":" "$"$MonthlyCostTotalRound -ForegroundColor Yellow 
                "$vmName,$subscriptionName,$resourceGroupName,$Department,$CostCentre,$EnvType,$MonthlyCostTotalRound" | Out-File $targetFilePath -Append -Encoding ascii
        }
    }
}

start-sleep -Seconds 5 
$RunTime = New-TimeSpan -Start $StartTime -End (get-date) 
Write-Host "Script Execution Completed. "Execution time was "Hours:$($RunTime.Hours)", "Minutes:$($RunTime.Minutes)", "Seconds:$($RunTime.Seconds)" and "MilliSeconds:$($RunTime.Milliseconds)". Report is available at the following location $targetFilePath -ForegroundColor Green