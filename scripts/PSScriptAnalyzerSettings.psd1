@{
    # Enable all embeded rules.
    IncludeRules = @('*')

    Rules = @{
        'PSUseCorrectCasing' = @{
            Enable        = $true
            CheckCommands = $true
            CheckKeyword  = $true
            CheckOperator = $true
        }
    }
}
