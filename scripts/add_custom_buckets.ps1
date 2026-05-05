param([string]$custom_buckets_string)

Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")
Import-Module (Join-Path $($PSScriptRoot) "modules/Test-Params")
Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

Set-Variable `
  -Name "thisFileName" `
  -Value (Split-Path -Leaf $PSCommandPath) `
  -Option Constant `
  -Scope Script

[string[]] $lines = @()
if ($custom_buckets_string) {
    $lines = (
        $custom_buckets_string -split '\r?\n'
        | ForEach-Object { $_.Trim() }
        | Where-Object { $_ -ne "" }
    )
}
# $custom_buckets_string, $lines, $line, $repoUrl, $list, and $list.RepoURL
# shouldn't be output to log,
# because they can be include HTTPS PAT or some secrets.
if ($lines.count -ge 1) {
    # Validate and construct name and repoUrl pair array.
    $list = @()
    foreach($line in $lines) {
        $i = $list.Count + 1
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
        if ((Test-BucketName -bucketName $name) -eq $false) {
            Write-Error "Bucket name ""$name"" is illegal." -ErrorAction Stop
        }
        # Parse repo URL part in line.
        if (-not $found.Matches[0].Groups['repo'].Success) {
            Write-Error `
              "Error in parsing repo in line $i of $($lines.count)" `
              -ErrorAction Stop
        }
        $repoUrl = $found.Matches[0].Groups['repo'].Value
        if ((Test-BucketRepoUrl -bucketRepoUrl $repoUrl) -eq $false) {
            Write-Error @"
Repo in line $i of $($lines.count) is illegal.
`custom_buckets` parameter is for URL-styled repo bucket.
"@ `
              -ErrorAction Stop
        }
        $parsed = @{
            Name = $name
            RepoURL = $repoUrl
        }
        $list += $parsed
    }
    if($list.Count -ne $lines.Count) {
        Write-Error "$($list.Count) should be $($lines.Count)." `
          -ErrorAction Stop
    }
    # Add buckets by constructed name and repoUrl pair array.
    foreach($item in $list) {
        Write-SetupScoopLog "Adding custom bucket ""$($item.Name)"" ..."
        Invoke-External `
          -Command "scoop" `
          -Parameters @("bucket", "add", "$($item.Name)", "$($item.RepoURL)") `
          -ErrorMessage """scoop bucket add $($item.Name)"" failed."
    }
} else {
    Write-Error "Missing parameter for ${thisFileName}." -ErrorAction Stop
}
