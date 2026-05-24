param([string]$local_buckets_string)

Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")
Import-Module (Join-Path $($PSScriptRoot) "modules/Test-Params")
Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

Set-Variable `
  -Name "thisFileName" `
  -Value (Split-Path -Leaf $PSCommandPath) `
  -Option Constant `
  -Scope Script

[string[]] $lines = @()
if ($local_buckets_string) {
    $lines = (
        $local_buckets_string -split '\r?\n'
        | ForEach-Object { $_.Trim() }
        | Where-Object { $_ -ne "" }
    )
}
if ($lines.count -ge 1) {
    # Validate and construct name and localPath pair array.
    $list = @()
    foreach($line in $lines) {
        $i = $list.Count + 1
        $found = $line | Select-String '\A(?<name>\S+)\s+(?<localPath>.+)\z'
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
        # Parse local path part in line.
        if (-not $found.Matches[0].Groups['localPath'].Success) {
            Write-Error `
              "Error in parsing localPath in line $i of $($lines.count)" `
              -ErrorAction Stop
        }
        $localPath = $found.Matches[0].Groups['localPath'].Value
        if ((Test-BucketLocalPath -bucketLocalPath $localPath) -eq $false) {
            Write-Error @"
Local path in line $i of $($lines.count) is illegal.
`local_buckets` parameter is for local-path-styled bucket.
"@ `
              -ErrorAction Stop
        }
        $parsed = @{
            Name = $name
            LocalPath = (Resolve-Path -Path $localPath)
        }
        $list += $parsed
    }
    if($list.Count -ne $lines.Count) {
        Write-Error "$($list.Count) should be $($lines.Count)." `
          -ErrorAction Stop
    }
    # Add buckets by constructed name and localPath pair array.
    foreach($item in $list) {
        Write-SetupScoopLog "Adding local bucket ""$($item.Name)"" ..."
        $url = "file://$($item.LocalPath -replace '\\', '/')"
        Invoke-External `
          -Command "scoop" `
          -Parameters @("bucket", "add", "$($item.Name)", "$url") `
          -ErrorMessage """scoop bucket add $($item.Name)"" failed."
    }
} else {
    Write-Error "Missing parameter for ${thisFileName}." -ErrorAction Stop
}
