<#
Pull EAccess paths from web.config files and changes via XML/Powershell
Ed Gaeta#######################
2/3/2021#######################
!!Run on a per server basis!!##
Look for any files contain "AccessAnyWhereImagePath" on e:\ drive
Load to Variable
Continue to filter for \SomestringVal
Loads all results into $FilePathArray ArrayList
#>

$colonslash = ":\"  
$slash = "\"
##Prompt user for drive letter
$ChooseDrive =  read-host -Prompt "Please enter letter drive would you like to search.."
$SearchforString = read-host -Prompt "Please enter the Keys or Values that you're looking for..example...AccessAnyWhereImagePath"


function Search {
    $dir = $ChooseDrive + $colonslash
    $filter = 'web.config'
    $hostname = Hostname
    $Files = Get-ChildItem -Path $dir -Filter $filter -Recurse | Select-String "AccessAnyWhereImagePath" 
    $SomestringVal = $files.path | Select-String "\SomestringVal"
    $FilePathArray = New-Object -TypeName "System.Collections.ArrayList"
    $FilePathArray = [System.Collections.ArrayList]@()
    
    foreach($file in $SomestringVal)
    {
      
            $obj = New-Object psobject
            $obj | Add-member Path $file.Path
            $obj | Add-member FileName $file.Filename
            $obj | Add-Member Content $file.Line
            $obj | Add-Member LineNo $file.LineNumber
            $obj | Add-Member Hostname $hostname
             
            $FilePathArray.Add($obj.Content)
    }   
}

#################################
##Makes a copy of each web.config file in the Array and names it web.config.old

foreach($path in $FilePathArray)
{
  Copy-Item $path -Destination $path'.copy' 
}

#################################
#XML - Grabs and imports content to XML objects
#loop written to grab and overwrite to the same file 

foreach($path in $FilePathArray)
{
    #Grab the web.config contents and convert into XML objects
    [xml]$xml = Get-Content $path 

    #Set new DFS Path
    $DFSpath = "\\some\dfspath\share\"

    #Grabs the exact E-Access that we're looking for "AccessAnyWhereImagePath"
    $XmlKeyValue = $xml.DocumentElement.appSettings.ChildNodes | Where-Object -Property 'key' -EQ "AccessAnyWhereImagePath"

    #Changes the value of $XmlKeyValue to the new DFSPath
    $XmlKeyValue.value = $DFSpath

    #Saves changes to file
    $xml.Save($path)
}
#############################################

##############################################
#Useful commands below
#$xml.DocumentElement.appSettings | Get-Member
#$XmlKeyValue.SelectNodes("//appSettings")
#Invoke-Item -Path C:\temp\WebConfigs\Web.config
#$xml.Save('C:\temp\WebConfigs\Web.config')




