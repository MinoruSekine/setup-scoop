param(
    [Parameter()]
    [string]$apps_string = $(throw "apps parameter is necessary.")
)

Import-Module "$($PSScriptRoot)\AppNameModule"
Import-Module "$($PSScriptRoot)\InvokeExternalModule"
Import-Module "$($PSScriptRoot)\LogModule"

Write-SetupScoopLog "parameter: ${apps_string}"
[string[]] $apps = @()
if ($apps_string) {
    $apps = $apps_string.Split(" ")
}
Write-SetupScoopLog "apps: ${apps}"
foreach($app in $apps) {
    if (-not (Test-AppName $app)) {
        Write-Error "Illegal app name `"$app`"." -ErrorAction Stop
    }
    Write-SetupScoopLog "Installing `"${app}`""
    Invoke-External -Command "scoop" -Parameters "install", "$app"
}
