Import-Module (Join-Path $($PSScriptRoot) "modules/Write-SetupScoopLog")

function Test-RunnerOS {
    if (-not $env:RUNNER_OS) {
        Write-Error "Environment variable RUNNER_OS is not set." `
          -ErrorAction Stop
    }

    if ($env:RUNNER_OS -ne "Windows") {
        Write-Error @"
setup-scoop supports only Windows runner.
RUNNER_OS is `"$($env:RUNNER_OS)`."
"@ `
          -ErrorAction Stop
    }

    Write-SetupScoopLog "RUNNER_OS `"$($env:RUNNER_OS)`" is supported."
}

Test-RunnerOS
