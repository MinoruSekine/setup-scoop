Function IsAppNameValid([string]$AppName) {
    return $AppName -imatch "\A\w[\w/.@-]*\z"
}
