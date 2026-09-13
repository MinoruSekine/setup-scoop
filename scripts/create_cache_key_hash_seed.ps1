Import-Module (Join-Path $($PSScriptRoot) "modules/Test-Params")

Write-Output "Buckets:`t$env:BUCKETS"
Write-Output "Local buckets:`t$env:LOCAL_BUCKETS"
Write-Output "Apps:`t$env:APPS"

# Output only bucket name in CUSTOM_BUCKETS.
# URL can include secrets like HTTPS access PAT.
[string[]] $lines = @()
if ($env:CUSTOM_BUCKETS) {
    $lines = (
        $env:CUSTOM_BUCKETS -split '\r?\n'
        | ForEach-Object { $_.Trim() }
        | Where-Object { $_ -ne "" }
    )
    if ($lines.count -ge 1) {
        $names = @()
        foreach($line in $lines) {
            $found = $line | Select-String '\A(?<name>\S+)\s+(?<repo>.+)\z'
            if (-not $found) {
                # Parse name part in line.
                Write-Error `
                  "Error in parsing line $i of $($lines.count)" `
                  -ErrorAction Stop
            }
            if (-not $found.Matches[0].Groups['name'].Success) {
                Write-Error `
                  "Error in parsing name in line $i of $($lines.count)" `
                  -ErrorAction Stop
            }
            $name = $found.Matches[0].Groups['name'].Value
            if (Test-BucketName -bucketName $name) {
                $names += $name
            } else {
                Write-Error "Bucket name ""$name"" is illegal." -ErrorAction Stop
            }
        }
        if ($names) {
            Write-Output "custom_buckets:`t$([string]::Join(`" `", $names))"
        }
    }
}
