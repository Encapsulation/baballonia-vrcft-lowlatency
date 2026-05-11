$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed"
    }
}

function Test-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git @Args > $null 2> $null
        return $LASTEXITCODE -eq 0
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Get-GitText {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

    $output = & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed"
    }
    return (($output -join "`n").Trim())
}

function Assert-RepositoryRoot {
    param(
        [string]$RepoName,
        [string[]]$RequiredPaths
    )

    $root = Get-GitText rev-parse --show-toplevel
    Set-Location $root

    foreach ($path in $RequiredPaths) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Wrong folder for $RepoName. Missing '$path'. Run this script from the $RepoName repo root."
        }
    }

    return $root
}

function Assert-ExactHead {
    param(
        [string]$RepoName,
        [string]$ExpectedCommit
    )

    $actual = Get-GitText rev-parse HEAD
    if ($actual -ne $ExpectedCommit) {
        throw "Wrong $RepoName checkout. Expected $ExpectedCommit, got $actual."
    }
}

function Apply-GitPatchOnce {
    param(
        [string]$PatchPath,
        [string]$PatchName
    )

    if (-not (Test-Path -LiteralPath $PatchPath)) {
        throw "Missing patch: $PatchPath"
    }

    if (Test-Git apply --check $PatchPath) {
        Invoke-Git apply $PatchPath
        Write-Host "Applied $PatchName."
        return
    }

    if (Test-Git apply --reverse --check $PatchPath) {
        Write-Host "$PatchName already applied."
        return
    }

    throw "$PatchName does not apply cleanly here and is not already applied. Check the repo, baseline commit, and patch role."
}
