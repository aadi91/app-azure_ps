$subName = "rpu-prod-digital-01"
$_ = Get-AzSubscription -SubscriptionName $subName
$subscriptionId = $_.Id
$subscriptionName = $_.Name
write-host -ForegroundColor Yellow $subscriptionName
Set-AzContext -SubscriptionId $subscriptionId
$resourceGroupName = "prod-retail-cep-centralus-01"
Get-AzStorageAccount -ResourceGroupName $resourceGroupName
$containername = "cep-assets"
$data = @()
#$lastModifiedBlobTest = Get-AzStorageBlob -Container $containername -Context $ctx | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified

Get-AzStorageAccount -ResourceGroupName $resourceGroupName |  Where-Object { $_.NetworkRuleSet.DefaultAction -eq "Allow" } | ForEach-Object {
    $storageaccname = $_.StorageAccountName
    write-host "Storage Acc>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" -ForegroundColor Red $storageaccname
    $ctx = $_.Context
    #Get-AzStorageContainer -Context $ctx | Get-AzStorageBlob | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified, Name
    Get-AzStorageContainer -Context $ctx | Where-Object { $_.PublicAccess -eq "Blob" } | ForEach-Object {
        # zero out our total
                
        $containername = $_.Name
        Write-Host "containername?>>>>>>" -ForegroundColor Red $containername
        $blobsAvailable = "Yes"
        $lastModifiedBlob = Get-AzStorageBlob -Container $containername -Context $ctx | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified, Name
        $bName = $lastModifiedBlob.Name
        Write-Host "Blob Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" $bName
        $blobCount = $lastModifiedBlob.Count
        $latestModifiedDate = $lastModifiedBlob.LastModified
        $data += $latestModifiedDate
    Write-Host "data?>>>>>>" -ForegroundColor Green $data
    $data -is [System.Object]
    #Foreach-Object {$data | Sort-Object Datum | Select-Object -Last 1}
    
    }
    
    $newResult = $data | Sort-Object -Descending | Select-Object -First 1 LocalDateTime
    $finalResult = $newResult.LocalDateTime
    Write-Host "finalResult>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>?>>>>>>" -ForegroundColor Yello $finalResult
}

$subName = "rpu-prod-digital-01"
$_ = Get-AzSubscription -SubscriptionName $subName
$subscriptionId = $_.Id
$subscriptionName = $_.Name
write-host -ForegroundColor Yellow $subscriptionName
Set-AzContext -SubscriptionId $subscriptionId
$resourceGroupName = "prod-retail-cep-centralus-01"
Get-AzStorageAccount -ResourceGroupName $resourceGroupName
$containername = "cep-assets"
$lastModifiedBlobTest = Get-AzStorageBlob -Container $containername -Context $ctx | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified

Get-AzStorageAccount -ResourceGroupName $resourceGroupName |  Where-Object { $_.NetworkRuleSet.DefaultAction -eq "Allow" } | ForEach-Object {
    $storageaccname = $_.StorageAccountName
    write-host "Storage Acc>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" -ForegroundColor Red $storageaccname
    $ctx = $_.Context
    #Get-AzStorageContainer -Context $ctx | Get-AzStorageBlob | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified, Name
    Get-AzStorageContainer -Context $ctx | Where-Object { $_.PublicAccess -eq "Blob" } | ForEach-Object {
        # zero out our total
                
        $containername = $_.Name
        Write-Host "containername?>>>>>>" -ForegroundColor Red $containername
        $blobsAvailable = "Yes"
        $lastModifiedBlob = Get-AzStorageBlob -Container $containername -Context $ctx | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified
        $blobCount = $lastModifiedBlob.Count
               
        $latestModifiedDate = $lastModifiedBlob.LastModified
    }
}