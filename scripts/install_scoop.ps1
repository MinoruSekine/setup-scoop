param(
    [switch]$ForceAdmin,
    [switch]$SkipIfAvailable
)

Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

if ($SkipIfAvailable -and (Get-Command "scoop")) {
    Write-SetupScoopLog "`scoop` is found. Skip installation."
    exit 0
}
$installScript = [scriptblock]::Create((Invoke-RestMethod -Uri https://get.scoop.sh))
if ($ForceAdmin) {
    & $installScript -RunAsAdmin
} else {
    & $installScript
}
