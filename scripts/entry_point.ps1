Import-Module "$($PSScriptRoot)\InvokeExternalModule"
Import-Module "$($PSScriptRoot)\LogModule"

if($env:INSTALL_SCOOP -eq 'true') {
    if($env:RUN_AS_ADMIN -eq 'true') {
        Invoke-External -Command "$($PSScriptRoot)\install_scoop.ps1"`
          -Parameters "-ForceAdmin"
    } else {
        Invoke-External -Command "$($PSScriptRoot)\install_scoop.ps1"
    }
    Invoke-External -Command "scoop" -Parameters "--version"
}
if($env:UPDATE_PATH -eq 'true') {
    Join-Path (Resolve-Path ~).Path "scoop\shims" >> $Env:GITHUB_PATH
}
Write-SetupScoopLog "env:BUCKETS $env:BUCKETS"
if ($env:BUCKETS) {
    Invoke-External -Command "$($PSScriptRoot)\add_buckets.ps1" `
      -Parameters "$env:BUCKETS"
}
if($env:SCOOP_UPDATE -eq 'true') {
    Invoke-External -Command "scoop" -Parameters "update"
}
if($env:SCOOP_CHECKUP -eq 'true') {
    Invoke-External -Command "scoop" -Parameters "checkup"
}
Write-SetupScoopLog "env:APPS $env:APPS"
if ($env:APPS) {
    Write-SetupScoopLog "Calling install_apps.ps1..."
    Invoke-External -Command "$($PSScriptRoot)\install_apps.ps1" `
      -Parameters "$env:APPS"
}
