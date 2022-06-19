
$startTime = Get-Date

$KeyVaults = Import-Csv U:\Project\CRQ\Azure_Key_Vaults\KeyVault_NonCompliant_List.csv
$KeyVaults.count
### Change ###
foreach ($KeyVault in $KeyVaults) {

Write-Host "working on KeyVault"  $KeyVault.KeyVaultName
$CurrentSubName = (Get-AzContext).Subscription.Name    
if ($CurrentSubName -ne $KeyVault.Subscription) {
   Select-AzSubscription -SubscriptionName $KeyVault.Subscription    
}


$vaultResourceId = (Get-AzKeyVault -VaultName $KeyVault.KeyVaultName).ResourceId
$vault = Get-AzResource -ResourceId $vaultResourceId -ExpandProperties

 Key Vault SKU change ###
$vault.Properties.sku.name =  "Premium" # or "Standard"

 Key Vault Soft-delete change ###
if ($vault.Properties.enableSoftDelete -eq $null) {
$vault.Properties | Add-Member -MemberType "NoteProperty" -Name "enableSoftDelete" -Value "True"
																								}

 Key Vault EnablePurgeProtection change ###
if ($vault.Properties.enablePurgeProtection -eq $null) {
$vault.Properties | Add-Member -MemberType "NoteProperty" -Name "enablePurgeProtection" -Value "True" 
																										}

Set-AzResource -ResourceId $vaultResourceId -Properties $vault.Properties -Force # -Confirm:$false

}


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
