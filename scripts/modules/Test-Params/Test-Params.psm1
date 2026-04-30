<#
.SYNOPSIS

Test given string is a legal application name in scoop.

.DESCRIPTION

Test given string is a legal application name in scoop
by regex.
#>
function Test-AppName {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )
    return $AppName -imatch "\A\w[\w/.@-]*\z"
}

Export-ModuleMember -Function 'Test-AppName'
