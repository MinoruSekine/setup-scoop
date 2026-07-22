param(
    [switch]$ForceAdmin,
    [switch]$SkipIfAvailable
)

Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")
Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

if ($SkipIfAvailable -and (Get-Command "scoop")) {
    Write-SetupScoopLog "`scoop` is found. Skip installation."
    exit 0
}

# Can't use [scriptblock] here,
# because calling `exit` from installer scriptblock terminates
# also caller script.
# That makes difficult to trap errors.
$installerPath = Join-Path $env:RUNNER_TEMP "install-scoop.ps1"
Invoke-RestMethod -Uri https://get.scoop.sh -OutFile $installerPath

if ($ForceAdmin) {
    Invoke-External $installerPath "-RunAsAdmin"
} else {
    Invoke-External $installerPath
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Error "Failed to install 'scoop'." -ErrorAction Stop
}
