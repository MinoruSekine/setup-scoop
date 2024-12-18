param(
    [Parameter()]
    [string]$apps_string = $(throw "apps parameter is necessary.")
)

Import-Module "$($PSScriptRoot)\LogModule"
Import-Module "$($PSScriptRoot)\AppNameModule"

WriteSetupScoopLog "parameter: ${apps_string}"
[string[]] $apps = @()
if ($apps_string) {
    $apps = $apps_string.Split(" ")
}
WriteSetupScoopLog "apps: ${apps}"
foreach($app in $apps) {
    if (IsAppNameValid $app) {
        Write-Error "Illegal app name `"$app`"." -ErrorAction Stop
    }
    WriteSetupScoopLog "Installing `"${app}`""
    scoop install $app
}
