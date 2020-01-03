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

Add-Content -Path $logFile "==================================================================================================================="

}

}

$pushFlagDir = "C:\ODK\tempFolder"
$csvDestinationsDir = "C:\ODK\csvDestinations.csv"
$logFile = "C:\ODK\test.log"
#$pushScript = java -jar C:\ODK\ODK-Briefcase-v1.16.3.jar --push_aggregate --form_id $formId --storage_directory C:\ODK\ --aggregate_url http://192.168.2.138:8080/ODKAggregate/ --odk_username safi --odk_password safi | Out-String -OutVariable push_result
$pushFlag = "C:\ODK\tempFolder\pushFlag"

pushScriptSeries -pushFlagDir $pushFlagDir -csvDestinationsDir $csvDestinationsDir -logFile $logFile -pushFlag $pushFlag