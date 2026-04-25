function Invoke-External {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$command,

        [Parameter(Mandatory = $false)]
        [string[]]$parameters = @()
    )

    if (-not $env:SETUP_SCOOP_DRYRUN) {
        & $command @parameters

        # This function doesn't care command
        # which returns non-zero exit codes at successful.
        if (-not $?) {
            Write-Error """$command $($parameters -join ' ')"" failed." `
              -ErrorAction Stop
        }
    } else {
        # Dry run.
        Write-Information "Dry-run: $command $parameters" `
          -InformationAction Continue
    }
}
