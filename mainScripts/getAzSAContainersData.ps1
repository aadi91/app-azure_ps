$StartTime = get-date
$storageAccounts = Import-Csv U:\Project\Stories\780686\Source1.csv
$storageAccounts.count
### Change ###
foreach ($storageAccount in $storageAccounts) {
    $saName = $storageAccount.StorageAccount
    $saRG = $storageAccount.RG
    $saSub = $storageAccount.Subscription
    $prefixName = "blob"
    Write-Host "working on storage accounts" $saName
    $CurrentSubName = (Get-AzContext).Subscription.Name    
    if ($CurrentSubName -ne $storageAccount.Subscription) {
        Select-AzSubscription -SubscriptionName $saSub    
    }
    $storageAcc = Get-AzStorageAccount -ResourceGroupName $saRG -Name $saName
    ## Get the storage account context
    $ctx = $storageAcc.Context
    ## List all the containers
    $containers = Get-AzStorageContainer  -Context $ctx     
    foreach ($container in $containers) {    
        $containerName = $container.Name
        write-host -ForegroundColor Yellow $containerName
        $strVal = 'Hello world'
        if ($containerName -like $prefixName) {
            Write-Host 'Your string contains the word blob'
        }
        else {
            Write-Host 'Your string does not contains the word blob'
        }
    }
}
start-sleep -Seconds 5
$RunTime = New-TimeSpan -Start $StartTime -End (get-date)
Write-Host "Completed working on storage accounts. "Execution time was "$($RunTime.Hours)-"hours, "$($RunTime.Minutes)-"minutes, "$($RunTime.Seconds)-"seconds and "$($RunTime.Milliseconds)-"milliseconds." 
Check report at" $targetFilePath -ForegroundColor Green