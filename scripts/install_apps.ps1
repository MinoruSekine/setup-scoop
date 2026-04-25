param(
    [Parameter()]
    [string]$apps_string = $(throw "apps parameter is necessary.")
)

Import-Module "$($PSScriptRoot)\LogModule"
Import-Module "$($PSScriptRoot)\AppNameModule"

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
    & scoop install $app
}
