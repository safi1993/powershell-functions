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