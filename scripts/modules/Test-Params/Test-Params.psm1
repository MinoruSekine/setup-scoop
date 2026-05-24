function Test-ScoopIdentifier {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$identifier
    )
    return $identifier -imatch "\A\w[\w/.@-]*\z"
}

<#
.SYNOPSIS

Test given string is a legal application name in scoop.

.DESCRIPTION

Test given string is a legal application name in scoop
by regex.
#>
function Test-AppName {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$appName
    )
    return Test-ScoopIdentifier -Identifier $appName
}

<#
.SYNOPSIS

Test given string is a legal bucket name in scoop.

.DESCRIPTION

Test given string is a legal bucket name in scoop
by regex.
#>
function Test-BucketName {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$bucketName
    )
    return Test-ScoopIdentifier -Identifier $bucketName
}

function Test-LocalAbsoluteWindowsPath {
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$str
    )
    return ($str -imatch "\A[a-z]:.*")
}

<#
.SYNOPSIS

Test given string is a legal bucket remote repo in scoop.

.DESCRIPTION

Test given string is a legal bucket remote repo in scoop
by regex.
This function returns $false for local git repo,
that is supported by Test-BucketLocalPath.
#>
function Test-BucketRepoUrl {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$bucketRepoUrl
    )
    return (
        ($bucketRepoUrl -imatch "\A\w[\w/.:@-]*\z") -and
        (-not (Test-LocalAbsoluteWindowsPath $bucketRepoUrl)) -and
        ($bucketRepoUrl -imatch ":")  # Remote repo requires colon.
    )
}

<#
.SYNOPSIS

Test given string is a legal bucket local repo in scoop.

.DESCRIPTION

Test given string is a legal bucket local repo in scoop.
This function returns $false for remote git repo,
that is supported by Test-BucketRepoUrl.
#>
function Test-BucketLocalPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$bucketLocalPath
    )
    return (
        (-not $bucketLocalPath.StartsWith('-')) -and
        ((Test-LocalAbsoluteWindowsPath $bucketLocalPath) -or
         ($bucketLocalPath -notlike "*:*")) -and
        (Test-Path -Path $bucketLocalPath -PathType Container) -and
        ($null -ne (Resolve-Path -Path $bucketLocalPath -ErrorAction SilentlyContinue))
    )
}

Export-ModuleMember `
  -Function `
  'Test-AppName', 'Test-BucketLocalPath', 'Test-BucketName', 'Test-BucketRepoUrl'
