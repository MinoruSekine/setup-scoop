<#
.SYNOPSIS

Write log string to information stream with prefix.
#>
function Write-SetupScoopLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogMessage
    )
    Write-Information "setup-scoop: $LogMessage" -InformationAction Continue
}
