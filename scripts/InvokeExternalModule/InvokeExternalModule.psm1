function Invoke-External {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$command,

        [Parameter(Mandatory = $false)]
        [string[]]$parameters = @()
    )

    # Set SETUP_SCOOP_DRYRUN to 'true' or '1' to enable dry-run mode for local debugging.
    if ($env:SETUP_SCOOP_DRYRUN -notin @('true', '1')) {
        & $command @parameters

        # This function doesn't support command
        # which returns non-zero exit codes at successful (e.g. diff).
        if (-not $?) {
            Write-Error """$command $($parameters -join ' ')"" failed." `
              -ErrorAction Stop
        }
    } else {
        # Dry run.
        Write-Information "Dry-run: $command $($parameters -join ' ')" `
          -InformationAction Continue
    }
}
