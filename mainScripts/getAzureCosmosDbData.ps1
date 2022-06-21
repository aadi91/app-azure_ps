Connect-AzAccount
$date = Get-Date -UFormat("%m-%d-%yT%H-%M-%S")
$currentDir = $(Get-Location).Path
$targetFilePath = "$($currentDir)\Azure_CosmosDB_Usage_Report-$($date).csv"
#$oFilePath = "U:\Azure_CosmosDB_Usage_Report-$($date).csv"

"COSMOS_DB_NAME,SUBSCRIPTION_NAME,RESOURCE_GROUP_NAME,DEPARTMENT,COST_CENTER,ENV_TYPE,Max_Percentage_30days,MONTHLY_COST" | Out-File $targetFilePath -Append -Encoding ascii
 
Get-AzSubscription | ForEach-Object {
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
    $subscriptionTags = $_.Tags
    $TenentID = $_.TenantId
    $tagcount = $_.Tags.Count
    Set-AzContext -SubscriptionId $subscriptionId
    Get-AzResourceGroup | ForEach-Object {
        $resourceGroupName = $_.ResourceGroupName
        Get-AzCosmosDBAccount -ResourceGroupName  $resourceGroupName | ForEach-Object {
            $cdbName = $_.Name
            $cdbid = $_.Id
            $Department = $_.Tags.Department
            $CostCentre = $_.Tags.CostCenter
            $EnvType = $_.Tags.EnvType
            $name = (Get-AzResource -ResourceId $cdbid).Name
            $metricdata = Get-AzMetric -ResourceId $cdbid -TimeGrain 00:05:00 -MetricName "NormalizedRUConsumption" -AggregationType Maximum -WarningAction Ignore -StartTime (Get-Date).adddays(-30) -EndTime (Get-Date) -DetailedOutput
            $metricdata | ForEach-Object {
                $metric_used = $_.Data.Maximum | measure -Maximum
                $metric_maximum = $metric_used.Maximum
                $Consumption = Get-AzConsumptionUsageDetail -StartDate (Get-Date).adddays(-30) -EndDate (Get-Date) -InstanceID $cdbid
                $Costs = $Consumption.PretaxCost
                Write-Output $Costs
                $MonthlyCostTotal = 0
                foreach ($Cost in $Costs) { $MonthlyCostTotal += $Cost }
                Write-Output $Cost
                Write-Output $MonthlyCostTotal
                $MonthlyCostTotalRound = [math]::Round($MonthlyCostTotal)
                "$cdbName,$subscriptionName,$resourceGroupName,$Department,$CostCentre,$EnvType,$metric_maximum,$MonthlyCostTotalRound" | Out-File $targetFilePath -Append -Encoding ascii
            }
        }
    }
}

$StartTime = get-date 
start-sleep -Seconds 5 
$RunTime = New-TimeSpan -Start $StartTime -End (get-date) 
Write-Host "Completed. Script took "$($RunTime.Hours) "hours. Check report at" $targetFilePath -ForegroundColor Green