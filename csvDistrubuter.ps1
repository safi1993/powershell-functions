Function csvDistributor($syncPath, $copyConfig, $logPath, $newFlag)
{$newFiles = (Get-ChildItem -Path $syncPath| Measure-Object).Count


if($newFiles -eq 0)  
{
    Write-Host "No New Updates Available"
    exit
}


if ($newFiles -ne 0) 
#$diagnostic

{ 

$folder=Get-ChildItem -Path $syncPath -Name #update this path for migration
$pathFile= Import-Csv -Path $copyConfig #update this path for migration
$sourceFolderPath = 'C:\ODK\sync\' #update this path for migration
$startTime = Get-Date 
$count = 0
$copyStatus = $null

$formNameArray = @()

foreach($file in $folder) {


$copyFrom = -join($sourceFolderPath,$file)

#Write-Host "Copy From:" $copyFrom

 $pathFile | ForEach-Object { 
    $fileName= $_.CSV_name
    $filePath= $_.form_media_path
    $copyStart= $_.copy_start
    $copyEnd= $_.copy_end
    $pushReq = $_.push_required
    $formName = $_.Form
    #$pushStatus = $_.pushStatus
    #$copyStatus = $_.copyStatus
    

    if (($fileName -eq $file) -and ($pathFile | Where-Object {$fileName -Like '*.csv'}) -and ($folder -match $file ) -and ($filePath.Length -ne 0)) {
    if($file -match $fileName ) {Write-Host "NAME IN CSVDESTINATION FILE IS $fileName AND CSV FILE NAME IS $file -----$formName"}
    
   # }}} Start-Sleep -Seconds 5
    #& "C:\ODK\pushScriptSeries.ps1"
    #}
    
    

   # Write-Host " Paste the file $file In $filePath" 
    try{ 
    $copiedTo = Get-ChildItem -Path $filePath
    $pasteTime = $copiedTo.LastAccessTime
    $pathFile.CSV_name
    Copy-Item -Path $copyFrom -Destination $filePath -ErrorAction Stop -ErrorVariable copyErr 

    $copyStatus = "Success"
     }

    catch{ 
    $copyStatus = "Failed"
    
    $errTime = Get-Date
    "$errTime - $copyErr"  | Out-file  $logPath -Append
     }
    $count++


    $index = [array]::IndexOf($pathFile.form_media_path , $filePath )

   
    
            $copiedTo = Get-ChildItem -Path $filePath
        $pasteTime = $copiedTo.LastAccessTime
        $pathFile.CSV_name   
        
        
        #Write-Host "index index index $index "
    
    
        #$timeStamp = Get-Date -Format "yyyyMMdd HH:MM:ss"
        $pathFile[$index].copy_start
        $copyStart
        $pathFile[$index].copy_start = Get-Date

    
        $pathFile[$index].push_required 
        $pushReq 
        $pathFile[$index].push_required = "YES"


       # $timeStamp = Get-Date -Format "yyyyMMdd HH:MM:ss"
        $pathFile[$index].copy_end
        $copyEnd
        $pathFile[$index].copy_end = Get-Date 

   
      
     $pathFile[$index].copyStatus
    
    $pathFile[$index].copyStatus = $copyStatus 
    #$newCopyTime = $pathFile[$index].copy_start
    #Write-Host " this is it: $newCopyTime"
   
  
    
    $pathFile.push_required
    $pathFile | Sort copy_start | Select CSV_name, Form, form_id, form_path, form_media_path, push_start, push_end, copy_start, copy_end, push_required, copyStatus, pushStatus |
    Export-Csv $copyConfig -NoTypeInformation
    
    

    

    }
    
    
}  

  
 Remove-Item -Path $copyFrom   
 
 } 
 #write-host "count=" $count
 #write-host "Index=" $index "and file is" $file
 #if(($count -ge 0) ) 
 #{
    New-Item -Path $newFlag -ItemType File
# 
# }

 $endDateIndex = [array]::IndexOf($pathFile.form_media_path , "copy_script" )
 
 $pathFile[$endDateIndex].copy_end
 $endTime = $pathFile[$endDateIndex].copy_end = Get-Date 

 $pathFile[$endDateIndex].copy_start = $startTime  
 
 $pathFile[$endDateIndex].copy_start
 #Write-Host "End date is=" $endDate
 if($copyStatus = "Success")
           {
            $pathFile | Sort copy_start | Select CSV_name, Form, form_id, form_path, form_media_path, push_start, push_end, copy_start, copy_end, push_required, copyStatus, pushStatus |           
            Export-Csv $copyConfig -NoTypeInformation
           }    
    
    #Start-Sleep -Seconds 5
    #& "C:\ODK\pushScriptSeries.ps1"
 
 }

 }
 $syncPath = "C:\ODK\sync"
 $copyConfig = "C:\ODK\csvDestinations.csv"
 $logPath = "C:\ODK\copyLog.txt"
 $newFlag = "C:\ODK\tempFolder\pushFlag"
 csvDistributor -syncPath $syncPath -copyConfig $copyConfig -logPath $logPath -csvDestinationsDir $csvDestinationsDir -newFlag $newFlag 