function Test-AppName {
    param(
        [string]$AppName
    )
    return $AppName -imatch "\A\w[\w/.@-]*\z"
}
