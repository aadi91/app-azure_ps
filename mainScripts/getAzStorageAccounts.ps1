$StartTime = get-date
# Connect to Azure Account
Connect-AzAccount

$date = Get-Date -UFormat("%m-%d-%yT%H.%M.%S")
$currentDir = $(Get-Location).Path
$targetFilePath = "$($currentDir)\Azure_StorageAccounts_List-$($date).csv"

"STORAGE_ACCOUNT_NAME,RESOURCE_GROUP_NAME,SUBSCRIPTION_NAME,DEPARTMENT,COST_CENTER,ENV_TYPE" | Out-File $targetFilePath -Append -Encoding ascii
 
# Create Report Array
#$report = @()
# Record all the subscriptions in a Text file  
# $SubscriptionIds = Get-Content -Path "c:\inputs\Subscriptions.txt"
$SubscriptionIds = Get-AzSubscription
Foreach ($SubscriptionId in $SubscriptionIds) {
    $subscriptionName = $subscriptionId.Name
    # Select the subscription  
    Select-AzSubscription $subscriptionId
    Write-Host "Selected Subscription Id" $subscriptionId
    Write-Host "Selected Subscription Name" $subscriptionName
    $storageAccountNames = Get-AzStorageAccount
    foreach ($storageAccountName in $storageAccountNames) {
        $saName = $storageAccountName.StorageAccountName
        $rgName = $storageAccountName.ResourceGroupName
        $Department = $storageAccountName.Tags.Department
        $CostCentre = $storageAccountName.Tags.CostCenter
        $EnvType = $storageAccountName.Tags.EnvType
    }
    "$saName,$rgName,$subscriptionName,$Department,$CostCentre,$EnvType" | Out-File $targetFilePath -Append -Encoding ascii
}

start-sleep -Seconds 5
$RunTime = New-TimeSpan -Start $StartTime -End (get-date)
Write-Host "Completed working on storage accounts. "Execution time was "$($RunTime.Hours)-"hours, "$($RunTime.Minutes)-"minutes, "$($RunTime.Seconds)-"seconds and "$($RunTime.Milliseconds)-"milliseconds." 
Check report at" $targetFilePath -ForegroundColor Green