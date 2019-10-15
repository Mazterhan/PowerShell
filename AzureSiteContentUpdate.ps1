function UpdateSite ($SiteName)
{
Login-AzureRmAccount  
Select-AzureRmSubscription -SubscriptionId '6c28b945-6d98-403d-8936-5e658f228a0f'  
$FTPPass = '3v}B~PMWR)5bB&gt' # FTP Server Variables
if ($SiteName = 'RVD')
   {
   $SiteName          = 'RvdNow'
   $Site_TestURL      = 'https://rvdnow-preprodstage.azurewebsites.net'
   $Site_URL          = 'https://www.rvdnow.com'
   $UploadFolder      = '\\PRBCWEBTESTX\c$\Projects\MB.rVd\'  #Directory where to find pictures to upload
   $FTPHost           = 'ftp://waws-prod-dm1-015.ftp.azurewebsites.windows.net/site/wwwroot/' # FTP Server Variables
   $FTPUser           = 'rvdnow__PreProdStage\optoutadmin1'  # FTP Server Variables
   $sourceslot        = 'rvdnow-PreProdStage'
   $destinationslot   = 'rvdnow'
   $RG                = 'RvdNow' 
   }


clear
 
# FTP Server Variables
 
#Directory where to find pictures to upload
  
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($FTPUser,$FTPPass)  
 
$SrcEntries = Get-ChildItem $UploadFolder -Recurse
$Srcfolders = $SrcEntries | Where-Object{$_.PSIsContainer}
$SrcFiles = $SrcEntries | Where-Object{!$_.PSIsContainer}
 
# Create FTP Directory/SubDirectory If Needed - Start
foreach($folder in $Srcfolders)
{    
    $SrcFolderPath = $UploadFolder  -replace "\\","\\" -replace "\:","\:"   
    $DesFolder = $folder.Fullname -replace $SrcFolderPath,$FTPHost
    $DesFolder = $DesFolder -replace "\\", "/"
    # Write-Output $DesFolder
 
    try
        {
            $makeDirectory = [System.Net.WebRequest]::Create($DesFolder);
            $makeDirectory.Credentials = New-Object System.Net.NetworkCredential($FTPUser,$FTPPass);
            $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
            $makeDirectory.GetResponse();
            #folder created successfully
        }
    catch [Net.WebException]
        {
            try {
                #if there was an error returned, check if folder already existed on server
                $checkDirectory = [System.Net.WebRequest]::Create($DesFolder);
                $checkDirectory.Credentials = New-Object System.Net.NetworkCredential($FTPUser,$FTPPass);
                $checkDirectory.Method = [System.Net.WebRequestMethods+FTP]::PrintWorkingDirectory;
                $response = $checkDirectory.GetResponse();
                #folder already exists!
            }
            catch [Net.WebException] {
                #if the folder didn't exist
            }
        }
}
# Create FTP Directory/SubDirectory If Needed - Stop
 
# Upload Files - Start
foreach($entry in $SrcFiles)
{
    $SrcFullname = $entry.fullname
    $SrcName = $entry.Name
    $SrcFilePath = $UploadFolder -replace "\\","\\" -replace "\:","\:"
    $DesFile = $SrcFullname -replace $SrcFilePath,$FTPHost
    $DesFile = $DesFile -replace "\\", "/"
    # Write-Output $DesFile
 
    $uri = New-Object System.Uri($DesFile) 
    $webclient.UploadFile($uri, $SrcFullname)
}
# Upload Files - Stop



#проверка работоспособности тестового сайта
Start-Process chrome.exe -ArgumentList @( '-incognito', $Site_TestURL )
#переключение слотов
Switch-AzureRmWebAppSlot -SourceSlotName $sourceslot -DestinationSlotName $destinationslot -ResourceGroupName $RG -Name $SiteName
#проверка работоспособности продакшн сайта
Start-Process chrome.exe -ArgumentList @( '-incognito', $Site_URL )
}



