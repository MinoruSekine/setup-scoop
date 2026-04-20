param([switch]$ForceAdmin)

$install_script = [scriptblock]::Create((Invoke-RestMethod -Uri https://get.scoop.sh))
if ($ForceAdmin) {
    & $install_script -RunAsAdmin
} else {
    & $install_script
}
