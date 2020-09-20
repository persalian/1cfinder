param (
    [string]$dir="C:\Users\andrey_2\desktop",
    [switch]$help=$false,
    [switch]$debug=$false,
    [string]$filename="*.txt",
    [switch]$alldrivers=$false,
    [string]$prevfile=".\infobases.prev.csv",
    [string]$lastfile=".\infobases.csv"
)

function GetAllDrivers()
{
    $drivers = (Get-Volume |  Where-Object { $_.DriveLetter -ne $null} ).DriveLetter
    for($i=0; $i -le $drivers.count-1; $i++){
        $drivers[$i] += ":\"
    }
    return $drivers

}

function SearchInfobases($path, [string]$ext)
{
    
    return Get-ChildItem -Path $path -Include "$ext" -Recurse -ErrorAction SilentlyContinue  | Select FullName

}


if($debug){
    $DebugPreference = 'Continue'
}

if($help){
    $h = "
    Finding 1c infobases on server
    1cfinder [ -path path-to-folder | -alldrivers ] -filename filename
    -dir path - search infobases in path, default search in all drivers
    -filename - filename, wildcard, default *.1CD
    -alldrivers - find filename over all drivers
    ";
    Write-Output($h);
    Exit;
}


if($alldrivers){
    
    if( Test-Path $prevfile){
        Remove-Item -Path $prevfile -Force
    }
    if( Test-Path $lastfile) {
        Rename-Item -Path $lastfile -NewName $prevfile -Force
    }

    $drivers =  GetAllDrivers
    SearchInfobases $drivers $filename | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

    

}else{

    if( Test-Path $prevfile){
        Remove-Item -Path $prevfile -Force
    }
    if( Test-Path $lastfile) {
        Rename-Item -Path $lastfile -NewName $prevfile -Force
    }

    SearchInfobases $dir $filename | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

}


$prev = Import-Csv -Encoding UTF8 $prevfile
$last = Import-Csv -Encoding UTF8 $lastfile
if( $prev -ne $null -and $lastfile -ne $null){
    $cmp = Compare-Object  $prev.FullName $last.FullName
    $cmp | ConvertTo-Json
}


