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
This function returns $false for local git repo.
It will be supported by another way.
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

Export-ModuleMember `
  -Function 'Test-AppName', 'Test-BucketName', 'Test-BucketRepoUrl'
