
# Connect to Azure Account
Connect-AzAccount
 
# Create Report Array
$report = @()

$date = Get-Date -UFormat("%m-%d-%y")
$currentDir = "U:\Project\Reports"
#$currentDir = $(Get-Location).Path
$reportName = "$($currentDir)\Azure_Subscriptions_RG_$($date).csv"
 
if (Test-Path $reportName) {
    Remove-Item $reportName -Force
}
 
Get-AzSubscription | ForEach-Object {
    $subscriptionId = $_.Id
    $subscriptionName = $_.Name
    write-host -ForegroundColor Yellow $subscriptionName
    Set-AzContext -SubscriptionId $subscriptionId

    $resourceGroups = Get-AzResourceGroup 
    foreach ($resourceGroup in $resourceGroups) {
        $ReportDetails = "" | Select SUBSCRIPTION_NAME, RESOURCE_GROUP_NAME 
        $resourceGroupName = $resourceGroup.ResourceGroupName
        $ReportDetails.SUBSCRIPTION_NAME = $subscriptionName
        $ReportDetails.RESOURCE_GROUP_NAME = $resourceGroup.ResourceGroupName
        write-host -ForegroundColor Green $resourceGroupName
        $report += $ReportDetails
    }
}

$report | ft SUBSCRIPTION_NAME, RESOURCE_GROUP_NAME
#Path to save the generated spreadsheet
$report | Export-CSV $reportName