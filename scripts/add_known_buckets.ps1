param([string]$buckets_string)

Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")
Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

[string[]] $buckets = @()
if ($buckets_string) {
    $buckets = $buckets_string.Split(" ")
}
if ($buckets.count -ge 1) {
    # Next line needs outputs through PowerShell pipeline,
    # so Invoke-External will not be suitable for here.
    # Note: SETUP_SCOOP_DRYRUN will not be effected here.
    $known_buckets=& scoop bucket known
    if (-not $?) {
        Write-Error "Failed to get known buckets by ""scoop bucket known""." `
          -ErrorAction Stop
    }
    Set-Variable `
      -Name "thisFileName" `
      -Value (Split-Path -Leaf $PSCommandPath) `
      -Option Constant `
      -Scope Local
    foreach($bucket in $buckets) {
        if($null -eq ($known_buckets | Where-Object {$_ -eq $bucket})) {
            Write-Error (
                "Bucket `"$bucket`" is not in known buckets " +
                "($($known_buckets -join ','))."
            ) -ErrorAction Stop
        }
        Write-SetupScoopLog `
          "$thisFileName is adding known bucket ""${bucket}"" ..."
        Invoke-External -Command "scoop" -Parameters "bucket", "add", "$bucket"
    }
}
