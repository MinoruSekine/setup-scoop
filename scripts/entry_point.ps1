Import-Module "$($PSScriptRoot)\LogModule"

if($env:INSTALL_SCOOP -eq 'true') {
    if($env:RUN_AS_ADMIN -eq 'true') {
        & "$($PSScriptRoot)\install_scoop.ps1" -ForceAdmin
    } else {
        & "$($PSScriptRoot)\install_scoop.ps1"
    }
    & scoop --version
}
if($env:UPDATE_PATH -eq 'true') {
    Join-Path (Resolve-Path ~).Path "scoop\shims" >> $Env:GITHUB_PATH
}
Write-SetupScoopLog "env:BUCKETS $env:BUCKETS"
if ($env:BUCKETS) {
    & "$($PSScriptRoot)\add_buckets.ps1" "$env:BUCKETS"
}
if($env:SCOOP_UPDATE -eq 'true') { & scoop update }
if($env:SCOOP_CHECKUP -eq 'true') { & scoop checkup }
Write-SetupScoopLog "env:APPS $env:APPS"
if ($env:APPS) {
    Write-SetupScoopLog "Calling install_apps.ps1..."
    & "$($PSScriptRoot)\install_apps.ps1" "$env:APPS"
}
