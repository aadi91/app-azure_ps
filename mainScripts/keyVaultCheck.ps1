
$startTime = Get-Date

$KeyVaults = Import-Csv U:\Project\CRQ\Azure_Key_Vaults\KeyVault_NonCompliant_List.csv
$KeyVaults.count


### Checking #######

Write-Output "****************************Checking*****************************"

foreach ($KeyVault in $KeyVaults) {

    $CurrentSubName = (Get-AzContext).Subscription.Name    
if ($CurrentSubName -ne $KeyVault.Subscription) {
    Select-AzSubscription -SubscriptionName $KeyVault.Subscription    
}


    $keyVaultCheck = Get-AzKeyVault -VaultName $KeyVault.KeyVaultName
    Write-Host $KeyVault.KeyVaultName "has SKU" $keyVaultCheck.Sku
    Write-Host $KeyVault.KeyVaultName "has EnablePurgeProtection set to" $keyVaultCheck.EnablePurgeProtection
    Write-Host $KeyVault.KeyVaultName "has EnableSoftDelete set to" $keyVaultCheck.EnableSoftDelete
    

}

$EndTime = Get-Date
$TimeScript = $EndTime - $startTime
$TimeScriptHours = [Math]::Round($TimeScript.TotalHours,3)
Write-Host "Completed. Script took "$TimeScriptHours "hours"
