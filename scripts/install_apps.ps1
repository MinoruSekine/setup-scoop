param(
    [Parameter()]
    [string]$apps_string = $(throw "apps parameter is necessary.")
)

Import-Module (Join-Path $($PSScriptRoot) "modules/Invoke-External")
Import-Module (Join-Path $($PSScriptRoot) "modules/Test-Params")
Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

[string[]] $apps = @()
if ($apps_string) {
    $apps = $apps_string.Split(" ")
}
Set-Variable `
  -Name "thisFileName" `
  -Value (Split-Path -Leaf $PSCommandPath) `
  -Option Constant `
  -Scope Local
Write-SetupScoopLog "${thisFileName}: $($apps -join ' ')"
foreach($app in $apps) {
    if (-not (Test-AppName $app)) {
        Write-Error "Illegal app name `"$app`"." -ErrorAction Stop
    }
}
foreach($app in $apps) {
    Invoke-External -Command "scoop" -Parameters "install", "$app"
}
