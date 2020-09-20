param (
    [string]$dir="C:\Users\andrey_2\desktop",
    [switch]$help=$false,
    [switch]$debug=$false,
    [string]$filename="*.txt",
    [switch]$alldrivers=$false
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
    
    Remove-Item -Path .\infobases.prev.csv -Force
    Rename-Item -Path .\infobases.csv -NewName .\infobases.prev.csv -Force

    $drivers =  GetAllDrivers
    SearchInfobases $drivers $pfilename | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

    

}else{

    Remove-Item -Path .\infobases.prev.csv -Force
    Rename-Item -Path .\infobases.csv -NewName .\infobases.prev.csv -Force

    SearchInfobases $plocate $pfilename | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

}


$prev = Import-Csv -Encoding UTF8 .\infobases.prev.csv
$last = Import-Csv -Encoding UTF8 .\infobases.csv
$cmp = Compare-Object  $prev.FullName $last.FullName
$cmp | ConvertTo-Json
