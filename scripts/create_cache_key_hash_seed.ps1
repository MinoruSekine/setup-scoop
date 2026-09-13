Import-Module (Join-Path $($PSScriptRoot) "modules/ConvertTo-CredentialFreeUrl")
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
        $custom_buckets = @()
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
            if (-not (Test-BucketName -bucketName $name)) {
                Write-Error "Bucket name ""$name"" is illegal." -ErrorAction Stop
            }
            # Parse repo URL part in line.
            if (-not $found.Matches[0].Groups['repo'].Success) {
                Write-Error `
                  "Error in parsing repo in line $i of $($lines.count)" `
                  -ErrorAction Stop
            }
            $repoUrl = $found.Matches[0].Groups['repo'].Value
            if (-not (Test-BucketRepoUrl -bucketRepoUrl $repoUrl)) {
                Write-Error @"
Repo in line $i of $($lines.count) is illegal.
`custom_buckets` parameter is for URL-styled repo bucket.
"@ `
  -ErrorAction Stop
            }
            $custom_buckets += @{
                name = $name
                credentialFreeUrl = ConvertTo-CredentialFreeUrl $repoUrl
            }
        }
        if ($custom_buckets) {
            $custom_buckets | ForEach-Object {
                Write-Output "custom_buckets:`t$($_.name) $($_.credentialFreeUrl)"
            }
        }
    }
}
