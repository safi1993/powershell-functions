    Function incrementFormVersion ($formPath) {
    $next_version = 0
    $firstLine = Get-Content -Path $formPath -TotalCount 1 #-Value 'version=".*?"><uid/>'
    $firstLine.ToString() -match '" version=".*?"><uid/>'
    $firstLine = $null
    [regex]::Match($matches[0], '(?<="*=")(.+)(?=")') | select -expa value -OutVariable current_version 
    $next_versionNo = [int] $current_version[0]+1
    $formContent = Get-Content -Path $formPath
    #$updateVersion = "`" version=`"$next_versionNo`"><uid/>"
    $formContent -replace '" version=".*?"><uid/>' , "`" version=`"$next_versionNo`"><uid/>" | Set-Content -Path $formPath
    }

    $formName = "contacts.xml"
    $form =     "contacts"
     $formPath ="C:\ODK\ODK Briefcase Storage\forms\" + $form + "\" + $formName

     incrementFormVersion -formPath $formPath