connect-azAccount
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

    $aksName = $_.Name
    $aksFDQN = $_.Fqdn
    $aksID = $_.Id
   
    Get-AzRoleAssignment -Scope "$aksID" | Where{($_.RoleDefinitionName -eq 'Contributor') -or ($_.RoleDefinitionName -like 'WBA Contributor' )} | ForEach-Object{
    #Get-AzRoleAssignment -Scope "$aksID" | Where{($_.RoleDefinitionName -eq 'Azure Kubernetes Service Cluster Admin Role') -or ($_.RoleDefinitionName -like 'Azure Kubernetes Service RBAC Admin' )} -WarningAction SilentlyContinue | ForEach-Object{
    $UserName = $_.DisplayName
    $ROlesDefination = $_.RoleDefinitionName
    $ObjectID = $_.ObjectId
    $SignInName = $_.SignInName
   
    Remove-AzRoleAssignment -ObjectId "$ObjectID" -RoleDefinitionName "$ROlesDefination" -Scope "$aksID"

   


         }
   
        }
       }
      }
 
Write-Host "script executed successfully" -ForegroundColor Green