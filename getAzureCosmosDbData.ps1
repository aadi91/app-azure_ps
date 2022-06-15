connect-azAccount
$date = Get-Date -UFormat("%m-%d-%yT%H-%M-%S")
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\List_Of_All_Azure_Resources_$($date).csv"

if (Test-Path $oFile) {
    Remove-Item $oFile -Force
}
 
"COSMOS_DB_NAME,SUBSCRIPTION_NAME,RESOURCE_GROUP_NAME,DEPARTMENT,COST_CENTER,ENV_TYPE,MATRIC_MAX" | Out-File $oFile -Append -Encoding ascii
 
Get-AzSubscription | ForEach-Object {
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
    #$subscriptionTags = $_.Tags
    #$TenentID = $_.TenantId
    #$tagcount = $_.Tags.Count
    Set-AzContext -SubscriptionId $subscriptionId
    Get-AzResourceGroup | ForEach-Object {
        $resourceGroupName = $_.ResourceGroupName
        Get-AzCosmosDBAccount -ResourceGroupName  $resourceGroupName | ForEach-Object {
            $cdbName = $_.Name
            $cdbid = $_.Id
            $Department = $_.Tags.Department
            $CostCentre = $_.Tags.CostCenter
            $EnvType = $_.Tags.EnvType
            #$name = (Get-AzResource -ResourceId $cdbid).Name
            $metricdata = Get-AzMetric -ResourceId $cdbid -TimeGrain 00:05:00 -MetricName "NormalizedRUConsumption" -AggregationType Maximum -WarningAction Ignore -StartTime (Get-Date).adddays(-30) -EndTime (Get-Date) -DetailedOutput
            $metricdata | ForEach-Object {
                $metric_used = $_.Data.Maximum | measure -Maximum
                $metric_maximum = $metric_used.Maximum
                "$cdbName,$subscriptionName,$resourceGroupName,$Department,$CostCentre,$EnvType,$metric_maximum" | Out-File $oFile -Append -Encoding ascii
            }
        }
    }
}
Write-Host "script executed successfully" -ForegroundColor Green
