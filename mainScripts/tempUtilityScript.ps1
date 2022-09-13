#$StorageAccounts = Get-AzStorageAccount -ResourceGroupName $_.ResourceGroupName | Where-Object {$_.NetworkRuleSet.DefaultAction -eq "Allow"

connect-azAccount
$date = Get-Date -UFormat("%m-%d-%yT%H.%M.%S")
#$currentDir = "U:\temp"
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\Azure_StorageAccount_LastModified_List_$($date).csv"
$blobLastModifiedDates = @()
$blobContainerNameForLastModifiedDate = @()
 
"SUBSCRIPTION_NAME,RESOURCE_GROUP_NAME,STORAGE_ACC_NAME,CONTAINER_NAME,BLOBS_AVAILABLE?,LAST_MODIFIED_DATE(CST)" | Out-File $oFile -Append -Encoding ascii
 
Get-AzSubscription | ForEach-Object {
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
    $subscriptionTags = $_.Tags
    $TenentID = $_.TenantId
    $tagcount = $_.Tags.Count
    Set-AzContext -SubscriptionId $subscriptionId

    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {    
        $resourceGroupName = $resourceGroup.ResourceGroupName
       
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
                $lastModifiedBlob = Get-AzStorageContainer -Context $ctx | Sort-Object LastModified -Descending | Select-Object -First 1 LastModified
                $blobCount = $lastModifiedBlob.Count
                $latestModifiedDate = $lastModifiedBlob.LastModified
                $result = [string]::IsNullOrEmpty($latestModifiedDate)
                if ($result -eq 'True') {
                    $latestModifiedDate = "Not Applicable"
                    $blobsAvailable = "No"
                    Write-Host "latestModifiedDateIfIF>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" -ForegroundColor Green $latestModifiedDate
                }
                $blobLastModifiedDates += $latestModifiedDate
                $blobContainerNameForLastModifiedDate += "$($latestModifiedDate) #$($containername)"
                $blobContainerLastModifiedDate = $string.Split("#")
                #Write-Host "$($assoc.Id) - $($assoc.Name) - $($assoc.Owner)"
                Write-Host "blobLastModifiedDatesWithContainerName?>>>>>>" -ForegroundColor Green $blobLastModifiedDates
                Write-Host "latestModifiedDateDateOut>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" -ForegroundColor Green $latestModifiedDate
                $blobsLatestModifiedDateTime = $blobLastModifiedDates | Sort-Object -Descending | Select-Object -First 1 LocalDateTime
                $containerLastModifiedDateTime = $blobsLatestModifiedDateTime.LocalDateTime
                Write-Host "finalResultcontainerLastModifiedDateTime>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>?>>>>>>" -ForegroundColor Yellow $containerLastModifiedDateTime
                $string1 = $blobContainerNameForLastModifiedDate
                foreach ($string in $string1) {
                    Write-host "string>>>>>>>>>>>>>>>>>>>>" $string
                    if ($string -like "*$containerLastModifiedDateTime*") {
                        Write-host -ForegroundColor Yellow "String contains>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
                        $finalBlobContainerName = $blobContainerLastModifiedDate
                        Write-host "finalBlobContainerName>>>>>>>>>>>>>>>>>>>>" -ForegroundColor Green $finalBlobContainerName
                    }
                    else {
                        Write-host "String cannot find"
                    }

                    #$blobContainerWithLastModifiedDateTime = $blobContainerLastModifiedDate[0]
                    #Write-host "blobContainerWithLastModifiedDateTime>>>>>>>>>>>>>>>>>>>>" $blobContainerWithLastModifiedDateTime
                    
                }
                "$subscriptionName,$resourceGroupName,$storageaccname,$finalBlobContainerName,$blobsAvailable,$containerLastModifiedDateTime" | Out-File $oFile -Append -Encoding ascii
            }
            
        }
    }
}
Write-Host "script executed successfully" -ForegroundColor Green

