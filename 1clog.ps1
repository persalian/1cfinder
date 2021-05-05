param (
    [string]$dir=".",
    [switch]$help=$false,
    [switch]$debug=$false,
    [string]$logdir="1Cv8Log",
    [string]$greater=0
)


# параметры:
# path - путь поиск
# ext - файлы для поиска
function SearchInfobases($path, [string]$ext)
{
    write-debug "SearchInfobases:path: $path"
    write-debug "SearchInfobases:dir: $ext"
    $r = Get-ChildItem -Path $path -Include $ext -Recurse -ErrorAction SilentlyContinue   | Select-object FullName
    return $r

}

#############################################################
if($debug){
    $DebugPreference = 'Continue'
}

if($help){
    $h = "
    Finding 1c infobases on local server
    1cfinder:
     -dir path - search infobases in path, default - current directory
     -dirname dirname - Name of log directory , default $dirname
     -greater num - show log folders only greater than num MB, default $greater
    ";
    Write-Output($h);
    Exit;
}


if ( test-path $dir ) {

    $logs = SearchInfobases $dir $logdir
    write-debug "start calculate of size"

    $c = $logs.count - 1
    write-debug "count found log folders: $c"
    for ($i=1; $i -le $c; $i++) {
        write-debug $logs[$i]
        
        $log_size = [math]::round(((Get-ChildItem $logs[$i].FullName -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB), 2)
        if( $log_size -ge $greater ){
            $s = "{1} MB = {0} " -f ($logs[$i].FullName, $log_size)
            write-output $s
        }
}
}else{
    write-output "Wrong folder for searching: $dir"
}