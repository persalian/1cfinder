param (
    [string]$plocate="C:\Users\andrey_2\desktop",
    [switch]$help=$false,
    [switch]$debug=$true,
    [string]$pfilename="*.txt",
    [switch]$palldrivers=$false
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
    Write-Debug "SearchInfobases:path: $path"
    Write-Debug "SearchInfobases:ext: $ext"

    Write-Debug "Get-ChildItem -Path $path -Include $ext -Recurse -ErrorAction SilentlyContinue  | Select FullName"
    $dbs = Get-ChildItem -Path $path -Include "$ext" -Recurse -ErrorAction SilentlyContinue  | Select FullName
    return($dbs)

}


if($debug){
    $DebugPreference = 'Continue'
}

if($help){
    $h = "
    Finding 1c infobases on server
    1cfinder [ -path path-to-folder ]
    -path path - search infobases in path, default search in all drivers
    -filename - filename, wildcard
    ";
    Write-Output($h);
    Exit;
}


if($palldrivers){
    $drivers =  GetAllDrivers
    
    $d = SearchInfobases $drivers $pfilename

    Remove-Item -Path .\infobases.prev.csv -Force
    Rename-Item -Path .\infobases.csv -NewName .\infobases.prev.csv -Force

    $d | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv




}else{
    
    $d = SearchInfobases $plocate $pfilename

    Remove-Item -Path .\infobases.prev.csv -Force
    Rename-Item -Path .\infobases.csv -NewName .\infobases.prev.csv -Force

    $d | ConvertTo-Csv  | Out-File -Encoding "UTF8" infobases.csv

}


$prev = Import-Csv -Encoding UTF8 .\infobases.prev.csv
$last = Import-Csv -Encoding UTF8 .\infobases.csv
Compare-Object  $prev.FullName $last.FullName
