#######################################-------FUNCTION 1-------#######################################
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

#------------------VARIABLES: SOURCE SCRIPT------------------#
$flagFolder = "C:\Users\LENOVO\Documents\form\sourceFlag"
$flagLoc = "C:\Users\LENOVO\Documents\form\sourceFlag\sourceFlag"
$sourceFolder = "C:\Users\LENOVO\Documents\form\Source"
$splitExcel = "C:\Users\LENOVO\Documents\form\splitExcel"
$archive = "C:\ODK\Archive"

SourceScript -flagFolder $flagFolder -flagLoc $flagLoc -sourceFolder $sourceFolder -splitExcel $splitExcel -archive $archive







######################################################################################################
#IF STATEMENT APPLIES ON THE NEXT 4 FUNCITONS THAT FOLLOW 
$countItems = (Get-ChildItem -Path "C:\Users\LENOVO\Documents\form\splitExcel" | Measure-Object).Count
if($countItems -gt 0 ){

#######################################-------FUNCTION 2-------#######################################
Function CsvColumnModifier ($sync_source,$columnMapConfig) 
{kill -processname *excel*
$dir = Get-ChildItem -Path $sync_source 
Write-Host $dir 
         
     $dir | ForEach-Object{
            
            $excelPath = $_.FullName

            $excel = New-Object -ComObject Excel.Application
            $excel.Visible =  $false
            #$excel.Interactive = $false
           
            $workbook = $excel.Workbooks.Open($excelPath)
            #$workbook.Worksheets.count
            $workSheets = $workbook.worksheets
            $ws1 = $null

            foreach($sheet in $workSheets)
            {
                $csvConfig = Import-Csv -Path $columnMapConfig
                $ws1 = $workbook.worksheets | where {$_.name -eq $sheet.Name} #<--------Sheet
    

                #$maxColumn = $ws1.UsedRange.Rows(1).Cells.Value2
                $maxColumn = $ws1.UsedRange.Rows(1).Cells
                #$maxColumn = $ws1.UsedRange.Columns.Count

                foreach($cell in $maxColumn) 
                {
                    $cellName = $cell.Value2
        
                    foreach($from in $csvConfig)
                    {
                        $fromName = $from.FromColumnName
                        $toName = $from.ToColumnName

                        if($cellName -eq $fromName)
                        {
                            Write-Host " Change the Name From this: $cellName to this: $toName "
                            $cell.Value2 = $toName
                        }   
                    }
        
                }    
            }

        $workbook.Save()
        $workbook.Close($True)
        $excel.Quit()

        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)

        }
 
        kill -processname *excel*
}


# copy & archive -> CSV COLUMN MODIFIER -> SHEET NAME MODIFER -> EXPORT CSV -> DISTRIBUTE CSV -> PUSH FORMS
 
####### - VARIABLES: CSV COLUMN MODIFIER -######
$sync_source = "C:\Users\LENOVO\Documents\form\splitExcel\*.xlsx" #Submission form directory that receives Google submission updates/sync [Excel xlsx files]
$columnMapConfig = "C:\ODK\CsvMatch\CsvConfig.csv" #


Measure-Command {
CsvColumnModifier -sync_source $sync_source -columnMapConfig $columnMapConfig

}
Start-Sleep -Seconds 5





#######################################-------FUNCTION 3-------#######################################


Function SheetNameModifier ($syncSource, $sheetMapConfig, $syncFolder)
{$dir = Get-ChildItem -Path $sync_source
$dir | ForEach-Object{
            
            $excelPath = $_.FullName
            $wbName = $_.Name 
            


$excel = New-Object -ComObject "Excel.Application"
$excel.DisplayAlerts=$False
$excel.Visible =$false
$wb = $excel.Workbooks.Open($excelPath)
$workSheet = $null
$from = $null

$sheetConfig = Import-Csv -Path $sheetMapConfig


    #$wb.Worksheets | Select-Object -Property Name 

    foreach ($workSheet in $wb.Worksheets)
    { 
        $sheetName = $workSheet.Name
        #Write-Host "Sheet Name: $asd"
    
        #$workSheet.Name = "sheet_1"
        
        foreach ($from in $sheetConfig)
        {
            $fromSheet = $from.FromSheetName
            $toSheet = $from.ToSheetName
            #Write-Host "From Sheet: $fromSheet"
            if ($fromSheet -eq $sheetName)
            { 
               $index = [array]::IndexOf($sheetConfig.FromSheetName , $fromSheet )
                Write-Host "Sheet: $sheetName has matched $fromSheet"
                Write-Host "Sheet: $sheetName has matched $toSheet"
                Write-Host "Index is: $index"
                #$sheetConfig[$index].ToSheetName
                $workSheet.Name = $toSheet
                
                
                $workSheet.SaveAs($syncFolder+$toSheet+".csv",6)
            }
        }    
        
    }
#$wb.Save()
$wb.SaveAs($excelPath,[Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
$wb.Close($True)
$excel.Quit()
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)


 kill -processname *excel*
 }    
 
}

#---------------Variables: Sheet Name Modifier---------------#
$sync_source = "C:\Users\LENOVO\Documents\form\splitExcel\*.xlsx" #Submission file is downloaded in this directory from the googlesheets 
$sheetMapConfig = "C:\ODK\CsvMatch\SheetConfig.csv"               #Contains both original and updated names of WorkSheets/CSV files  
$syncFolder = "C:\ODK\sync\"  #Create CSVs from the submission file after modifying sheet names and export to this folder

SheetNameModifier -syncSource $sync_source -sheetMapConfig $sheetMapConfig -syncFolder $syncFolder

Start-Sleep -Seconds 5







#######################################-------FUNCTION 4-------#######################################

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
 ####### - VARIABLES: CSV DISTRIBUTOR -######
 $syncPath = "C:\ODK\sync"
 $copyConfig = "C:\ODK\csvDestinations.csv"
 $logPath = "C:\ODK\copyLog.txt"
 $newFlag = "C:\ODK\tempFolder\pushFlag"
 csvDistributor -syncPath $syncPath -copyConfig $copyConfig -logPath $logPath -csvDestinationsDir $csvDestinationsDir -newFlag $newFlag 

 Start-Sleep -Seconds 5






 #######################################-------FUNCTION 5-------#######################################

 Function pushScriptSeries ($pushFlagDir,$csvDestinationsDir, $logFile, $pushFlag )

{$newFlag = Get-ChildItem -Path $pushFlagDir

if($newFlag.Count -eq 0)
{
Write-Host " No new updates available"
#exit
}

if($newFlag.Count -ne 0)
{
$pathFile= Import-Csv -Path $csvDestinationsDir
$pushed_forms_array = @()
$allFormArray = $($pathFile.Form)
$scriptStartTime = Get-Date
$job = 0
Add-Content -Path $logFile "==================================================================================================================="


$pathFile | ForEach-Object {
    $filePath = $_.form_media_path
    $csvName = $_.CSV_name
    $pushReq = $_.push_required
    $formName = $_.Form.Trim()
    $pushStart = $_.push_start
    $copyStatus = $_.copyStatus
    $formId = $_.form_id
    $pushStatus = $_.pushStatus

    $pushStartTime = Get-Date
    $form = $formName.TrimEnd(".xml")
    
    $pushSuccess = $null
    $pushResultString = $null
    $pushResultLength = $null
    $script = $null

    #Write-Host "-------Push Required: $pushReq --------"
    
    if (($copyStatus -eq "Success") -and ($pushed_forms_array -notcontains $formName) -and ($pathFile | Where-Object {$formName -Like '*.xml'})) 
        {
            Write-Host "Push Required: $pushReq"
            $formNameMatch = $pushed_forms_array-notmatch $formName  
            
 
            # PUSH THE FORM
            
                
                    # comment out ">> C:\ODK\push.log" and write the content within brackets (|more) at the end of the script below to see the output in the terminal
                    #java -jar C:\ODK\ODK-Briefcase-v1.16.3.jar --push_aggregate --form_id $formId --storage_directory C:\ODK\ --aggregate_url http://192.168.2.138:8080/ODKAggregate/ --odk_username safi --odk_password safi >>C:\ODK\push.log 
                 
               $script= java -jar C:\ODK\ODK-Briefcase-v1.16.3.jar --push_aggregate --form_id $formId --storage_directory C:\ODK\ --aggregate_url http://192.168.2.138:8080/ODKAggregate/ --odk_username safi --odk_password safi | Out-String -OutVariable push_result
                    
                     Add-Content -Path $logFile " $(Get-Date) $push_result"

                     Write-Host "this is the output of the script |$push_result| and it shoud match |$form - Success| for a successful push"
                    Write-Host " RESULT = $script"
                    $pushResultString = $script.ToString()
                    $pushResultLength = $pushResultString.Length
                    Write-Host "Length is ------------------------------------------------------------------------- $pushResultLength"
          
                         
                         if($copyStatus -eq "Success")
                         {
                            if($push_result -match "$form - Success")
                                {
                                #Write-Host "PUSH IS SUCCESSFUL"
                                $pushSuccess = "success"
                                }

                            if($pushResultLength -eq 0)
                                {
                                #Write-Host "PUSH HAS FAILED"
                                $pushSuccess = "failed"
                                Add-Content -Path $logFile " $form $pushSuccess "
                                }
                          }

                         #if($push_result -match "$form - Success")
                         #{
                         #   #Write-Host "PUSH IS SUCCESSFUL"
                         #   $pushSuccess = "success"
                         #}  
                     
                        else
                        {
                           #Write-Host "escaped all conditions"
                            $pushSuccess = "escaped all conditions"
                           Add-Content -Path $logFile " $form $pushSuccess "
                        }
                        
                        #if($pushResultLength -eq 0)
                        #{
                        #    #Write-Host "PUSH HAS FAILED"
                        #    $pushSuccess = "failed"
                        #    Add-Content -Path C:\ODK\test.log " $form $pushSuccess "
                        #}

                        
            
            Add-Content -Path $logFile "___________________________________________________________________________________________________________________"
            Write-Host "form name match $formNameMatch "
            Write-Host "Array contains $pushed_forms_array"
            Write-Host "Pushing $formName form "

            $index = [array]::IndexOf($pathFile.form_media_path, $filePath)

            Write-Host "index is $index"

         

            #$pathFile[$index].push_start
            $pathFile[$index].push_start = $pushStartTime

            #$pathFile[$index].push_end
            $pushEndTime = $pathFile[$index].push_end = Get-Date


            $pushed_forms_array += $formName

            $formMatchIndex = (0..($allFormArray.Count - 1 ))| where {$allFormArray[$_] -eq $formName}
            #$formMatchIndex
            
          foreach
                    ($pos in $formMatchIndex)  
                {
                #$pathFile[$pos].push_start
                $pathFile[$pos].push_start = $pushStartTime

                #$pathFile[$pos].push_end
                $pathFile[$pos].push_end= $pushEndTime

                #$pathFile[$pos].push_required
                $pathFile[$pos].push_required = "NO"

                #$pathFile[$pos].pushStatus
                $pathFile[$pos].pushStatus = $pushSuccess
                
               # Write-Host "------------------------------------------------- position is $pos"
                }
            

            
            #$pathFile |Sort push_start| Select CSV_name, Form, form_id, form_path, form_media_path, push_start, push_end, copy_start, copy_end, push_required, copyStatus, pushStatus| 
            #Export-Csv "C:\ODK\temp.csv" -NoTypeInformation
                
        } 
  
  $pathFile |Sort push_start| Select CSV_name, Form, form_id, form_path, form_media_path, push_start, push_end, copy_start, copy_end, push_required, copyStatus, pushStatus| 
            Export-Csv $csvDestinationsDir -NoTypeInformation
}
Remove-Item -Path $pushFlag

$pushSuccessIndex = [array]::IndexOf($pathFile.form_media_path, "push_script")
#$pathFile[$pushSuccessIndex].push_start
$pathFile[$pushSuccessIndex].push_start = $scriptStartTime

#$pathFile[$pushSuccessIndex].push_end
$pathFile[$pushSuccessIndex].push_end = Get-Date

#$pathFile[$pushSuccessIndex].push_required
$pathFile[$pushSuccessIndex].push_required = "NO"

$pathFile |Sort push_start| Select CSV_name, Form, form_id, form_path, form_media_path, push_start, push_end, copy_start, copy_end, push_required, copyStatus, pushStatus| 
            Export-Csv $csvDestinationsDir -NoTypeInformation

            Start-Sleep -Seconds 1
Add-Content -Path $logFile "==================================================================================================================="

}

}
####### - VARIABLES: PUSH SCRIPT -######
$pushFlagDir = "C:\ODK\tempFolder"
$csvDestinationsDir = "C:\ODK\csvDestinations.csv"
$logFile = "C:\ODK\test.log"
#$pushScript = java -jar C:\ODK\ODK-Briefcase-v1.16.3.jar --push_aggregate --form_id $formId --storage_directory C:\ODK\ --aggregate_url http://192.168.2.138:8080/ODKAggregate/ --odk_username safi --odk_password safi | Out-String -OutVariable push_result
$pushFlag = "C:\ODK\tempFolder\pushFlag"

pushScriptSeries -pushFlagDir $pushFlagDir -csvDestinationsDir $csvDestinationsDir -logFile $logFile -pushFlag $pushFlag
}