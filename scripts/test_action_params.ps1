function Test-ActionParam {
    param (
        [hashtable]$ActionParam
    )

    # It is capable that specific env is undefined.
    if ([string]::IsNullOrEmpty($ActionParam.value)) {
        return
    }

    if ($ActionParam.value -notin $ActionParam.allowed) {
        # $ActionParam.value should not be in error log,
        # because action users can store secrets into them.
        Write-Error @"
Unsupported parameter in $($ActionParam.name).
Supported value is one of $($ActionParam.allowed -join ", ").
"@ `
          -ErrorAction Stop
    }
}

# Parameters to validate which are stored in environment variables.
# In this script,
# validate parameters which are only allowed limited set of parameters.
$actionParams = @(
    @{
        value = $env:INSTALL_SCOOP;
        name = 'INSTALL_SCOOP';
        allowed = @('true', 'false', 'force')
    };
    @{
        value = $env:RUN_AS_ADMIN;
        name = 'RUN_AS_ADMIN';
        allowed = @('true', 'false')
    };
    @{
        value = $env:UPDATE_PATH;
        name = 'UPDATE_PATH';
        allowed = @('true', 'false')
    };
    @{
        value = $env:SCOOP_UPDATE;
        name = 'SCOOP_UPDATE';
        allowed = @('true', 'false')
    };
    @{
        value = $env:SCOOP_CHECKUP;
        name = 'SCOOP_CHECKUP';
        allowed = @('true', 'false')
    }
)

foreach ($i in $actionParams) {
    Test-ActionParam -ActionParam $i
}
