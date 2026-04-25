function Test-AppName {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )
    return $AppName -imatch "\A\w[\w/.@-]*\z"
}
