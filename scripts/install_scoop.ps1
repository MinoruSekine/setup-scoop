param(
    [switch]$ForceAdmin,
    [switch]$SkipIfAvailable
)

if ($SkipIfAvailable -and (Get-Command "scoop")) {
    exit 0
}
$install_script = [scriptblock]::Create((Invoke-RestMethod -Uri https://get.scoop.sh))
if ($ForceAdmin) {
    & $install_script -RunAsAdmin
} else {
    & $install_script
}
