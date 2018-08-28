#request the logs creation date - the logs created in that day will be backed up
$BackupDay = Read-Host "Please type the day of the month when the logs were created to backup them(1-31)"
$BackupMonth = Read-Host "Please type the month of the year when the logs were created to  backup them(1-12)"


$LogFiles = Get-ChildItem -Path "D:\application" -Filter "*.txt" -Recurse
$ConfFiles = Get-ChildItem -Path "D:\application" -Filter "*.config" -Recurse

$regex = "\d{4}-\d{2}-\d{2}" #regex for the date format

# we are testing if the backup folders: logs and configs exist. If yes, the script deletes/recreates them. If not, it simply creates them
$TestLogPath = Test-Path "d:\backup\logs"
$TestConfPath = Test-Path "d:\backup\configs"

if($TestLogPath)
    {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
    Write-Host "$TimeStamp : Cleaning logs folder"
    Remove-Item -Path "d:\backup\logs" -Force -Confirm:$False
    New-Item -ItemType Directory "d:\backup\logs"
    }
    else { 
        $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
        Write-Host "$TimeStamp : Creating logs folder"
        New-Item -ItemType Directory "d:\backup\logs"  }


if($TestConfPath)
    {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
    Write-Host "$TimeStamp : Cleaning configs folder"
    Remove-Item -Path "d:\backup\configs" -Force -Confirm:$False
    New-Item -ItemType Directory "d:\backup\configs" 
    }
    else 
    { 
    $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
    Write-Host "$TimeStamp : Creating configs folder"
    New-Item -ItemType Directory "d:\backup\configs"  
    }


#This part of the script is backing up the log files according the regex(if the files contain the date format
# defined by the regex in the name) and the creation date defined at the begining of the script
foreach ($file in $LogFiles)

    {
    $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
    Write-Host "$TimeStamp :  Backing up $file"
    

    $FilePath = $file.FullName | Select-String -Pattern "$regex"
    if($([string]::IsNullOrEmpty($FilePath)))
        {Write-Host "$TimeStamp The file $file will not be backed up"}
         
        Else {  
            $CreationDay = ($file.CreationTime).day
            $creationMonth = ($file.CreationTime).Month

            If(($CreationDay -eq  $BackupDay) -and ($creationMonth -eq $BackupMonth))
            {

            Write-Host "$TimeStamp : Backing $file"
            Copy-Item -Path "$FilePath" -Destination "d:\backup\logs"
            }
                }
    }

    foreach($config in $ConfFiles)
    {
        $TimeStamp = Get-Date -Format "yyyy-MM-dd hh:mm:ss.ff"
        Write-Host "$TimeStamp :  Backing up $config"
        $ConfPath = $config.FullName
        Copy-Item -Path "$ConfPath" -Destination "d:\backup\configs"


    }

    Write-Host "The backing up process has ended"

 #file locking :  if any file is locked by another process we could close it. If runned with admin privileges it should be able to deleted everything else.
       