Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")

# Fail fast by unsupported runner.
Invoke-External -Command "$($PSScriptRoot)\test_runner_os.ps1"

# Fail fast by unsupported Action parameter(s).
Invoke-External -Command "$($PSScriptRoot)\test_action_params.ps1"

if ($env:CACHE_HIT -ne 'true') {
    if ($env:INSTALL_SCOOP -eq 'true' -or $env:INSTALL_SCOOP -eq 'force') {
        $params = @()
        if($env:INSTALL_SCOOP -ne 'force') {
            $params += "-SkipIfAvailable"
        }
        if($env:RUN_AS_ADMIN -eq 'true') {
            $params += "-ForceAdmin"
        }
        Invoke-External -Command "$($PSScriptRoot)\install_scoop.ps1" `
          -Parameters $params
        Invoke-External -Command "scoop" -Parameters "--version"
    }
}
if ($env:UPDATE_PATH -eq 'true') {
    $scoopPath = Join-Path (Resolve-Path ~).Path "scoop\shims"
    $scoopPath >> $Env:GITHUB_PATH
    $env:PATH = "$scoopPath;$env:PATH"
}
if ($env:CACHE_HIT -ne 'true') {
    if ($env:BUCKETS) {
        Invoke-External -Command "$($PSScriptRoot)\add_known_buckets.ps1" `
          -Parameters "$env:BUCKETS"
    }
    # CUSTOM_BUCKETS shouldn't be output to log,
    # because it can be include HTTPS PAT or some secrets.
    if ($env:CUSTOM_BUCKETS) {
        Invoke-External -Command "$($PSScriptRoot)\add_custom_buckets.ps1" `
          -Parameters "$env:CUSTOM_BUCKETS"
    }
    if ($env:LOCAL_BUCKETS) {
        Invoke-External -Command "$($PSScriptRoot)\add_local_buckets.ps1" `
          -Parameters "$env:LOCAL_BUCKETS"
    }
}
if ($env:SCOOP_UPDATE -eq 'true') {
    Invoke-External -Command "scoop" -Parameters "update"
}
if ($env:SCOOP_CHECKUP -eq 'true') {
    Invoke-External -Command "scoop" -Parameters "checkup"
}
if ($env:CACHE_HIT -ne 'true') {
    if ($env:APPS) {
        Invoke-External -Command "$($PSScriptRoot)\install_apps.ps1" `
          -Parameters "$env:APPS"
    }
}
# Clear scoop download cache before create cache of `~/scoop` dir.
# This is also necessary when cache hit,
# because saving cache will be processed also on cache hit.
if ($env:CACHE -eq 'true' -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-External -Command "scoop" -Parameters "cache", "rm", "--all"
    Invoke-External -Command "scoop" -Parameters "cleanup", "--all", "--cache"
}
