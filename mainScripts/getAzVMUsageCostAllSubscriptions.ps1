Connect-AzAccount
$StartTime = get-date 
$date = Get-Date -UFormat("%m-%d-%yT%H-%M-%S")
$currentDir = $(Get-Location).Path
$targetFilePath = "$($currentDir)\Azure_VM_Cost_Report-$($date).csv"
# Generated report will be available at the following location - ""
"VM_NAME,SUBSCRIPTION_NAME,RESOURCE_GROUP_NAME,DEPARTMENT,COST_CENTER,ENV_TYPE,MONTHLY_COST$" | Out-File $targetFilePath -Append -Encoding ascii
Get-AzSubscription | ForEach-Object {
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
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
                $Consumption = Get-AzConsumptionUsageDetail -StartDate (Get-Date).adddays(-30) -EndDate (Get-Date) -InstanceID $vmId
                $Costs = $Consumption.PretaxCost
                $MonthlyCostTotal = 0
                foreach ($Cost in $Costs) { $MonthlyCostTotal += $Cost }
                $MonthlyCostTotalRound = [math]::Round($MonthlyCostTotal)
                Write-Host "VM Monthly Cost>>>>>>>>>>>>>>>>>>>>"  $vmName":" "$"$MonthlyCostTotalRound -ForegroundColor Green
                "$vmName,$subscriptionName,$resourceGroupName,$Department,$CostCentre,$EnvType,$MonthlyCostTotalRound" | Out-File $targetFilePath -Append -Encoding ascii
        }
    }
}

start-sleep -Seconds 5 
$RunTime = New-TimeSpan -Start $StartTime -End (get-date) 
Write-Host "Completed. Script took "$($RunTime.Hours) "hours. Check report at" $targetFilePath -ForegroundColor Yellow