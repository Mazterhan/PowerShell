function UpdateSite ($SiteName)
{
Login-AzureRmAccount  
Select-AzureRmSubscription -SubscriptionId '6c28b945-6d98-403d-8936-5e658f228a0f'  
$password = '3v}B~PMWR)5bB&gt'
if ($SiteName = 'RVD')
   {
   $SiteName          = 'RvdNow'
   $Site_TestURL      = 'https://rvdnow-preprodstage.azurewebsites.net'
   $Site_URL          = 'https://www.rvdnow.com'
   $sourceFolder      = '\\PRBCWEBTESTX\c$\Projects\MB.rVd\*'
   $TempZIPFolder     = 'F:\RVD_ftp_site\'
   $targetFTPFolder   = 'ftp://waws-prod-dm1-015.ftp.azurewebsites.windows.net/site/wwwroot/'
   $user_TestURL      = 'rvdnow__PreProdStage\optoutadmin1'
   $sourceslot        = 'rvdnow-PreProdStage'
   $destinationslot   = 'rvdnow'
   $RG                = 'RvdNow' 
   }

#Создание архива данных, перенос
Compress-Archive -Path $sourceFolder -CompressionLevel Optimal -Update -DestinationPath "$TempZIPFolder $SiteName .zip"
Expand-Archive -LiteralPath "$TempZIPFolder $SiteName.zip" -DestinationPath $targetFTPFolder -Force

#проверка работоспособности тестового сайта
Start-Process chrome.exe -ArgumentList @( '-incognito', $Site_TestURL )
#переключение слотов
Switch-AzureRmWebAppSlot -SourceSlotName $sourceslot -DestinationSlotName $destinationslot -ResourceGroupName $RG -Name $SiteName
#проверка работоспособности продакшн сайта
Start-Process chrome.exe -ArgumentList @( '-incognito', $Site_URL )
}



