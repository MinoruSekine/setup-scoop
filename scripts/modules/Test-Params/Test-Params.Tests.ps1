Describe 'Test-AppName' {
    $modulePath = Join-Path $PSScriptRoot "Test-Params.psm1"
    Import-Module $modulePath -Force


    Context 'AppsInKnownBucket' {
         $apps = @(scoop search | Where-Object { $_.Name } | ForEach-Object {
             @{ Name = $_.Name }
         })
        if ($apps.Count -eq 0) {
            throw "No app names were discovered from 'scoop search'."
         }
        It 'Validation should pass for <Name>' -ForEach $apps {
            $result = Test-AppName $Name

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
            Test-AppName $name | Should -Be $true
        }
        It 'App name <name> should be invalid' -ForEach @(
            @{ name = "-foo" }
            @{ name = "foo*bar" }
            @{ name = "foo`n" }
        ) {
            Test-AppName $name | Should -Be $false
        }
    }
}

Describe 'Test-BucketName' {
    $modulePath = Join-Path $PSScriptRoot "Test-Params.psm1"
    Import-Module $modulePath -Force


    Context 'ValidName' {
        It 'Bucket name <name> should be valid' -ForEach @(
            @{ name = 'bar' }
            @{ name = 'barbar' }
            @{ name = 'bar-' }
            @{ name = 'bar-bar' }
        ) {
            Test-BucketName $name | Should -Be $true
        }
    }

    Context 'NameStartingWithDash' {
        It 'Bucket name <name> should be invalid' -ForEach @(
            @{ name = '-' }
            @{ name = '--' }
            @{ name = '-bar' }
            @{ name = '--bar' }
        ) {
            Test-BucketName $name | Should -Be $false
        }
    }
}

Describe 'Test-BucketRepoUrl' {
    $modulePath = Join-Path $PSScriptRoot "Test-Params.psm1"
    Import-Module $modulePath -Force


    Context 'ValidRepo' {
        It 'Bucket remote repo <repo> should be valid' -ForEach @(
            @{ repo = 'https://github.com/MinoruSekine/setup-scoop.git' }
            @{ repo = 'git@github.com:MinoruSekine/setup-scoop.git' }
        ) {
            Test-BucketRepoUrl $repo | Should -Be $true
        }
    }

    Context 'InvalidRepo' {
        It 'Bucket remote repo <repo> should be invalid' -ForEach @(
            @{ repo = '-' }
            @{ repo = '--' }
            @{ repo = '-bar' }
            @{ repo = '--bar' }
            @{ repo = '/' } # Local paths will be supported by another way.
            @{ repo = './local-bucket' }
            @{ repo = '../local-bucket' }
            @{ repo = 'tmp/local-bucket' }
            @{ repo = $PSScriptRoot }
            @{ repo = $PSScriptRoot -replace '\\', '/' }
        ) {
            Test-BucketRepoUrl $repo | Should -Be $false
        }
    }
}

Describe 'Test-BucketLocalPath' {
    $modulePath = Join-Path $PSScriptRoot "Test-Params.psm1"
    Import-Module $modulePath -Force


    Context 'ValidLocalPath' {
        It 'Bucket local path <localPath> should be valid' -ForEach @(
            @{ localPath = './' }
            @{ localPath = $PSScriptRoot }
            @{ localPath = $PSScriptRoot -replace '\\', '/' }
            @{ localPath = $PSScriptRoot | Resolve-Path }
        ) {
            Test-BucketLocalPath $localPath | Should -Be $true
        }
    }

    Context 'InvalidLocalPath' {
        It 'Bucket local path <localPath> should be invalid' -ForEach @(
            @{ localPath = '-' }
            @{ localPath = '--' }
            @{ localPath = '-bar' }
            @{ localPath = '--bar' }
            @{ localPath = 'C:\does\not\exist' }
            @{ localPath = 'https://github.com/MinoruSekine/setup-scoop.git' }
        ) {
            Test-BucketLocalPath $localPath | Should -Be $false
        }
    }
}

Describe 'Test-CacheVersion' {
    $modulePath = Join-Path $PSScriptRoot "Test-Params.psm1"
    Import-Module $modulePath -Force


    Context 'ValidCacheVersion' {
        It 'Cache version string <cacheVersion> should be valid' -ForEach @(
            @{ cacheVersion = 'v0' }
            @{ cacheVersion = 'v0.1' }
            @{ cacheVersion = 'v1' }
            @{ cacheVersion = 'v2' }
            @{ cacheVersion = 'v10' }
            @{ cacheVersion = 'v1.1' }
        ) {
            Test-CacheVersion $cacheVersion | Should -Be $true
        }
    }

    Context 'InvalidCacheVersion' {
        It 'Cache version string <cacheVersion> should be invalid' -ForEach @(
            @{ cacheVersion = '_v0' }
            @{ cacheVersion = '_v0.1' }
            @{ cacheVersion = 'v1_' }
            @{ cacheVersion = 'v2_' }
            @{ cacheVersion = '_v10_' }
            @{ cacheVersion = 'v1_1' }
        ) {
            Test-CacheVersion $cacheVersion | Should -Be $false
        }
    }
}
