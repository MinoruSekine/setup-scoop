param(
    [Parameter()]
    [string]$apps_string = $(throw "apps parameter is necessary.")
)
Write-Host parameter: $apps_string
[string[]] $apps = @()
if ($apps_string) {
    $apps = $apps_string.Split(" ")
}
Write-Host apps: $apps
foreach($app in $apps) {
    if ($app -inotmatch "^\w[\w/.@]+$") {
        Write-Error "Illegal app name `"$app`"." -ErrorAction Stop
    }
    Write-Host app: $app
    scoop install $app
}
