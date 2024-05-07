param([string]$buckets_string)

Import-Module "$($PSScriptRoot)\LogModule"

WriteSetupScoopLog "parameter: ${buckets_string}"
[string[]] $buckets = @()
if ($buckets_string) {
    $buckets = $buckets_string.Split(" ")
}
WriteSetupScoopLog "buckets: ${buckets}"
if ($buckets.count -ge 1) {
    $known_buckets=scoop bucket known
    foreach($bucket in $buckets) {
        if($null -eq ($known_buckets | Where-Object {$_ -eq $bucket})) {
            Write-Error "Bucket `"$bucket`" is unknown." -ErrorAction Stop
        }
        WriteSetupScoopLog "Adding `"${bucket}`" bucket"
        scoop bucket add $bucket
    }
}
