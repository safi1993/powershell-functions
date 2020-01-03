Function CleanUpRoutine ($cleanUpPath)
{

    $dir = Get-ChildItem -Path $cleanUpPath
        foreach($destination in $dir) {
        
        $Name = $destination.Name
        $lastModified = $destination.LastAccessTime
        $filePath = $destination.FullName
        $itemLastModified = $null

        if($Name.IndexOf(' ') -gt 0){
        $fileName = $Name.Substring(0, $Name.IndexOf(' '))
        }

        if($Name.IndexOf(' ') -eq -1){
        $fileName = $Name.Substring(0, $Name.IndexOf('.'))
        }

    Write-Host " OUTER LOOP $lastModified"
    $path = Get-ChildItem -Path $cleanUpPath  -Filter *$fileName*.xlsx 
    

    $newFileName = $fileName + ".xlsx"

    if($path.Count -gt 1){
        foreach($item in $path){
        $itemLastModified = $item.LastAccessTime
        $itemPath = $item.FullName
        Write-Host " INNER LOOP $itemLastModified"
    
        if($lastModified -gt $itemLastModified){
            Remove-Item -Path $itemPath
            Write-Host "REMOVED"
                }
    
        if($itemLastModified -gt $lastModified ){
            Remove-Item -Path $filePath
            Write-Host "REMOVED"
            break
                }
            } 
        }   
    if($itemLastModified -gt $lastModified){continue}
    Rename-Item -Path $filePath -NewName $newFileName
    }
}
Measure-Command{
$cleanUpPath = "C:\ODK\Archive"

CleanUpRoutine -cleanUpPath $cleanUpPath
}