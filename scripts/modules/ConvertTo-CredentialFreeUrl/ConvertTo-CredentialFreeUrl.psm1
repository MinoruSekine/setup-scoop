<#
.SYNOPSIS

Convert given URL to credential free.

.DESCRIPTION

URLs of git repositry can include credentials like https PAT.
If write them to file for hash seed,
that can be security vulnerability.
So this function can remove credentials from given URL.

.NOTES

This funciton also supports SCP-like git syntax
(e.g. "git@github.com:owner/repo.git).
#>
function ConvertTo-CredentialFreeUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$repoUrl
    )

    $credentialFreeUrl = ''

    try {
        $uri = [Uri]$repoUrl
        $builder = [UriBuilder]$uri
        $builder.UserName = ''
        $builder.Password = ''

        $port = if ($builder.Uri.IsDefaultPort) { '' } else { ":$($builder.Port)" }
        $credentialFreeUrl = '{0}://{1}{2}{3}' -f `
          $builder.Scheme.ToLowerInvariant(),
          $builder.Host.ToLowerInvariant(),
          $port,
          $builder.Path.TrimEnd('/')
    }
    catch {
        if ($repoUrl -match '\A(?:[^`@/`:]+@)?(?<host>[^/:]+):(?<path>.+)\z') {
            # SCP-like git syntax.
            $credentialFreeUrl = 'ssh://{0}/{1}' -f `
              $Matches.host.ToLowerInvariant(),
              $Matches.path.TrimEnd('/')
        }
    }

    return $credentialFreeUrl
}

Export-ModuleMember -Function 'ConvertTo-CredentialFreeUrl'

