param(
    [string]$ShareRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

function Run-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed"
    }
}

$patch2 = Join-Path $ShareRoot 'patches\02-vrcft-host-core.patch'

Run-Git apply --check $patch2
Run-Git apply $patch2

Write-Host 'Applied VRCFaceTracking host exact fork patch.'
