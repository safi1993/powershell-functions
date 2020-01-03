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
#$wb.SaveAs($excelPath)
$wb.SaveAs($excelPath,[Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
$wb.Close($True)
$excel.Quit()
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)

Write-Host "C:\Users\LENOVO\Documents\form\splitExcel\split\$wbName"


 kill -processname *excel*
 }    
 
}

#---------------Variables: Sheet Name Modifier---------------#
$sync_source = "C:\Users\LENOVO\Documents\form\splitExcel\*.xlsx" #Submission file is downloaded in this directory from the googlesheets 
$sheetMapConfig = "C:\ODK\CsvMatch\SheetConfig.csv"               #Contains both original and updated names of WorkSheets/CSV files  
$syncFolder = "C:\ODK\sync\"  #Create CSVs from the submission file after modifying sheet names and export to this folder

SheetNameModifier -syncSource $sync_source -sheetMapConfig $sheetMapConfig -syncFolder $syncFolder


