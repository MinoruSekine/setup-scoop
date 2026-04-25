function Write-SetupScoopLog {
    param(
        [string]$LogMessage
    )
    Write-Information "setup-scoop: $LogMessage" -InformationAction Continue
}
