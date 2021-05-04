param (
    [string]$dir=".",
    [switch]$help=$false,
    [switch]$debug=$false,
    [string]$filename="*.1CD",
    [string]$exclude="1Cv8tmp.1CD",
    [switch]$alldrivers=$true,
    [string]$prevfile=".\infobases.prev.csv",
    [string]$lastfile=".\infobases.csv",
    [string]$newfile=".\appended.csv",
    [string]$delfile=".\deleted.csv"
)

# массив имен томов
function GetAllDrivers()
{
    $drivers = (Get-Volume |  Where-Object { $_.DriveLetter -ne 0} ).DriveLetter
    for($i=0; $i -le $drivers.count-1; $i++){
        $drivers[$i] += ":\"
    }
    return $drivers

}


function SearchInfobases($path, [string]$ext, [string]$exc)
{
    
    return Get-ChildItem -Path $path -Include "$ext" -Exclude $exc -Recurse -ErrorAction SilentlyContinue  | Select FullName

}

#############################################################
if($debug){
    $DebugPreference = 'Continue'
}

if($help){
    $h = "
    Finding 1c infobases on local server
    1cfinder:
     -dir path - search infobases in path
     -filename filename - filename, wildcard, default $filename
     -exclude exclude-filename - exclude filenames, default $exclude
     -alldrivers - find filename over all drivers,  default
     -prevfile - filename for result of prev searching, default $prevfile
     -lastfile - filename for result of last searching, default $lastfile
     -newfile - file for list of append files, default $newfile
     -delfile - file for list of deleted files, default $delfile
    ";
    Write-Output($h);
    Exit;
}


if( Test-Path $prevfile){
        Remove-Item -Path $prevfile -Force
}

if( Test-Path $lastfile) {
        Rename-Item -Path $lastfile -NewName $prevfile -Force
}

if($alldrivers){
    
    $path =  GetAllDrivers
   
}else{
    $path = $dir
}
    
SearchInfobases $path $filename $exclude | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

if(Test-Path $prevfile)
{
    $prev = Import-Csv -Encoding UTF8 $prevfile
}else{
    $prev = $null
}

if( Test-Path $lastfile){
    $last = Import-Csv -Encoding UTF8 $lastfile
}else{ 
    $last = $null
}

if( $prev -ne $null -and $lastfile -ne $null){
    $new = Compare-Object  $prev.FullName $last.FullName | where { $_.SideIndicator -ne "<=" }
    $del = Compare-Object  $prev.FullName $last.FullName | where { $_.SideIndicator -ne "=>" }
    $new | ConvertTo-Csv | Out-File -Encoding UTF8 $newfile
    $del | ConvertTo-Csv | Out-File -Encoding UTF8 $delfile

    $r = @{"append"= ($new | measure).count; "deleted"=($del | measure).count}
    $r | ConvertTo-Json
}else{
    $r = @{"append"= 0; "deleted"=0}
    $r | ConvertTo-Json
}
