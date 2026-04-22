Describe 'IsAppNameValid' {
    $modulePath = Join-Path $PSScriptRoot "AppNameModule.psm1"
    Import-Module $modulePath -Force


    Context 'AppsInKnownBucket' {
         $apps = @(scoop search | Where-Object { $_.Name } | ForEach-Object {
             @{ Name = $_.Name }
         })
        if ($apps.Count -eq 0) {
            throw "No app names were discovered from 'scoop search'."
         }
        It 'Validation should pass for <Name>' -ForEach $apps {
            $result = IsAppNameValid $Name

            if ($result -eq $false) {
                Write-Warning "Validation failed for app: [$Name]"
            }

            $result | Should -Be $true
        }
    }

    Context 'FixedSampleAppNames' {
        It 'App name <name> should be valid' -ForEach @(
            @{ name = "foo" }
            @{ name = "FooBar" }
            @{ name = "Foo-Bar" }
            @{ name = "g" }
        ) {
            IsAppNameValid $name | Should -Be $true
        }
        It 'App name <name> should be invalid' -ForEach @(
            @{ name = "-foo" }
            @{ name = "foo*bar" }
            @{ name = "foo`n" }
        ) {
            IsAppNameValid $name | Should -Be $false
        }
    }
}
