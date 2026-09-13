Describe 'ConvertTo-CredentialFreeUrl' {
    $modulePath = Join-Path $PSScriptRoot "ConvertTo-CredentialFreeUrl.psm1"
    Import-Module $modulePath -Force


    Context 'SimpleUrl' {
        $urls = @(
            'https://github.com/MinoruSekine/setup-scoop.git',
            'https://github.com/ScoopInstaller/Extras.git'
        )

        It '<_> needs no conversion' -ForEach $urls {
            ConvertTo-CredentialFreeUrl $_ | Should -Be $_
        }
    }

    Context 'UrlWithCredentials' {
        $addrs = @(
            @{
                src = 'https://PAT@github.com/owner/repo.git'
                expected = 'https://github.com/owner/repo.git'
            }
        )

        It 'Converted Url should be credentials free' -ForEach $addrs {
            ConvertTo-CredentialFreeUrl $src | Should -Be $expected
        }
    }

    Context 'ScpStyle' {
        $addrs = @(
            @{
                src = 'git@github.com:owner/repo.git'
                expected = 'ssh://github.com/owner/repo.git'
            }
        )

        It 'SCP-styled git syntax should be converted into credentials free Url' `
          -ForEach $addrs {
            ConvertTo-CredentialFreeUrl $src | Should -Be $expected
        }
    }
}
