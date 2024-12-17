Function IsAppNameValid([string]$AppName) {
    return $AppName -inotmatch "^\w[\w/.@-]+$"
}
