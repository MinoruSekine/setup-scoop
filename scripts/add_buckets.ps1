param([string]$buckets_string)

Import-Module "$($PSScriptRoot)\InvokeExternalModule"
Import-Module "$($PSScriptRoot)\LogModule"

Write-SetupScoopLog "parameter: ${buckets_string}"
[string[]] $buckets = @()
if ($buckets_string) {
    $buckets = $buckets_string.Split(" ")
}
Write-SetupScoopLog "buckets: ${buckets}"
if ($buckets.count -ge 1) {
    $known_buckets=& scoop bucket known
    if (-not $?) {
        Write-Error "Failed to get known buckets by ""scoop bucket known""." `
          -ErrorAction Stop
    }
    foreach($bucket in $buckets) {
        if($null -eq ($known_buckets | Where-Object {$_ -eq $bucket})) {
            Write-Error `
              "Bucket `"$bucket`" is not in known buckets ($known_buckets)." `
              -ErrorAction Stop
        }
        Write-SetupScoopLog "Adding `"${bucket}`" bucket"
        Invoke-External -Command "scoop" -Parameters "bucket", "add", "$bucket"
    }
}
