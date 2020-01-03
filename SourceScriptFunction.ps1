Function SourceScript($flagFolder ,$flagLoc, $sourceFolder, $splitExcel, $archive)
{
#New-Item -Path "C:\Users\LENOVO\Documents\form\sourceFlag\sourceFlag" -ItemType File
$flagDir = $flagFolder
$flagPath = $flagLoc
$sourceFolderPath = $sourceFolder
$splitExcelPath = $splitExcel
$archivePath = $archive
$flagCreationTime = (Get-Item -Path $flagPath).CreationTime
$FolderWriteTime = (Get-Item -Path $sourceFolderPath).LastWriteTime
$count = (Get-ChildItem -Path $splitExcelPath | Measure-Object).Count

#Get-Item -Path $flagPath | select -Property CreationTime -OutVariable flagCreationTime
#Get-Item -Path $sourceFolderPath | select -Property LastWriteTime -OutVariable FolderWriteTime


if(($FolderWriteTime -le $flagCreationTime) -or ($count))
{
    Write-Host "Going to EXIT"
    #exit
}

if(($FolderWriteTime -gt $flagCreationTime) -and ($count -eq 0))
{
    
    $files = Get-ChildItem -Path $sourceFolderPath
    $flagName = Get-ChildItem -Path "$flagDir" -Name
    Write-Host "This is flag Name $flagname"
    foreach ($file in $files)
    {
        if($flagName -contains "sourceFlag")
        {
           Remove-Item -Path $flagPath 
        }

        $fileCopyTime = $file.LastAccessTime

        if($fileCopyTime -gt $flagCreationTime)
        {
            
            Copy-Item -Path $file.FullName -Destination $splitExcelPath
            #Copy-Item -Path $file.FullName -Destination $archivePath
        }
    }
    New-Item -Path $flagLoc -ItemType File
}
}

########-----SOURCE SCRIPT VARIABLES-----########
$flagFolder = "C:\Users\LENOVO\Documents\form\sourceFlag"
$flagLoc = "C:\Users\LENOVO\Documents\form\sourceFlag\sourceFlag"
$sourceFolder = "C:\Users\LENOVO\Documents\form\Source"
$splitExcel = "C:\Users\LENOVO\Documents\form\splitExcel"
$archive = "C:\ODK\Archive"

SourceScript -flagFolder $flagFolder -flagLoc $flagLoc -sourceFolder $sourceFolder -splitExcel $splitExcel -archive $archive