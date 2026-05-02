<#
.SYNOPSIS

Invoke external commands and abort if an error occurred.

.DESCRIPTION

Invoke external application, scripts, or cmdlet.
If error will occur in them,
write message to error stream and abort.

.NOTES

This doesn't support commands that return non-zero values on success.

If environment variable `SETUP_SCOOP_DRYRUN` is set to 'true' or '1',
this writes command and parameters to information stream
instead of invoking command.
#>
function Invoke-External {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$command,

        [Parameter(Mandatory = $false)]
        [string[]]$parameters = @(),

        [Parameter(Mandatory = $false)]
        [string]$errorMessage = $null
    )

    # Set SETUP_SCOOP_DRYRUN to 'true' or '1'
    # to enable dry-run mode for local debugging.
    if ($env:SETUP_SCOOP_DRYRUN -notin @('true', '1')) {
        & $command @parameters

        # This function doesn't support command
        # which returns non-zero exit codes at successful (e.g. diff).
        if (-not $?) {
            if ($errorMessage) {
                $msg = $errorMessage
            } else {
                $msg = """$command $($parameters -join ' ')"" failed."
            }
            Write-Error $msg -ErrorAction Stop
        }
    } else {
        # Dry run.
        Write-Information "Dry-run: $command $($parameters -join ' ')" `
          -InformationAction Continue
    }
}

Export-ModuleMember -Function 'Invoke-External'
