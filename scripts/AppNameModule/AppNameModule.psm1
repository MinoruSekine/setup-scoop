Function IsAppNameValid([string]$AppName) {
    return $AppName -imatch "^\w[\w/.@-]*$"
}
