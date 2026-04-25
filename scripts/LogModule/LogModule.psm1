function Write-SetupScoopLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogMessage
    )
    Write-Information "setup-scoop: $LogMessage" -InformationAction Continue
}
