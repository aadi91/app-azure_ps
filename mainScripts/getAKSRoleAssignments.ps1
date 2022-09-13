
###########AKS NAME with ROLES LIST#################
connect-azAccount
$date = Get-Date -UFormat("%m-%d-%y")
$currentDir = $(Get-Location).Path
$oFile = "$($currentDir)\Azure_AKS_Resources_List_$($date).csv"
 
if(Test-Path $oFile){
    Remove-Item $oFile -Force
}
 
"AKS_NAME,SUBSCRIPTION_NAME,SUBSCRIPTION_ID,RESOURCE_GROUP_NAME,USER_NAME,AKS_ROLES,ENVIRONMENT,DEPARTMENT,COST_CENTER" | Out-File $oFile -Append -Encoding ascii
 
    Get-AzSubscription | ForEach-Object{
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
    $subscriptionTags = $_.Tags
    $TenentID = $_.TenantId
    $tagcount = $_.Tags.Count
    Set-AzContext -SubscriptionId $subscriptionId

    Get-AzResourceGroup | ForEach-Object{
    $resourceGroupName = $_.ResourceGroupName

    Get-AzAksCluster -ResourceGroupName $resourceGroupName -WarningAction SilentlyContinue | ForEach-Object{
    $aksNameForTags = $_.Name
    $tagInfo = (Get-AzAksCluster -ResourceGroupName $resourceGroupName -Name $aksNameForTags).Tags

    $aksName = $_.Name
    $aksFDQN = $_.Fqdn
    $aksID = $_.Id
    $dept = $tagInfo.Department
    $env = $tagInfo.EnvType
    $costCenter = $tagInfo.CostCenter
   
    Get-AzRoleAssignment -Scope "$aksID" | Where{($_.RoleDefinitionName -eq 'Contributor') -or ($_.RoleDefinitionName -like 'WBA Contributor' )} | ForEach-Object{
    $UserName = $_.DisplayName
    $ROlesDefination = $_.RoleDefinitionName      
    "$aksName,$subscriptionName,$subscriptionId,$resourceGroupName,$UserName,$ROlesDefination,$env,$dept,$costCenter" | Out-File $oFile -Append -Encoding ascii
        }
       }
      }
 }
Write-Host "script executed successfully" -ForegroundColor Green