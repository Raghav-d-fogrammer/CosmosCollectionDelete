$tenantId = "<TENANT ID>" # AD Tenant
$clientId = "<CLIENT ID>" # SPN APP ID or Client ID
$secret = ConvertTo-SecureString "<SECRET>" -AsPlainText -Force # Client Secret or key and not the cosmos account key

$outputFilePath = "cosmos_container_delete.txt" # output

#Function to delete Cosmos Collection
function Delete-CosmosCollection {
    param (
        $rgName,
        $accName,
        $databaseName,
        $collectionName,
        $reasonForDeletion,
        $outputFileName
    )

    try {
        # -Confirm will ask for confirmation
        Remove-AzCosmosDBSqlContainer -ResourceGroupName $rgName -AccountName $accName -DatabaseName $databaseName -Name $collectionName -Confirm -PassThru
        $out = (Get-Date).ToString() + "," + $accName + "," + $databaseName + "," + $collectionName + "," + $reasonForDeletion | Out-File -FilePath $outputFileName -Append
    }
    catch {
        Write-Host $_.Exception.Message -BackgroundColor Red
    }
}

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $secret
Connect-AzAccount -ServicePrincipal -TenantId $tenantId -Credential $credential

# Use this below script to delete all the collections in a given account
#$resourceGroupName = "rd-rg-sc"
#$accountName = "rdcosmos"
#$reason = "dev account delete for cost savings."

#$account = Get-AzCosmosDBAccount -ResourceGroupName $resourceGroupName
#$dbs = Get-AzCosmosDBSqlDatabase -ResourceGroupName $resourceGroupName -AccountName $accountName
#foreach($db in $dbs) {
#    "Database: "  + $db.Name
#    $collections = Get-AzCosmosDBSqlContainer -ResourceGroupName $resourceGroupName -AccountName $accountName -DatabaseName $db.Name
#    foreach($collection in $collections) {
#        read-host "Press ENTER to delete the collection: " $collection.Name
#        #Remove-AzCosmosDBSqlContainer -ResourceGroupName $resourceGroupName -AccountName $accountName -DatabaseName $db.Name -Name $collection.Name -Confirm -PassThru
#        #$out = (Get-Date).ToString()+","+$accountName+","+$db.name+","+$collection.Name+","+$reason | Out-File -FilePath $outputFilePath -Append
#        Delete-CosmosCollection $resourceGroupName $accountName $db.Name $collection.Name $reason $outputFilePath
#    }
#}

#use this script to delete all the collection in a given csv file (AccountName, DatabaseName, CollectionName)

$inputFilePath = "./cosmos_accounts.csv"
$csv = Import-csv -path $inputFilePath
$csv
foreach($l in $csv){
    read-host "Press ENTER to delete the collection: " $l.collection
     Delete-CosmosCollection $l.rg $l.account $l.db $l.collection $l.reason $outputFilePath
}
