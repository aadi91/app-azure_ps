connect-azAccount
$date = Get-Date -UFormat("%m-%d-%y")
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\List_Of_All_Azure_Resources_$($date).csv"
 
if (Test-Path $oFile) {
    Remove-Item $oFile -Force
}
 
"MANAGEMENT_GROUP,SUBSCRIPTION_NAME,MGMTGRP_POLICYNAME,RG_NAME,RG_LEVEL_POL_NAME" | Out-File $oFile -Append -Encoding ascii
Get-AzManagementGroup | ForEach-Object {
    $managemetgrp = $_.DisplayName
    Write-Host "MGMNT GRP>>>>>>>>>>>>>>>>>>" $managemetgrp
    if ($managemetgrp -eq "WBA-Legacy") {
        Get-AzSubscription | ForEach-Object {
            $subscriptionId = $_.Id
            $subscriptionName = $_.Name
            $subscriptionTags = $_.Tags
            $TenentID = $_.TenantId
            $tagcount = $_.Tags.Count
            Set-AzContext -SubscriptionId $subscriptionId
            Get-AzPolicyAssignment -Scope '/providers/Microsoft.Management/managementgroups/$managemetgrp' | Where-Object { $_.Properties.DisplayName -match "GRA*" -and $_.Properties.DisplayName -match "GRD*" } | ForEach-Object {
                $mgName = $_.Name
                Get-AzResourceGroup | ForEach-Object {
                    $RGNAme = $_.ResourceGroupName
                    $RGID = $_.ResourceId
                    Get-AzPolicyAssignment -Scope $RGID | Where-Object { $_.Properties.DisplayName -match "GRA*" -and $_.Properties.DisplayName -match "GRD*" } | ForEach-Object {
                        $GRpolname = $_.Name   
                        "$managemetgrp,$subscriptionName,$mgName,$RGNAme,$GRpolname" | Out-File $oFile -Append -Encoding ascii
                    }
                }
            }
        }
    }
}
Write-Host "script executed successfully" -ForegroundColor Green