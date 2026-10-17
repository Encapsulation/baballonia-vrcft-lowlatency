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

function Set-CanonicalLineEndings {
    param([string]$RepoName)

    # The patches were generated against a core.autocrlf=true (CRLF) checkout. Recreate that checkout so they
    # apply byte-exact regardless of the user's global git settings. Only touches a pristine working tree.
    $current = (& git config --get core.autocrlf) 2>$null
    if ($current -eq 'true') { return }

    $status = Get-GitText status --porcelain --untracked-files=no
    if ($status) {
        Write-Host "$RepoName has local changes; leaving line endings as they are."
        return
    }

    Invoke-Git config core.autocrlf true
    Invoke-Git rm --cached -r -q .
    Invoke-Git reset --hard -q
    Write-Host "$RepoName checked out with CRLF line endings (core.autocrlf=true) to match the patches."
}
